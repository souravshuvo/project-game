import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../game/cloud_courier_game.dart';
import '../game/components/background_component.dart';
import '../game/models/run_state.dart';
import '../game/world/challenge_catalog.dart';
import '../game/world/world_config.dart';
import '../services/ads_gateway.dart';
import '../services/analytics_service.dart';
import '../services/feedback_service.dart';
import '../services/local_save_service.dart';
import 'overlays/game_over_overlay.dart';
import 'overlays/hud_overlay.dart';
import 'overlays/pause_overlay.dart';
import 'overlays/start_overlay.dart';

enum _MenuPanel { none, help, settings }

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: WorldConfig.gameTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff1d6f78),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final LocalSaveService _localSaveService = const LocalSaveService();
  final AnalyticsService _analyticsService = const AnalyticsService();
  final AdsGateway _adsGateway = AdsGateway();
  final GameFeedbackService _feedbackService = GameFeedbackService();
  final CloudCourierGame _game = CloudCourierGame();

  Duration? _previousTick;
  bool _leftHeld = false;
  bool _rightHeld = false;
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  _MenuPanel _menuPanel = _MenuPanel.none;
  String _cueText = '';
  bool _cueIsAlert = false;
  double _cueSeconds = 0;
  int _lastScoreCue = 0;
  int _lastSavedChallengeSteps = 0;
  bool _rewardedReviveAvailable = false;
  bool _showingRewardedRevive = false;
  DateTime? _runStartedAt;

  int get _inputAxis {
    if (_leftHeld == _rightHeld) {
      return 0;
    }

    return _rightHeld ? 1 : -1;
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadSaveData());
    unawaited(_preloadAds());
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Future<void> _loadSaveData() async {
    final saveData = await _localSaveService.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _game.setBestScore(saveData.bestScore);
      _game.setCompletedChallengeSteps(saveData.completedChallengeSteps);
      _lastSavedChallengeSteps = saveData.completedChallengeSteps;
      _soundEnabled = saveData.soundEnabled;
      _hapticsEnabled = saveData.hapticsEnabled;
      _feedbackService.setEnabled(
        sound: _soundEnabled,
        haptics: _hapticsEnabled,
      );
    });
    _analyticsService.appOpened(
      bestScore: _game.bestScore,
      completedRoutes: _game.completedChallengeSteps,
    );
  }

  Future<void> _preloadAds() async {
    await _adsGateway.preload();
    if (!mounted) {
      return;
    }

    setState(() {
      _rewardedReviveAvailable = _adsGateway.hasRewardedRevive;
    });
  }

  void _onTick(Duration elapsed) {
    final previous = _previousTick;
    _previousTick = elapsed;

    if (previous == null || !_game.hasViewport) {
      return;
    }

    final dt = math.min(
      (elapsed - previous).inMicroseconds / Duration.microsecondsPerSecond,
      WorldConfig.maxFrameStep,
    );

    setState(() {
      _game.tick(dt);
      _cueSeconds = math.max(0, _cueSeconds - dt);
      if (_game.phase == RunPhase.playing) {
        final landingsBefore = _game.landingsThisRun;
        final bestScoreChanged = _game.step(dt, _inputAxis);
        if (_game.lastRunCompletedChallenge &&
            _game.completedChallengeSteps > _lastSavedChallengeSteps) {
          _lastSavedChallengeSteps = _game.completedChallengeSteps;
          _setCue('${_game.displayedChallenge.routeLabel} complete');
          unawaited(_feedbackService.reward());
          _analyticsService.routeCompleted(
            routeNumber: _game.displayedChallenge.number,
            completedRoutes: _game.completedChallengeSteps,
            score: _game.score,
          );
          unawaited(
            _localSaveService.saveCompletedChallengeSteps(
              _game.completedChallengeSteps,
            ),
          );
        }
        if (_game.landingsThisRun > landingsBefore) {
          unawaited(_feedbackService.score());
          _setCue(_game.landingsThisRun == 1 ? 'Good landing' : 'Clean jump');
        }
        final scoreCue = (_game.score ~/ 25) * 25;
        if (scoreCue > _lastScoreCue && scoreCue > 0) {
          _lastScoreCue = scoreCue;
          _setCue('Score $_lastScoreCue');
        }
        if (_game.phase == RunPhase.gameOver) {
          _leftHeld = false;
          _rightHeld = false;
          _setCue(
            bestScoreChanged ? 'New best route' : _game.deathReason.message,
            isAlert: !bestScoreChanged,
          );
          unawaited(
            bestScoreChanged
                ? _feedbackService.reward()
                : _feedbackService.loss(),
          );
          _adsGateway.recordRunEnded();
          _analyticsService.runEnded(
            score: _game.score,
            bestScore: _game.bestScore,
            deathReason: _game.deathReason.name,
            durationSeconds: _runDurationSeconds(),
            landings: _game.landingsThisRun,
            pickups: _game.pickupsThisRun,
            routeNumber: _game.displayedChallenge.number,
            routeCompleted: _game.lastRunCompletedChallenge,
            revivesUsed: _game.revivesThisRun,
          );
          unawaited(
            _maybeShowGameOverInterstitial(
              routeCompleted: _game.lastRunCompletedChallenge,
            ),
          );
        }
        if (bestScoreChanged) {
          unawaited(_localSaveService.saveBestScore(_game.bestScore));
        }
      }
    });
  }

  void _startRun() {
    if (!_game.hasViewport) {
      unawaited(_feedbackService.invalidAction());
      return;
    }

    unawaited(_feedbackService.tap());
    setState(() {
      _leftHeld = false;
      _rightHeld = false;
      _menuPanel = _MenuPanel.none;
      _lastScoreCue = 0;
      if (_game.phase == RunPhase.gameOver) {
        _analyticsService.restartTapped(previousScore: _game.score);
      }
      _analyticsService.runStarted(
        bestScoreBefore: _game.bestScore,
        routeNumber: _game.currentChallenge.number,
        completedRoutes: _game.completedChallengeSteps,
      );
      _game.startRun();
      _runStartedAt = DateTime.now();
      _rewardedReviveAvailable = _adsGateway.hasRewardedRevive;
      _setCue('Climb the sky route');
    });
  }

  void _setLeftHeld(bool value) {
    if (_game.phase != RunPhase.playing && value) {
      unawaited(_feedbackService.invalidAction());
      return;
    }

    if (_leftHeld == value) {
      return;
    }

    if (value) {
      unawaited(_feedbackService.validMove());
    }

    setState(() {
      _leftHeld = value;
    });
  }

  void _setRightHeld(bool value) {
    if (_game.phase != RunPhase.playing && value) {
      unawaited(_feedbackService.invalidAction());
      return;
    }

    if (_rightHeld == value) {
      return;
    }

    if (value) {
      unawaited(_feedbackService.validMove());
    }

    setState(() {
      _rightHeld = value;
    });
  }

  void _pauseRun() {
    if (_game.phase != RunPhase.playing) {
      unawaited(_feedbackService.invalidAction());
      return;
    }

    unawaited(_feedbackService.tap());
    _analyticsService.pauseOpened(score: _game.score);
    setState(() {
      _leftHeld = false;
      _rightHeld = false;
      _menuPanel = _MenuPanel.none;
      _game.pauseRun();
    });
  }

  void _resumeRun() {
    if (_game.phase != RunPhase.paused) {
      unawaited(_feedbackService.invalidAction());
      return;
    }

    unawaited(_feedbackService.tap());
    _analyticsService.resumeTapped(score: _game.score);
    setState(() {
      _menuPanel = _MenuPanel.none;
      _game.resumeRun();
      _setCue('Back on route');
    });
  }

  void _goHome() {
    unawaited(_feedbackService.tap());
    _analyticsService.homeTapped(score: _game.score, phase: _game.phase.name);
    setState(() {
      _leftHeld = false;
      _rightHeld = false;
      _menuPanel = _MenuPanel.none;
      _lastScoreCue = 0;
      _game.resetToMenu();
    });
  }

  void _openHelp() {
    unawaited(_feedbackService.tap());
    _analyticsService.helpOpened(phase: _game.phase.name);
    setState(() {
      _menuPanel = _MenuPanel.help;
    });
  }

  void _openSettings() {
    unawaited(_feedbackService.tap());
    _analyticsService.settingsOpened(phase: _game.phase.name);
    setState(() {
      _menuPanel = _MenuPanel.settings;
    });
  }

  void _closePanel() {
    unawaited(_feedbackService.tap());
    setState(() {
      _menuPanel = _MenuPanel.none;
    });
  }

  void _setSoundEnabled(bool value) {
    setState(() {
      _soundEnabled = value;
      _feedbackService.setEnabled(
        sound: _soundEnabled,
        haptics: _hapticsEnabled,
      );
    });
    unawaited(_feedbackService.tap());
    _analyticsService.feedbackSettingChanged(
      setting: 'sound',
      enabled: _soundEnabled,
    );
    unawaited(
      _localSaveService.saveFeedbackSettings(
        soundEnabled: _soundEnabled,
        hapticsEnabled: _hapticsEnabled,
      ),
    );
  }

  void _setHapticsEnabled(bool value) {
    setState(() {
      _hapticsEnabled = value;
      _feedbackService.setEnabled(
        sound: _soundEnabled,
        haptics: _hapticsEnabled,
      );
    });
    unawaited(_feedbackService.tap());
    _analyticsService.feedbackSettingChanged(
      setting: 'haptics',
      enabled: _hapticsEnabled,
    );
    unawaited(
      _localSaveService.saveFeedbackSettings(
        soundEnabled: _soundEnabled,
        hapticsEnabled: _hapticsEnabled,
      ),
    );
  }

  void _setCue(String text, {bool isAlert = false}) {
    _cueText = text;
    _cueIsAlert = isAlert;
    _cueSeconds = isAlert ? 2.2 : 1.35;
  }

  int _runDurationSeconds() {
    final startedAt = _runStartedAt;
    if (startedAt == null) {
      return 0;
    }

    return DateTime.now().difference(startedAt).inSeconds;
  }

  Future<void> _maybeShowGameOverInterstitial({
    required bool routeCompleted,
  }) async {
    final result = await _adsGateway.maybeShowGameOverInterstitial(
      routeCompleted: routeCompleted,
      canShowNow: () => mounted && _game.phase == RunPhase.gameOver,
    );
    _analyticsService.adEvent(
      format: 'interstitial',
      placement: 'game_over',
      result: result.name,
      runCount: _adsGateway.completedRuns,
      routeCompleted: routeCompleted,
    );
    await _preloadAds();
  }

  Future<void> _tryRewardedRevive() async {
    if (!_game.canRevive ||
        !_rewardedReviveAvailable ||
        _showingRewardedRevive) {
      unawaited(_feedbackService.invalidAction());
      return;
    }

    setState(() {
      _showingRewardedRevive = true;
      _setCue('Opening revive');
    });
    _analyticsService.adEvent(
      format: 'rewarded',
      placement: 'revive',
      result: 'requested',
      runCount: _adsGateway.completedRuns,
      routeCompleted: _game.lastRunCompletedChallenge,
    );

    final result = await _adsGateway.showRewardedRevive();
    _analyticsService.adEvent(
      format: 'rewarded',
      placement: 'revive',
      result: result.name,
      runCount: _adsGateway.completedRuns,
      routeCompleted: _game.lastRunCompletedChallenge,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _showingRewardedRevive = false;
      _rewardedReviveAvailable = _adsGateway.hasRewardedRevive;
      if (result == RewardedAdResult.earned && _game.reviveAfterAd()) {
        _leftHeld = false;
        _rightHeld = false;
        _runStartedAt = DateTime.now();
        _setCue('Revived');
        unawaited(_feedbackService.reward());
      } else {
        _setCue('Revive unavailable', isAlert: true);
        unawaited(_feedbackService.invalidAction());
      }
    });
    unawaited(_preloadAds());
  }

  Widget _buildMenuOverlay() {
    return switch (_menuPanel) {
      _MenuPanel.help => HelpOverlay(onStart: _startRun, onBack: _closePanel),
      _MenuPanel.settings => SettingsOverlay(
        soundEnabled: _soundEnabled,
        hapticsEnabled: _hapticsEnabled,
        onSoundChanged: _setSoundEnabled,
        onHapticsChanged: _setHapticsEnabled,
        onBack: _closePanel,
      ),
      _MenuPanel.none => StartOverlay(
        onStart: _startRun,
        onSettings: _openSettings,
        onHelp: _openHelp,
        routeLabel: _game.currentChallenge.routeLabel,
        routeTitle: _game.currentChallenge.title,
        goalLabel: _game.currentChallenge.goalLabel,
        completedRoutes: _game.completedChallengeSteps,
        totalRoutes: ChallengeCatalog.totalSteps,
      ),
    };
  }

  Widget _buildPauseOverlay() {
    if (_menuPanel == _MenuPanel.settings) {
      return SettingsOverlay(
        soundEnabled: _soundEnabled,
        hapticsEnabled: _hapticsEnabled,
        onSoundChanged: _setSoundEnabled,
        onHapticsChanged: _setHapticsEnabled,
        onBack: _closePanel,
      );
    }

    return PauseOverlay(
      onResume: _resumeRun,
      onRestart: _startRun,
      onSettings: _openSettings,
      onHome: _goHome,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          _game.configureViewport(size);

          return Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(painter: CloudCourierPainter(_game)),
                ),
              ),
              if (_game.phase == RunPhase.playing)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 112,
                  child: SafeArea(
                    top: false,
                    minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      height: 80,
                      child: GameControls(
                        leftHeld: _leftHeld,
                        rightHeld: _rightHeld,
                        onLeftHeld: _setLeftHeld,
                        onRightHeld: _setRightHeld,
                      ),
                    ),
                  ),
                ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: HudOverlay(
                    score: _game.score,
                    bestScore: _game.bestScore,
                    routeLabel: _game.currentChallenge.routeLabel,
                    goalLabel: _game.currentChallenge.goalLabel,
                    progressLabel: _game.challengeProgressLabel,
                    onPause: _game.phase == RunPhase.playing ? _pauseRun : null,
                  ),
                ),
              ),
              if (_cueSeconds > 0 && _cueText.isNotEmpty)
                Positioned(
                  left: 20,
                  right: 20,
                  top: MediaQuery.paddingOf(context).top + 76,
                  child: IgnorePointer(
                    child: _CueBanner(text: _cueText, isAlert: _cueIsAlert),
                  ),
                ),
              if (_game.phase == RunPhase.ready)
                Positioned.fill(child: _buildMenuOverlay()),
              if (_game.phase == RunPhase.gameOver)
                Positioned.fill(
                  child: GameOverOverlay(
                    score: _game.score,
                    bestScore: _game.bestScore,
                    routeLabel: _game.displayedChallenge.routeLabel,
                    routeTitle: _game.displayedChallenge.title,
                    goalLabel: _game.displayedChallenge.goalLabel,
                    progressLabel: _game.challengeProgressLabel,
                    pickups: _game.pickupsThisRun,
                    deathReason: _game.deathReason,
                    isNewBest: _game.lastRunWasNewBest,
                    routeCompleted: _game.lastRunCompletedChallenge,
                    onRestart: _startRun,
                    onHome: _goHome,
                    canRewardedRevive:
                        _rewardedReviveAvailable &&
                        _game.canRevive &&
                        !_showingRewardedRevive,
                    onRewardedRevive: _tryRewardedRevive,
                  ),
                ),
              if (_game.phase == RunPhase.paused)
                Positioned.fill(child: _buildPauseOverlay()),
            ],
          );
        },
      ),
    );
  }
}

class _CueBanner extends StatelessWidget {
  const _CueBanner({required this.text, required this.isAlert});

  final String text;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: (isAlert ? const Color(0xffb82435) : const Color(0xff062d33))
              .withAlpha(218),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xffffcb5b), width: 1.4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
