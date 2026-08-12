import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../data/debug_game_events.dart';
import '../data/game_ads.dart';
import '../data/game_analytics.dart';
import '../data/game_progress_store.dart';
import '../data/level_library.dart';
import '../domain/game_events.dart';
import '../domain/game_model.dart';
import '../domain/marble_run_game_engine.dart';
import 'game_feedback.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    this.initialLevelIndex = 0,
    this.progressStore,
    this.analytics,
    this.ads,
    super.key,
  });

  final int initialLevelIndex;
  final GameProgressStore? progressStore;
  final GameAnalytics? analytics;
  final GameAdService? ads;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late MarbleRunGameEngine _engine;
  late final Ticker _ticker;
  late int _levelIndex;

  final GameFeedbackController _feedback = GameFeedbackController();
  final List<_VisualEffect> _effects = <_VisualEffect>[];

  late final GameProgressStore _progressStore;
  late final GameAnalytics _analytics;
  late final GameAdService _ads;
  GameProgress _progress = GameProgress.initial();
  GameFeedbackSettings _feedbackSettings = const GameFeedbackSettings();
  _GameOverlayMode _overlayMode = _GameOverlayMode.none;
  Duration? _lastTick;
  double _sceneTime = 0;

  bool get _isMenuOpen => _overlayMode != _GameOverlayMode.none;

  @override
  void initState() {
    super.initState();
    _progressStore =
        widget.progressStore ?? const MethodChannelGameProgressStore();
    _analytics = widget.analytics ?? const NoopGameAnalytics();
    _ads = widget.ads ?? const NoopGameAdService();
    _levelIndex = widget.initialLevelIndex
        .clamp(0, v1Levels.length - 1)
        .toInt();
    _engine = _createEngine();
    unawaited(_analytics.logScreenView('game_level'));
    unawaited(_ads.preloadInterstitial());
    _loadProgress();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  MarbleRunGameEngine _createEngine() {
    return MarbleRunGameEngine(
      level: v1Levels[_levelIndex],
      levelCount: v1Levels.length,
      onEvent: _handleGameEvent,
    );
  }

  void _tick(Duration elapsed) {
    final lastTick = _lastTick;
    _lastTick = elapsed;
    if (lastTick == null) {
      if (mounted) {
        setState(() {});
      }
      return;
    }

    final dt =
        ((elapsed.inMicroseconds - lastTick.inMicroseconds) /
                Duration.microsecondsPerSecond)
            .clamp(0.0, 0.05)
            .toDouble();

    _sceneTime += dt;
    if (!_isMenuOpen && _engine.phase == GamePhase.playing) {
      _engine.update(dt);
    }
    _tickEffects(dt);

    if (mounted) {
      setState(() {});
    }
  }

  void _handleGameEvent(String name, Map<String, Object?> properties) {
    debugGameEventSink(name, properties);
    final snapshot = _engine.snapshot;
    unawaited(
      _analytics.logEvent(name, {
        ...properties,
        'level_name': snapshot.levelName,
        'phase': snapshot.phase.name,
        'reserve_count': snapshot.reserveCount,
        'active_count': snapshot.activeCount,
        'enemy_strength': snapshot.enemyStrength,
        'elapsed_seconds': snapshot.elapsedSeconds.round(),
      }),
    );

    switch (name) {
      case GameEventNames.levelStart:
        _feedback.validAction();
        _addEffect(
          _VisualEffect(
            position: Offset(_engine.launcherX, gameWorldSize.height - 68),
            label: 'Launch',
            color: const Color(0xFF2563EB),
          ),
        );
        break;
      case GameEventNames.gateSelected:
        _handleGateFeedback(properties);
        break;
      case GameEventNames.enemyCollision:
        _feedback.collision();
        _handleEnemyHitFeedback(properties);
        break;
      case GameEventNames.enemyCleared:
        _feedback.reward();
        _handleEnemyClearedFeedback(properties);
        break;
      case GameEventNames.reserveEmpty:
        _feedback.invalidAction();
        _addEffect(
          _VisualEffect(
            position: Offset(_engine.launcherX, gameWorldSize.height - 72),
            label: 'Empty',
            color: const Color(0xFFEF4444),
          ),
        );
        break;
      case GameEventNames.levelWin:
        _feedback.win();
        _addEffect(
          _VisualEffect(
            position: Offset(180, 138),
            label: 'Clear',
            color: const Color(0xFF10B981),
            duration: 1,
          ),
        );
        unawaited(_recordWin());
        break;
      case GameEventNames.levelLose:
        _feedback.loss();
        _addEffect(
          _VisualEffect(
            position: Offset(180, 160),
            label: 'Retry',
            color: const Color(0xFFEF4444),
            duration: 1,
          ),
        );
        break;
    }
  }

  void _handleGateFeedback(Map<String, Object?> properties) {
    final gateId = _stringProperty(properties, 'gate_id');
    final gate = _gateById(gateId);
    final before = _intProperty(properties, 'before');
    final after = _intProperty(properties, 'after');
    final effect = _stringProperty(properties, 'effect') ?? 'Gate';
    final delta = after - before;

    final color = delta < 0
        ? const Color(0xFFEF4444)
        : delta > 0
        ? const Color(0xFF10B981)
        : const Color(0xFF2563EB);
    final label = delta == 0
        ? effect
        : delta > 0
        ? '+$delta'
        : '$delta';

    if (delta < 0) {
      _feedback.invalidAction();
    } else if (delta > 0) {
      _feedback.reward();
    } else {
      _feedback.validAction();
    }

    _addEffect(
      _VisualEffect(
        position: gate?.center ?? Offset(_engine.launcherX, 420),
        label: label,
        color: color,
      ),
    );
  }

  void _handleEnemyHitFeedback(Map<String, Object?> properties) {
    final enemyId = _stringProperty(properties, 'enemy_id');
    final enemy = _enemyById(enemyId);
    final before = _intProperty(properties, 'before_enemy');
    final after = _intProperty(properties, 'after_enemy');
    final damage = math.max(0, before - after);

    _addEffect(
      _VisualEffect(
        position: enemy?.center ?? const Offset(180, 180),
        label: damage > 0 ? '-$damage' : 'Hit',
        color: const Color(0xFFFB7185),
      ),
    );
  }

  void _handleEnemyClearedFeedback(Map<String, Object?> properties) {
    final enemyId = _stringProperty(properties, 'enemy_id');
    final enemy = _enemyById(enemyId);

    _addEffect(
      _VisualEffect(
        position: enemy?.center ?? const Offset(180, 180),
        label: 'Cleared',
        color: const Color(0xFF10B981),
      ),
    );
  }

  Future<void> _loadProgress() async {
    final progress = await _progressStore.load(levelCount: v1Levels.length);
    if (!mounted) {
      return;
    }

    setState(() {
      _progress = progress;
      final maxUnlockedIndex = progress.unlockedLevelNumber - 1;
      if (_levelIndex > maxUnlockedIndex) {
        _levelIndex = maxUnlockedIndex;
        _lastTick = null;
        _effects.clear();
        _engine = _createEngine();
      }
    });
  }

  Future<void> _recordWin() async {
    final snapshot = _engine.snapshot;
    final nextProgress = _progress.recordWin(
      levelNumber: snapshot.levelNumber,
      score: snapshot.score,
      stars: snapshot.stars,
      levelCount: v1Levels.length,
    );

    if (mounted) {
      setState(() => _progress = nextProgress);
    } else {
      _progress = nextProgress;
    }

    await _progressStore.save(nextProgress);
    await _analytics.logEvent('progress_saved', {
      'level_number': snapshot.levelNumber,
      'unlocked_level_number': nextProgress.unlockedLevelNumber,
      'score': snapshot.score,
      'stars': snapshot.stars,
      'total_stars': nextProgress.totalStars,
    });
  }

  void _restart() {
    _feedback.tap();
    setState(() {
      _overlayMode = _GameOverlayMode.none;
      _lastTick = null;
      _effects.clear();
      _engine.restart();
    });
  }

  void _nextLevel() {
    if (_levelIndex >= v1Levels.length - 1) {
      return;
    }

    _feedback.tap();
    setState(() {
      _levelIndex += 1;
      _overlayMode = _GameOverlayMode.none;
      _lastTick = null;
      _effects.clear();
      _engine = _createEngine();
      unawaited(_analytics.logScreenView('game_level'));
    });
  }

  Future<void> _restartAfterResult() {
    return _ads.showLevelEndInterstitial(
      snapshot: _engine.snapshot,
      afterAd: _restart,
    );
  }

  Future<void> _nextLevelAfterResult() {
    return _ads.showLevelEndInterstitial(
      snapshot: _engine.snapshot,
      afterAd: _nextLevel,
    );
  }

  Future<void> _goHomeAfterResult() {
    return _ads.showLevelEndInterstitial(
      snapshot: _engine.snapshot,
      afterAd: _goHome,
    );
  }

  void _openOverlay(_GameOverlayMode mode) {
    if (_engine.snapshot.isFinished) {
      return;
    }

    _feedback.tap();
    unawaited(
      _analytics.logEvent('game_overlay_open', {
        'overlay': mode.name,
        'level_number': _engine.snapshot.levelNumber,
      }),
    );
    setState(() {
      _engine.setLaunching(false);
      _overlayMode = mode;
    });
  }

  void _resumeGame() {
    _feedback.tap();
    setState(() => _overlayMode = _GameOverlayMode.none);
  }

  void _goHome() {
    _feedback.tap();
    Navigator.of(context).maybePop();
  }

  void _setSoundEnabled(bool value) {
    final next = _feedbackSettings.copyWith(soundEnabled: value);
    unawaited(
      _analytics.logEvent('settings_changed', {
        'setting': 'sound',
        'enabled': value,
      }),
    );
    setState(() {
      _feedbackSettings = next;
      _feedback.update(next);
    });
  }

  void _setHapticsEnabled(bool value) {
    final next = _feedbackSettings.copyWith(hapticsEnabled: value);
    unawaited(
      _analytics.logEvent('settings_changed', {
        'setting': 'haptics',
        'enabled': value,
      }),
    );
    setState(() {
      _feedbackSettings = next;
      _feedback.update(next);
    });
  }

  void _startLaunch(Offset localPosition, Size size) {
    if (_isMenuOpen || _engine.snapshot.isFinished) {
      _invalidAction('Use the menu buttons');
      return;
    }

    if (!_isInsideWorld(localPosition, size)) {
      _invalidAction('Drag inside the lane');
      return;
    }

    if (_engine.reserveCount <= 0 && _engine.activeCount <= 0) {
      _invalidAction('No marbles left');
      return;
    }

    setState(() {
      _updateLauncher(localPosition, size);
      _engine.setLaunching(true);
    });
  }

  void _updateLaunch(Offset localPosition, Size size) {
    if (_isMenuOpen || _engine.snapshot.isFinished) {
      return;
    }

    setState(() => _updateLauncher(localPosition, size));
  }

  void _stopLaunch() {
    if (_engine.isLaunching) {
      setState(() => _engine.setLaunching(false));
    }
  }

  void _invalidAction(String message) {
    _engine.showMessage(message);
    _feedback.invalidAction();
    _addEffect(
      _VisualEffect(
        position: Offset(_engine.launcherX, gameWorldSize.height - 72),
        label: 'No',
        color: const Color(0xFFEF4444),
      ),
    );
    setState(() {});
  }

  void _updateLauncher(Offset localPosition, Size size) {
    _engine.setLauncherX(_worldXForLocal(localPosition, size));
  }

  bool _isInsideWorld(Offset localPosition, Size size) {
    return _worldRectInLocal(size).inflate(12).contains(localPosition);
  }

  double _worldXForLocal(Offset localPosition, Size size) {
    final rect = _worldRectInLocal(size);
    final scale = rect.width / gameWorldSize.width;
    return ((localPosition.dx - rect.left) / math.max(scale, 0.001))
        .clamp(0.0, gameWorldSize.width)
        .toDouble();
  }

  Rect _worldRectInLocal(Size size) {
    final scale = math.min(
      size.width / gameWorldSize.width,
      size.height / gameWorldSize.height,
    );
    final width = gameWorldSize.width * scale;
    final height = gameWorldSize.height * scale;
    return Rect.fromLTWH(
      (size.width - width) / 2,
      (size.height - height) / 2,
      width,
      height,
    );
  }

  void _addEffect(_VisualEffect effect) {
    _effects.add(effect);
    if (_effects.length > 14) {
      _effects.removeAt(0);
    }
  }

  void _tickEffects(double dt) {
    for (final effect in _effects) {
      effect.age += dt;
    }
    _effects.removeWhere((effect) => effect.isDone);
  }

  GateDefinition? _gateById(String? id) {
    if (id == null) {
      return null;
    }

    for (final gate in _engine.level.gates) {
      if (gate.id == id) {
        return gate;
      }
    }
    return null;
  }

  EnemyDefinition? _enemyById(String? id) {
    if (id == null) {
      return null;
    }

    for (final enemy in _engine.level.enemies) {
      if (enemy.id == id) {
        return enemy;
      }
    }
    return null;
  }

  int _intProperty(Map<String, Object?> properties, String key) {
    final value = properties[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  String? _stringProperty(Map<String, Object?> properties, String key) {
    final value = properties[key];
    return value is String ? value : null;
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _engine.snapshot;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              snapshot: snapshot,
              onMenu: () => _openOverlay(_GameOverlayMode.pause),
              onRestart: _restart,
            ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: gameWorldSize.width / gameWorldSize.height,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Listener(
                            behavior: HitTestBehavior.opaque,
                            onPointerDown: (event) =>
                                _startLaunch(event.localPosition, size),
                            onPointerMove: (event) =>
                                _updateLaunch(event.localPosition, size),
                            onPointerUp: (_) => _stopLaunch(),
                            onPointerCancel: (_) => _stopLaunch(),
                            child: CustomPaint(
                              painter: _GamePainter(
                                _engine,
                                effects: List<_VisualEffect>.unmodifiable(
                                  _effects,
                                ),
                                sceneTime: _sceneTime,
                                isMenuOpen: _isMenuOpen,
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                          if (snapshot.phase == GamePhase.ready && !_isMenuOpen)
                            _StartHintOverlay(snapshot: snapshot),
                          if (_overlayMode == _GameOverlayMode.pause)
                            _PauseOverlay(
                              snapshot: snapshot,
                              onResume: _resumeGame,
                              onRestart: _restart,
                              onHelp: () => _openOverlay(_GameOverlayMode.help),
                              onSettings: () =>
                                  _openOverlay(_GameOverlayMode.settings),
                              onHome: _goHome,
                            ),
                          if (_overlayMode == _GameOverlayMode.help)
                            _HelpOverlay(
                              onBack: () =>
                                  _openOverlay(_GameOverlayMode.pause),
                              onResume: _resumeGame,
                            ),
                          if (_overlayMode == _GameOverlayMode.settings)
                            _SettingsOverlay(
                              settings: _feedbackSettings,
                              onSoundChanged: _setSoundEnabled,
                              onHapticsChanged: _setHapticsEnabled,
                              onBack: () =>
                                  _openOverlay(_GameOverlayMode.pause),
                              onResume: _resumeGame,
                            ),
                          if (snapshot.isFinished)
                            _ResultOverlay(
                              snapshot: snapshot,
                              onRestart: _restartAfterResult,
                              onNext: snapshot.hasNextLevel
                                  ? _nextLevelAfterResult
                                  : null,
                              onHome: _goHomeAfterResult,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _GameOverlayMode { none, pause, help, settings }

class _VisualEffect {
  _VisualEffect({
    required this.position,
    required this.label,
    required this.color,
    this.duration = 0.72,
  });

  final Offset position;
  final String label;
  final Color color;
  final double duration;

  double get progress => (age / duration).clamp(0.0, 1.0).toDouble();
  bool get isDone => age >= duration;

  double age = 0;
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.snapshot,
    required this.onMenu,
    required this.onRestart,
  });

  final GameSnapshot snapshot;
  final VoidCallback onMenu;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          IconButton.filledTonal(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HudChip(
                  label: 'Level',
                  value: '${snapshot.levelNumber}/${snapshot.levelCount}',
                ),
                _HudChip(label: 'Reserve', value: '${snapshot.reserveCount}'),
                _HudChip(label: 'Crowd', value: '${snapshot.activeCount}'),
                _HudChip(label: 'Enemy', value: '${snapshot.enemyStrength}'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            key: const ValueKey('game-menu-button'),
            tooltip: 'Menu',
            onPressed: onMenu,
            icon: const Icon(Icons.pause_rounded),
          ),
          const SizedBox(width: 6),
          IconButton.filled(
            tooltip: 'Restart',
            onPressed: onRestart,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartHintOverlay extends StatelessWidget {
  const _StartHintOverlay({required this.snapshot});

  final GameSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.levelName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Hold and drag to launch',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Steer through one gate, grow the crowd, then outnumber every cluster.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({
    required this.snapshot,
    required this.onResume,
    required this.onRestart,
    required this.onHelp,
    required this.onSettings,
    required this.onHome,
  });

  final GameSnapshot snapshot;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onHelp;
  final VoidCallback onSettings;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return _OverlayShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.pause_circle_filled_rounded,
            color: Color(0xFF2563EB),
            size: 48,
          ),
          const SizedBox(height: 10),
          Text(
            snapshot.phase == GamePhase.ready ? 'Game menu' : 'Paused',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Level ${snapshot.levelNumber}: ${snapshot.levelName}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          _WideButton(
            child: FilledButton.icon(
              key: const ValueKey('resume-button'),
              onPressed: onResume,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Resume'),
            ),
          ),
          const SizedBox(height: 10),
          _WideButton(
            child: OutlinedButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Restart'),
            ),
          ),
          const SizedBox(height: 10),
          _WideButton(
            child: OutlinedButton.icon(
              key: const ValueKey('help-button'),
              onPressed: onHelp,
              icon: const Icon(Icons.help_outline_rounded),
              label: const Text('Help'),
            ),
          ),
          const SizedBox(height: 10),
          _WideButton(
            child: OutlinedButton.icon(
              key: const ValueKey('settings-button'),
              onPressed: onSettings,
              icon: const Icon(Icons.settings_rounded),
              label: const Text('Settings'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onHome,
            icon: const Icon(Icons.home_rounded),
            label: const Text('Home'),
          ),
        ],
      ),
    );
  }
}

class _HelpOverlay extends StatelessWidget {
  const _HelpOverlay({required this.onBack, required this.onResume});

  final VoidCallback onBack;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return _OverlayShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'How to play',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          const _RuleRow(
            icon: Icons.touch_app_rounded,
            title: 'Hold anywhere',
            body: 'Drag sideways in the lane to steer the stream.',
          ),
          const _RuleRow(
            icon: Icons.call_split_rounded,
            title: 'Pick one gate',
            body: 'Green and blue grow the crowd. Red drains it.',
          ),
          const _RuleRow(
            icon: Icons.bubble_chart_rounded,
            title: 'Beat the number',
            body: 'Reach each cluster with enough marbles left.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onResume,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Resume'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsOverlay extends StatelessWidget {
  const _SettingsOverlay({
    required this.settings,
    required this.onSoundChanged,
    required this.onHapticsChanged,
    required this.onBack,
    required this.onResume,
  });

  final GameFeedbackSettings settings;
  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onHapticsChanged;
  final VoidCallback onBack;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return _OverlayShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            key: const ValueKey('sound-toggle'),
            value: settings.soundEnabled,
            onChanged: onSoundChanged,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Sound effects',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text('Taps, gates, results'),
          ),
          SwitchListTile(
            key: const ValueKey('haptics-toggle'),
            value: settings.hapticsEnabled,
            onChanged: onHapticsChanged,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Haptics',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text('Launches, hits, wins, losses'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onResume,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Resume'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay({
    required this.snapshot,
    required this.onRestart,
    required this.onNext,
    required this.onHome,
  });

  final GameSnapshot snapshot;
  final VoidCallback onRestart;
  final VoidCallback? onNext;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final won = snapshot.phase == GamePhase.won;

    return _OverlayShell(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        tween: Tween<double>(begin: 0.92, end: 1),
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              won ? Icons.check_circle_rounded : Icons.error_rounded,
              color: won ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              size: 50,
            ),
            const SizedBox(height: 12),
            Text(
              won ? 'Level clear' : 'Level lost',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            if (won) _StarRow(stars: snapshot.stars),
            const SizedBox(height: 8),
            Text(
              won
                  ? 'Score ${snapshot.score}'
                  : snapshot.message.isEmpty
                  ? 'Try a stronger gate route.'
                  : snapshot.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Retry'),
                ),
                if (onNext != null)
                  FilledButton.icon(
                    onPressed: onNext,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Next'),
                  ),
                TextButton.icon(
                  onPressed: onHome,
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Home'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverlayShell extends StatelessWidget {
  const _OverlayShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.56),
        child: Center(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 330),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WideButton extends StatelessWidget {
  const _WideButton({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: double.infinity, child: child);
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final filled = index < stars;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          color: filled ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
          size: 30,
        );
      }),
    );
  }
}

class _GamePainter extends CustomPainter {
  _GamePainter(
    this.engine, {
    required this.effects,
    required this.sceneTime,
    required this.isMenuOpen,
  });

  final MarbleRunGameEngine engine;
  final List<_VisualEffect> effects;
  final double sceneTime;
  final bool isMenuOpen;

  static const _marbleColors = [
    Color(0xFF38BDF8),
    Color(0xFF34D399),
    Color(0xFFFBBF24),
    Color(0xFFFB7185),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(
      size.width / gameWorldSize.width,
      size.height / gameWorldSize.height,
    );
    final offset = Offset(
      (size.width - gameWorldSize.width * scale) / 2,
      (size.height - gameWorldSize.height * scale) / 2,
    );

    canvas
      ..save()
      ..translate(offset.dx, offset.dy)
      ..scale(scale);

    _drawBackground(canvas);
    _drawFinish(canvas);
    _drawGates(canvas);
    _drawEnemies(canvas);
    _drawMarbles(canvas);
    _drawLauncher(canvas);
    _drawEffects(canvas);
    _drawMessage(canvas);

    canvas.restore();
  }

  void _drawBackground(Canvas canvas) {
    final worldRect = Offset.zero & gameWorldSize;
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFDCFCE7), Color(0xFFE0F2FE), Color(0xFFFFF7ED)],
      ).createShader(worldRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(worldRect, const Radius.circular(18)),
      paint,
    );

    final lanePaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.08)
      ..strokeWidth = 2;
    for (final x in const [72.0, 144.0, 216.0, 288.0]) {
      canvas.drawLine(Offset(x, 56), Offset(x, 660), lanePaint);
    }

    final guidePaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(26, 72, 308, 568),
        const Radius.circular(16),
      ),
      guidePaint,
    );
  }

  void _drawFinish(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF0F172A);
    final rect = Rect.fromLTWH(54, engine.level.finishY - 8, 252, 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      paint,
    );
    _drawCenteredText(
      canvas,
      'FINISH',
      rect.center,
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.w900,
    );
  }

  void _drawGates(Canvas canvas) {
    for (final gate in engine.level.gates) {
      final used = engine.triggeredGateIds.contains(gate.id);
      final applied = engine.appliedGateIds.contains(gate.id);
      final color = switch (gate.effect.kind) {
        GateKind.add => const Color(0xFF22C55E),
        GateKind.multiply => const Color(0xFF2563EB),
        GateKind.subtract => const Color(0xFFEF4444),
        GateKind.wide => const Color(0xFFF59E0B),
        GateKind.tight => const Color(0xFF14B8A6),
      };
      final rect = gate.bounds;
      final alpha = used ? (applied ? 0.42 : 0.16) : 0.92;
      final paint = Paint()..color = color.withValues(alpha: alpha);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(3), const Radius.circular(6)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = applied ? 4 : 2
          ..color = Colors.white.withValues(alpha: applied ? 0.94 : 0.76),
      );
      if (!used && gate.choiceGroup != null) {
        canvas.drawCircle(
          gate.center.translate(0, rect.height / 2 + 12),
          4,
          Paint()..color = Colors.white.withValues(alpha: 0.85),
        );
      }
      _drawCenteredText(
        canvas,
        gate.effect.label,
        gate.center,
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w900,
      );
    }
  }

  void _drawEnemies(Canvas canvas) {
    for (final enemy in engine.enemyStates) {
      final rect = enemy.definition.bounds;
      if (enemy.defeated) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8)),
          Paint()..color = const Color(0xFF64748B).withValues(alpha: 0.18),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.deflate(4), const Radius.circular(6)),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = const Color(0xFF10B981).withValues(alpha: 0.6),
        );
        continue;
      }

      final enemyColor = switch (enemy.definition.shape) {
        EnemyShape.cluster => const Color(0xFFBE123C),
        EnemyShape.wideLine => const Color(0xFF9F1239),
        EnemyShape.narrowBlock => const Color(0xFF7F1D1D),
      };
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()..color = enemyColor,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(4), const Radius.circular(6)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.46),
      );
      canvas.drawCircle(
        enemy.definition.center,
        26,
        Paint()..color = const Color(0xFFFFE4E6),
      );
      _drawCenteredText(
        canvas,
        '${enemy.remainingStrength}',
        enemy.definition.center,
        color: const Color(0xFF881337),
        fontSize: 24,
        fontWeight: FontWeight.w900,
      );
    }
  }

  void _drawMarbles(Canvas canvas) {
    for (final unit in engine.units) {
      final color = _marbleColors[unit.id % _marbleColors.length];
      canvas.drawCircle(
        unit.position.translate(1.4, 2),
        5.8,
        Paint()..color = Colors.black.withValues(alpha: 0.12),
      );
      canvas.drawCircle(unit.position, 5.8, Paint()..color = color);
      canvas.drawCircle(
        unit.position.translate(-1.8, -1.8),
        1.8,
        Paint()..color = Colors.white.withValues(alpha: 0.7),
      );
    }
  }

  void _drawLauncher(Canvas canvas) {
    final launcher = Offset(engine.launcherX, gameWorldSize.height - 42);
    final pulse =
        (engine.phase == GamePhase.ready || engine.isLaunching) && !isMenuOpen
        ? (math.sin(sceneTime * 5.2) + 1) / 2
        : 0.0;
    if (pulse > 0) {
      canvas.drawCircle(
        launcher,
        29 + pulse * 8,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(
            0xFF2563EB,
          ).withValues(alpha: 0.26 * (1 - pulse * 0.5)),
      );
    }
    canvas.drawLine(
      launcher.translate(0, -22),
      Offset(engine.launcherX, 560),
      Paint()
        ..color = const Color(0xFF1E293B).withValues(alpha: 0.18)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(launcher, 24, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(launcher, 14, Paint()..color = const Color(0xFF93C5FD));
    canvas.drawCircle(
      launcher.translate(-4, -5),
      4,
      Paint()..color = Colors.white.withValues(alpha: 0.74),
    );
  }

  void _drawEffects(Canvas canvas) {
    for (final effect in effects) {
      final progress = effect.progress;
      final alpha = (1 - progress).clamp(0.0, 1.0).toDouble();
      final position = effect.position.translate(0, -20 * progress);
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 - progress
        ..color = effect.color.withValues(alpha: 0.74 * alpha);
      canvas.drawCircle(effect.position, 14 + 28 * progress, ringPaint);

      final painter = TextPainter(
        text: TextSpan(
          text: effect.label,
          style: TextStyle(
            color: effect.color.withValues(alpha: alpha),
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: 120);

      final bubble = Rect.fromCenter(
        center: position.translate(0, -28),
        width: painter.width + 20,
        height: painter.height + 10,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bubble, const Radius.circular(8)),
        Paint()..color = Colors.white.withValues(alpha: 0.82 * alpha),
      );
      painter.paint(
        canvas,
        Offset(
          bubble.center.dx - painter.width / 2,
          bubble.center.dy - painter.height / 2,
        ),
      );
    }
  }

  void _drawMessage(Canvas canvas) {
    final message = engine.lastMessage;
    if (message.isEmpty) {
      return;
    }

    final center = Offset(gameWorldSize.width / 2, 92);
    final painter = TextPainter(
      text: TextSpan(
        text: message,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: 260);

    final bubble = Rect.fromCenter(
      center: center,
      width: painter.width + 28,
      height: painter.height + 16,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bubble, const Radius.circular(8)),
      Paint()..color = Colors.white.withValues(alpha: 0.88),
    );
    painter.paint(
      canvas,
      center.translate(-painter.width / 2, -painter.height / 2),
    );
  }

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Offset center, {
    required Color color,
    required double fontSize,
    required FontWeight fontWeight,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center.translate(-painter.width / 2, -painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _GamePainter oldDelegate) {
    return true;
  }
}
