import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../data/signal_reef_save_store.dart';
import '../data/wave_definitions.dart';
import '../domain/run_result.dart';
import '../domain/save_data.dart';
import '../game/signal_reef_game.dart';
import 'signal_reef_ads.dart';
import 'signal_reef_feedback.dart';
import 'signal_reef_telemetry.dart';

enum SignalReefScreen { home, playing, settings, result }

class SignalReefController extends ChangeNotifier {
  SignalReefController({
    required this.saveStore,
    required SignalReefSaveData initialSave,
    required this.ads,
    this.telemetry = const NoOpSignalReefTelemetry(),
    this.feedback = const PlatformSignalReefFeedback(),
  }) : _saveData = initialSave;

  final SignalReefSaveStore saveStore;
  final SignalReefAdService ads;
  final SignalReefTelemetry telemetry;
  final SignalReefFeedback feedback;

  SignalReefSaveData _saveData;
  SignalReefScreen _screen = SignalReefScreen.home;
  SignalReefGame? _game;
  SignalReefRunResult? _lastResult;
  var _isPaused = false;
  var _resultInterstitialConsidered = false;
  var _notificationQueued = false;
  var _disposed = false;

  SignalReefScreen get screen => _screen;

  SignalReefGame? get game => _game;

  SignalReefRunResult? get lastResult => _lastResult;

  bool get isPaused => _isPaused;

  int get bestScore => _saveData.bestScore;

  bool get soundEnabled => _saveData.soundEnabled;

  bool get hapticsEnabled => _saveData.hapticsEnabled;

  int get bestWaveReached => _saveData.bestWaveReached;

  int get totalWaves => productionWaveDefinitions.length;

  SignalReefFeedbackSettings get feedbackSettings {
    return SignalReefFeedbackSettings(
      soundEnabled: soundEnabled,
      hapticsEnabled: hapticsEnabled,
    );
  }

  void trackAppOpen() {
    telemetry.track(
      SignalReefTelemetryEvents.appOpen(
        runsPlayed: _saveData.runsPlayed,
        bestScore: _saveData.bestScore,
        bestWaveReached: _saveData.bestWaveReached,
        totalWaves: totalWaves,
      ),
    );
  }

  void play({String source = 'menu'}) {
    _playFeedback(SignalReefFeedbackCue.tap);
    _isPaused = false;
    _lastResult = null;
    _resultInterstitialConsidered = false;
    _game = SignalReefGame(
      waves: productionWaveDefinitions,
      telemetry: telemetry,
      feedback: feedback,
      feedbackSettings: () => feedbackSettings,
      onStateChanged: _notifyListenersSafely,
      onRunFinished: _finishRun,
    );
    _screen = SignalReefScreen.playing;
    telemetry.track(
      SignalReefTelemetryEvents.gameStart(
        source: source,
        totalWaves: totalWaves,
        runsPlayed: _saveData.runsPlayed,
      ),
    );
    _notifyListenersSafely();
  }

  void retry() {
    telemetry.track(SignalReefTelemetryEvents.gameRestart());
    play(source: 'retry');
  }

  void pause() {
    if (_screen != SignalReefScreen.playing || _isPaused) {
      _playFeedback(SignalReefFeedbackCue.invalidAction);
      return;
    }

    _playFeedback(SignalReefFeedbackCue.tap);
    _game?.pauseEngine();
    _isPaused = true;
    telemetry.track(SignalReefTelemetryEvents.pauseOpen());
    _notifyListenersSafely();
  }

  void resume() {
    if (!_isPaused) {
      _playFeedback(SignalReefFeedbackCue.invalidAction);
      return;
    }

    _playFeedback(SignalReefFeedbackCue.tap);
    _game?.resumeEngine();
    _isPaused = false;
    telemetry.track(SignalReefTelemetryEvents.pauseResume());
    _notifyListenersSafely();
  }

  void backHome() {
    _playFeedback(SignalReefFeedbackCue.tap);
    _game?.pauseEngine();
    _isPaused = false;
    _screen = SignalReefScreen.home;
    _notifyListenersSafely();
  }

  void showSettings() {
    _playFeedback(SignalReefFeedbackCue.tap);
    _screen = SignalReefScreen.settings;
    _notifyListenersSafely();
  }

  void toggleSound(bool value) {
    _saveData = _saveData.copyWith(soundEnabled: value);
    _playFeedback(SignalReefFeedbackCue.validAction);
    telemetry.track(
      SignalReefTelemetryEvents.settingsChanged(
        setting: 'sound',
        enabled: value,
      ),
    );
    _save();
    _notifyListenersSafely();
  }

  void toggleHaptics(bool value) {
    _saveData = _saveData.copyWith(hapticsEnabled: value);
    _playFeedback(SignalReefFeedbackCue.validAction);
    telemetry.track(
      SignalReefTelemetryEvents.settingsChanged(
        setting: 'haptics',
        enabled: value,
      ),
    );
    _save();
    _notifyListenersSafely();
  }

  void _finishRun(SignalReefRunResult result) {
    final bestScore = result.score > _saveData.bestScore
        ? result.score
        : _saveData.bestScore;
    final bestWaveReached = result.waveReached > _saveData.bestWaveReached
        ? result.waveReached
        : _saveData.bestWaveReached;
    final updatedBest = bestScore != _saveData.bestScore;

    _lastResult = result;
    _resultInterstitialConsidered = false;
    _saveData = _saveData.copyWith(
      bestScore: bestScore,
      bestWaveReached: bestWaveReached,
      runsPlayed: _saveData.runsPlayed + 1,
    );
    _screen = SignalReefScreen.result;
    _isPaused = false;
    ads.recordRunFinished();
    telemetry.track(
      SignalReefTelemetryEvents.gameResult(
        score: result.score,
        waveReached: result.waveReached,
        wavesCleared: result.wavesCleared,
        durationSeconds: result.durationSeconds,
        hullRemaining: result.hullRemaining,
        won: result.won,
      ),
    );

    if (updatedBest) {
      telemetry.track(
        SignalReefTelemetryEvents.bestScoreUpdated(bestScore: bestScore),
      );
    }

    _save();
    _notifyListenersSafely();
  }

  void maybeShowResultInterstitial() {
    if (_screen != SignalReefScreen.result || _resultInterstitialConsidered) {
      return;
    }

    _resultInterstitialConsidered = true;
    ads.maybeShowResultInterstitial();
  }

  void _save() {
    unawaited(saveStore.save(_saveData));
  }

  void _playFeedback(SignalReefFeedbackCue cue) {
    feedback.play(cue, feedbackSettings);
  }

  void _notifyListenersSafely() {
    if (_disposed) {
      return;
    }

    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      notifyListeners();
      return;
    }

    if (_notificationQueued) {
      return;
    }

    _notificationQueued = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _notificationQueued = false;
      if (!_disposed) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
