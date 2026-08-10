import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/signal_reef_save_store.dart';
import '../data/wave_definitions.dart';
import '../domain/run_result.dart';
import '../domain/save_data.dart';
import '../game/signal_reef_game.dart';
import 'signal_reef_telemetry.dart';

enum SignalReefScreen { home, playing, settings, result }

class SignalReefController extends ChangeNotifier {
  SignalReefController({
    required this.saveStore,
    required SignalReefSaveData initialSave,
    this.telemetry = const NoOpSignalReefTelemetry(),
  }) : _saveData = initialSave;

  final SignalReefSaveStore saveStore;
  final SignalReefTelemetry telemetry;

  SignalReefSaveData _saveData;
  SignalReefScreen _screen = SignalReefScreen.home;
  SignalReefGame? _game;
  SignalReefRunResult? _lastResult;
  var _isPaused = false;

  SignalReefScreen get screen => _screen;

  SignalReefGame? get game => _game;

  SignalReefRunResult? get lastResult => _lastResult;

  bool get isPaused => _isPaused;

  int get bestScore => _saveData.bestScore;

  bool get soundEnabled => _saveData.soundEnabled;

  bool get musicEnabled => _saveData.musicEnabled;

  bool get hapticsEnabled => _saveData.hapticsEnabled;

  void play({String source = 'menu'}) {
    _isPaused = false;
    _lastResult = null;
    _game = SignalReefGame(
      waves: prototypeWaveDefinitions,
      telemetry: telemetry,
      onStateChanged: notifyListeners,
      onRunFinished: _finishRun,
    );
    _screen = SignalReefScreen.playing;
    telemetry.track(SignalReefTelemetryEvents.gameStart(source: source));
    notifyListeners();
  }

  void retry() {
    telemetry.track(SignalReefTelemetryEvents.gameRestart());
    play(source: 'retry');
  }

  void pause() {
    if (_screen != SignalReefScreen.playing || _isPaused) {
      return;
    }

    _game?.pauseEngine();
    _isPaused = true;
    telemetry.track(SignalReefTelemetryEvents.pauseOpen());
    notifyListeners();
  }

  void resume() {
    if (!_isPaused) {
      return;
    }

    _game?.resumeEngine();
    _isPaused = false;
    telemetry.track(SignalReefTelemetryEvents.pauseResume());
    notifyListeners();
  }

  void backHome() {
    _game?.pauseEngine();
    _isPaused = false;
    _screen = SignalReefScreen.home;
    notifyListeners();
  }

  void showSettings() {
    _screen = SignalReefScreen.settings;
    notifyListeners();
  }

  void toggleSound(bool value) {
    _saveData = _saveData.copyWith(soundEnabled: value);
    telemetry.track(
      SignalReefTelemetryEvents.settingsChanged(
        setting: 'sound',
        enabled: value,
      ),
    );
    _save();
    notifyListeners();
  }

  void toggleMusic(bool value) {
    _saveData = _saveData.copyWith(musicEnabled: value);
    telemetry.track(
      SignalReefTelemetryEvents.settingsChanged(
        setting: 'music',
        enabled: value,
      ),
    );
    _save();
    notifyListeners();
  }

  void toggleHaptics(bool value) {
    _saveData = _saveData.copyWith(hapticsEnabled: value);
    telemetry.track(
      SignalReefTelemetryEvents.settingsChanged(
        setting: 'haptics',
        enabled: value,
      ),
    );
    _save();
    notifyListeners();
  }

  void _finishRun(SignalReefRunResult result) {
    final bestScore = result.score > _saveData.bestScore
        ? result.score
        : _saveData.bestScore;
    final updatedBest = bestScore != _saveData.bestScore;

    _lastResult = result;
    _saveData = _saveData.copyWith(
      bestScore: bestScore,
      runsPlayed: _saveData.runsPlayed + 1,
    );
    _screen = SignalReefScreen.result;
    _isPaused = false;

    if (updatedBest) {
      telemetry.track(
        SignalReefTelemetryEvents.bestScoreUpdated(bestScore: bestScore),
      );
    }

    _save();
    notifyListeners();
  }

  void _save() {
    unawaited(saveStore.save(_saveData));
  }
}
