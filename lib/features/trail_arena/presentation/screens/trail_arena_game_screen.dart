import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../data/local_save_store.dart';
import '../../domain/arena_difficulty_phase.dart';
import '../../domain/game_feedback_event.dart';
import '../../domain/game_settings.dart';
import '../../domain/run_state.dart';
import '../../domain/trail_goal.dart';
import '../../domain/vector2.dart';
import '../../game/trail_arena_game.dart';
import '../../services/ad_mob_service.dart';
import '../../services/analytics_sink.dart';
import '../../services/feedback_service.dart';
import '../widgets/ad_banner_slot.dart';
import '../painters/trail_arena_painter.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/help_overlay.dart';
import '../widgets/hud_overlay.dart';
import '../widgets/menu_overlay.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/settings_overlay.dart';

class TrailArenaGameScreen extends StatefulWidget {
  const TrailArenaGameScreen({
    super.key,
    required this.analytics,
    required this.ads,
  });

  final AnalyticsSink analytics;
  final AdMobService ads;

  @override
  State<TrailArenaGameScreen> createState() => _TrailArenaGameScreenState();
}

class _TrailArenaGameScreenState extends State<TrailArenaGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _saveStore = LocalSaveStore();
  final _feedbackService = const FeedbackService();
  final List<_ArenaCue> _arenaCues = <_ArenaCue>[];

  late final TrailArenaGame _game;
  late final Ticker _ticker;
  Duration? _lastTick;
  Offset? _dragOrigin;
  Offset? _dragCurrent;
  bool _steeringEngaged = false;
  bool _savedCurrentRun = false;
  bool _showSettings = false;
  bool _showHelp = false;
  bool _transitioningFromGameOver = false;
  int _lastHandledEventId = 0;
  int _cueId = 0;
  GameSettings _settings = GameSettings.defaults;
  Set<String> _completedGoalIds = <String>{};
  List<TrailGoalDefinition> _newlyCompletedGoals = <TrailGoalDefinition>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _game = TrailArenaGame(analytics: widget.analytics);
    _game.addListener(_handleGameFeedback);
    _ticker = createTicker(_tick)..start();
    _loadSave();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _game.removeListener(_handleGameFeedback);
    _ticker.dispose();
    widget.ads.dispose();
    _game.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _game.pause();
      _clearDrag();
    }
  }

  Future<void> _loadSave() async {
    final save = await _saveStore.load();
    if (!mounted) {
      return;
    }
    final validGoalIds = TrailGoalCatalog.goals.map((goal) => goal.id).toSet();
    setState(() {
      _settings = save.settings;
      _completedGoalIds = save.completedGoalIds.intersection(validGoalIds);
    });
    _game.hydrateSave(bestScore: save.bestScore, gamesPlayed: save.gamesPlayed);
  }

  void _tick(Duration elapsed) {
    final previous = _lastTick;
    _lastTick = elapsed;
    if (previous == null) {
      return;
    }
    final dt =
        (elapsed - previous).inMicroseconds / Duration.microsecondsPerSecond;
    _game.update(dt);
    if (_game.isGameOver && !_savedCurrentRun) {
      _saveCompletedRun();
    }
  }

  void _startRun() {
    _playFeedback(FeedbackCue.tap);
    _savedCurrentRun = false;
    _newlyCompletedGoals = <TrailGoalDefinition>[];
    _lastTick = null;
    _clearDrag();
    _game.startRun();
  }

  void _pauseGame() {
    _playFeedback(FeedbackCue.tap);
    _clearDrag();
    _game.pause();
    widget.analytics.log('game_pause_button', {
      'duration_seconds': _game.elapsedSeconds.floor(),
      'score': _game.score,
    });
  }

  void _resumeGame() {
    _playFeedback(FeedbackCue.tap);
    _clearDrag();
    _game.resume();
    widget.analytics.log('game_resume_button', {
      'duration_seconds': _game.elapsedSeconds.floor(),
    });
  }

  void _showMenu() {
    _playFeedback(FeedbackCue.tap);
    _clearDrag();
    _game.showMenu();
    widget.analytics.log('screen_view', {'screen_name': 'main_menu'});
  }

  void _openSettings() {
    _playFeedback(FeedbackCue.tap);
    if (_game.isActive) {
      _game.pause();
    }
    setState(() {
      _showHelp = false;
      _showSettings = true;
    });
    widget.analytics.log('settings_open', {'source_phase': _game.phase.name});
  }

  void _closeSettings() {
    _playFeedback(FeedbackCue.tap);
    setState(() {
      _showSettings = false;
    });
  }

  void _openHelp() {
    _playFeedback(FeedbackCue.tap);
    if (_game.isActive) {
      _game.pause();
    }
    setState(() {
      _showSettings = false;
      _showHelp = true;
    });
    widget.analytics.log('help_open', {'source_phase': _game.phase.name});
  }

  void _closeHelp() {
    _playFeedback(FeedbackCue.tap);
    setState(() {
      _showHelp = false;
    });
  }

  void _updateSettings(GameSettings settings) {
    setState(() {
      _settings = settings;
    });
    unawaited(_saveStore.saveSettings(settings));
    widget.analytics.log('settings_changed', {
      'sound_enabled': settings.soundEnabled,
      'haptics_enabled': settings.hapticsEnabled,
      'control_sensitivity': settings.controlSensitivity,
    });
  }

  void _saveCompletedRun() {
    _savedCurrentRun = true;
    final completedNow = TrailGoalCatalog.newlyCompleted(
      _game.runStats,
      _completedGoalIds,
    );
    final updatedGoalIds = <String>{
      ..._completedGoalIds,
      for (final goal in completedNow) goal.id,
    };
    setState(() {
      _completedGoalIds = updatedGoalIds;
      _newlyCompletedGoals = completedNow;
    });
    widget.ads.recordCompletedRun(_game.runStats);
    for (final goal in completedNow) {
      widget.analytics.log('game_goal_complete', {
        'goal_id': goal.id,
        'goal_metric': goal.metric.name,
        'goal_target': goal.target,
        'score': _game.score,
      });
    }
    unawaited(
      _saveStore.saveRun(score: _game.score, completedGoalIds: updatedGoalIds),
    );
  }

  Future<void> _leaveGameOver(VoidCallback action) async {
    if (_transitioningFromGameOver) {
      return;
    }
    _transitioningFromGameOver = true;
    try {
      await widget.ads.showInterstitialAtTransition(
        runStats: _game.runStats,
        onComplete: () {
          if (!mounted) {
            return;
          }
          _transitioningFromGameOver = false;
          action();
        },
      );
    } catch (error) {
      widget.analytics.log('ad_transition_error', {'error': error.toString()});
      if (!mounted) {
        return;
      }
      _transitioningFromGameOver = false;
      action();
    }
  }

  void _beginDrag(Offset position) {
    if (!_inputEnabled) {
      _playFeedback(FeedbackCue.invalidAction);
      return;
    }
    _dragOrigin = position;
    _dragCurrent = position;
    _steeringEngaged = false;
    _playFeedback(FeedbackCue.tap);
    setState(() {});
  }

  void _steerFromDrag(Offset current) {
    if (!_inputEnabled) {
      return;
    }
    final origin = _dragOrigin;
    if (origin == null) {
      return;
    }
    _dragCurrent = current;
    final delta = current - origin;
    if (delta.distance < _dragDeadZone) {
      setState(() {});
      return;
    }
    if (!_steeringEngaged) {
      _steeringEngaged = true;
      _playFeedback(FeedbackCue.validAction);
    }
    _game.steerPlayer(Vec2(delta.dx, delta.dy));
    setState(() {});
  }

  void _endDrag() {
    _clearDrag();
  }

  void _clearDrag() {
    if (_dragOrigin == null && _dragCurrent == null) {
      return;
    }
    setState(() {
      _dragOrigin = null;
      _dragCurrent = null;
      _steeringEngaged = false;
    });
  }

  void _handleGameFeedback() {
    final event = _game.latestEvent;
    if (event == null || event.id == _lastHandledEventId) {
      return;
    }
    _lastHandledEventId = event.id;

    switch (event.kind) {
      case GameFeedbackKind.runStarted:
        _playFeedback(FeedbackCue.validAction);
      case GameFeedbackKind.foodCollected:
        _playFeedback(FeedbackCue.score);
        _addArenaCue(event, const Color(0xFFFF8A76));
      case GameFeedbackKind.brightFoodCollected:
        _playFeedback(FeedbackCue.reward);
        _addArenaCue(event, const Color(0xFFFFD166));
      case GameFeedbackKind.botCrashed:
        _playFeedback(FeedbackCue.reward);
        _addArenaCue(event, const Color(0xFF65F0B4), label: 'Crash');
      case GameFeedbackKind.playerDied:
        _playFeedback(
          _game.achievedBestThisRun ? FeedbackCue.win : FeedbackCue.loss,
        );
        _addArenaCue(event, const Color(0xFFFF6B6B), label: 'Hit');
    }
  }

  void _addArenaCue(GameFeedbackEvent event, Color color, {String? label}) {
    if (!mounted) {
      return;
    }
    final cue = _ArenaCue(
      id: ++_cueId,
      position: event.position,
      label: label ?? '+${event.scoreDelta}',
      color: color,
    );
    setState(() {
      _arenaCues.add(cue);
    });
  }

  void _removeArenaCue(int id) {
    if (!mounted) {
      return;
    }
    setState(() {
      _arenaCues.removeWhere((cue) => cue.id == id);
    });
  }

  void _playFeedback(FeedbackCue cue) {
    unawaited(_feedbackService.play(cue, _settings));
  }

  bool get _inputEnabled =>
      _game.phase == RunPhase.ready || _game.phase == RunPhase.running;

  double get _dragDeadZone => 18 / _settings.controlSensitivity;

  TrailGoalDefinition? get _activeGoal {
    return TrailGoalCatalog.firstIncomplete(_completedGoalIds);
  }

  List<TrailGoalDefinition> get _nextGoals {
    return TrailGoalCatalog.nextIncomplete(_completedGoalIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101510),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _game,
          builder: (context, _) {
            if (_game.phase == RunPhase.menu) {
              return Stack(
                children: [
                  MenuOverlay(
                    bestScore: _game.bestScore,
                    gamesPlayed: _game.gamesPlayed,
                    completedGoalCount: _completedGoalIds.length,
                    totalGoalCount: TrailGoalCatalog.goals.length,
                    nextGoals: _nextGoals,
                    onPlay: _startRun,
                    onSettings: _openSettings,
                    onHelp: _openHelp,
                    adSlot: _showSettings || _showHelp
                        ? null
                        : AdBannerSlot(
                            analytics: widget.analytics,
                            placement: AdPlacement.menuBanner,
                          ),
                  ),
                  _blockingOverlays(),
                ],
              );
            }

            return Stack(
              children: [
                Column(
                  children: [
                    HudOverlay(
                      score: _game.score,
                      bestScore: _game.bestScore,
                      activeGoal: _activeGoal,
                      runStats: _game.runStats,
                      onPause: _pauseGame,
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final paintSize = _arenaPaintSize(
                            constraints.biggest,
                          );
                          return Center(
                            child: SizedBox(
                              width: paintSize.width,
                              height: paintSize.height,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      ignoring: !_inputEnabled,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onPanDown: (details) {
                                          _beginDrag(details.localPosition);
                                        },
                                        onPanUpdate: (details) {
                                          _steerFromDrag(details.localPosition);
                                        },
                                        onPanEnd: (_) {
                                          _endDrag();
                                        },
                                        onPanCancel: _endDrag,
                                        child: CustomPaint(
                                          painter: TrailArenaPainter(_game),
                                          child: const SizedBox.expand(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  _controlIndicator(),
                                  ..._arenaCueWidgets(paintSize),
                                  if (_game.phase == RunPhase.ready)
                                    _ReadyOverlay(
                                      seconds: _game.readyRemaining,
                                      showHint: _game.gamesPlayed == 0,
                                    ),
                                  if (_game.phase == RunPhase.paused)
                                    PauseOverlay(
                                      onResume: _resumeGame,
                                      onRestart: _startRun,
                                      onMenu: _showMenu,
                                      onSettings: _openSettings,
                                      onHelp: _openHelp,
                                    ),
                                  if (_game.phase == RunPhase.gameOver)
                                    GameOverOverlay(
                                      score: _game.score,
                                      bestScore: _game.bestScore,
                                      deathCause: _game.deathCause,
                                      isNewBest: _game.achievedBestThisRun,
                                      completedGoals: _newlyCompletedGoals,
                                      onRestart: () {
                                        unawaited(_leaveGameOver(_startRun));
                                      },
                                      onMenu: () {
                                        unawaited(_leaveGameOver(_showMenu));
                                      },
                                      adSlot: AdBannerSlot(
                                        analytics: widget.analytics,
                                        placement: AdPlacement.gameOverBanner,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    _FooterHint(
                      isFirstRun: _game.gamesPlayed == 0,
                      isActive: _game.isActive,
                      difficultyLabel: _game.difficultyPhase.label,
                    ),
                  ],
                ),
                _blockingOverlays(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _blockingOverlays() {
    return Positioned.fill(
      child: Stack(
        children: [
          if (_showSettings)
            SettingsOverlay(
              settings: _settings,
              onChanged: _updateSettings,
              onClose: _closeSettings,
            ),
          if (_showHelp) HelpOverlay(onClose: _closeHelp),
        ],
      ),
    );
  }

  Widget _controlIndicator() {
    final origin = _dragOrigin;
    final current = _dragCurrent;
    if (origin == null || current == null) {
      return const SizedBox.shrink();
    }
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _ControlIndicatorPainter(
            origin: origin,
            current: current,
            engaged: _steeringEngaged,
          ),
        ),
      ),
    );
  }

  List<Widget> _arenaCueWidgets(Size paintSize) {
    return [
      for (final cue in _arenaCues)
        _ArenaCueBubble(
          key: ValueKey(cue.id),
          cue: cue,
          position: _worldToLocal(cue.position, paintSize),
          paintSize: paintSize,
          onDone: () {
            _removeArenaCue(cue.id);
          },
        ),
    ];
  }

  Offset _worldToLocal(Vec2 position, Size size) {
    return Offset(
      position.x / TrailArenaGame.arenaWidth * size.width,
      position.y / TrailArenaGame.arenaHeight * size.height,
    );
  }

  Size _arenaPaintSize(Size available) {
    const aspect = TrailArenaGame.arenaWidth / TrailArenaGame.arenaHeight;
    var width = available.width;
    var height = width / aspect;
    if (height > available.height) {
      height = available.height;
      width = height * aspect;
    }
    return Size(width, height);
  }
}

class _ReadyOverlay extends StatelessWidget {
  const _ReadyOverlay({required this.seconds, required this.showHint});

  final double seconds;
  final bool showHint;

  @override
  Widget build(BuildContext context) {
    final label = seconds > 1 ? seconds.ceil().toString() : 'Go';
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.94, end: 1),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xD9142018),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF65F0B4)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    if (showHint) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Drag to steer. Avoid trails.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFB8C9BD),
                          fontSize: 13,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
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

class _FooterHint extends StatelessWidget {
  const _FooterHint({
    required this.isFirstRun,
    required this.isActive,
    required this.difficultyLabel,
  });

  final bool isFirstRun;
  final bool isActive;
  final String difficultyLabel;

  @override
  Widget build(BuildContext context) {
    final text = isFirstRun
        ? 'Drag from anywhere inside the arena'
        : 'Pace: $difficultyLabel - collect seeds and beat your best';
    return AnimatedOpacity(
      opacity: isActive ? 1 : 0.72,
      duration: const Duration(milliseconds: 180),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF9AB5A5),
            fontSize: 12,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _ControlIndicatorPainter extends CustomPainter {
  const _ControlIndicatorPainter({
    required this.origin,
    required this.current,
    required this.engaged,
  });

  final Offset origin;
  final Offset current;
  final bool engaged;

  @override
  void paint(Canvas canvas, Size size) {
    final delta = current - origin;
    final distance = delta.distance;
    final direction = distance == 0 ? Offset.zero : delta / distance;
    final clampedDistance = distance.clamp(0.0, 54.0).toDouble();
    final knob = origin + (direction * clampedDistance);
    final color = engaged ? const Color(0xFF65F0B4) : const Color(0x99FFFFFF);

    canvas.drawCircle(
      origin,
      34,
      Paint()
        ..color = color.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      origin,
      34,
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      origin,
      knob,
      Paint()
        ..color = color.withValues(alpha: 0.8)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(knob, 10, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ControlIndicatorPainter oldDelegate) {
    return oldDelegate.origin != origin ||
        oldDelegate.current != current ||
        oldDelegate.engaged != engaged;
  }
}

class _ArenaCue {
  const _ArenaCue({
    required this.id,
    required this.position,
    required this.label,
    required this.color,
  });

  final int id;
  final Vec2 position;
  final String label;
  final Color color;
}

class _ArenaCueBubble extends StatelessWidget {
  const _ArenaCueBubble({
    super.key,
    required this.cue,
    required this.position,
    required this.paintSize,
    required this.onDone,
  });

  final _ArenaCue cue;
  final Offset position;
  final Size paintSize;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final maxLeft = paintSize.width > 84 ? paintSize.width - 76 : 8.0;
    final maxTop = paintSize.height > 52 ? paintSize.height - 44 : 8.0;
    final left = (position.dx - 34).clamp(8.0, maxLeft).toDouble();
    final top = (position.dy - 50).clamp(8.0, maxTop).toDouble();
    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutCubic,
          onEnd: onDone,
          builder: (context, value, child) {
            final lift = -22 * value;
            final opacity = (1 - value).clamp(0.0, 1.0);
            final scale = 0.85 + (0.25 * (1 - (value - 0.35).abs()));
            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, lift),
                child: Transform.scale(scale: scale, child: child),
              ),
            );
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xDD142018),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cue.color),
              boxShadow: [
                BoxShadow(
                  color: cue.color.withValues(alpha: 0.25),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                cue.label,
                style: TextStyle(
                  color: cue.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
