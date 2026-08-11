import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../data/local_save_store.dart';
import '../../domain/run_state.dart';
import '../../domain/vector2.dart';
import '../../game/trail_arena_game.dart';
import '../painters/trail_arena_painter.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/hud_overlay.dart';
import '../widgets/menu_overlay.dart';
import '../widgets/pause_overlay.dart';

class TrailArenaGameScreen extends StatefulWidget {
  const TrailArenaGameScreen({super.key});

  @override
  State<TrailArenaGameScreen> createState() => _TrailArenaGameScreenState();
}

class _TrailArenaGameScreenState extends State<TrailArenaGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _saveStore = LocalSaveStore();
  late final TrailArenaGame _game;
  late final Ticker _ticker;
  Duration? _lastTick;
  Offset? _dragOrigin;
  bool _savedCurrentRun = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _game = TrailArenaGame();
    _ticker = createTicker(_tick)..start();
    _loadSave();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _game.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _game.pause();
    }
  }

  Future<void> _loadSave() async {
    final save = await _saveStore.load();
    if (!mounted) {
      return;
    }
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
      _savedCurrentRun = true;
      _saveStore.saveRun(score: _game.score);
    }
  }

  void _startRun() {
    _savedCurrentRun = false;
    _lastTick = null;
    _game.startRun();
  }

  void _showMenu() {
    _game.showMenu();
  }

  void _steerFromDrag(Offset current) {
    final origin = _dragOrigin;
    if (origin == null) {
      return;
    }
    final delta = current - origin;
    if (delta.distance < 8) {
      return;
    }
    _game.steerPlayer(Vec2(delta.dx, delta.dy));
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
              return MenuOverlay(
                bestScore: _game.bestScore,
                gamesPlayed: _game.gamesPlayed,
                onPlay: _startRun,
              );
            }

            return Column(
              children: [
                HudOverlay(
                  score: _game.score,
                  bestScore: _game.bestScore,
                  onPause: _game.pause,
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final paintSize = _arenaPaintSize(constraints.biggest);
                      return Center(
                        child: SizedBox(
                          width: paintSize.width,
                          height: paintSize.height,
                          child: Stack(
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onPanStart: (details) {
                                  _dragOrigin = details.localPosition;
                                },
                                onPanUpdate: (details) {
                                  _steerFromDrag(details.localPosition);
                                },
                                onPanEnd: (_) {
                                  _dragOrigin = null;
                                },
                                onPanCancel: () {
                                  _dragOrigin = null;
                                },
                                child: CustomPaint(
                                  painter: TrailArenaPainter(_game),
                                  size: paintSize,
                                ),
                              ),
                              if (_game.phase == RunPhase.ready)
                                _ReadyOverlay(seconds: _game.readyRemaining),
                              if (_game.phase == RunPhase.paused)
                                PauseOverlay(
                                  onResume: _game.resume,
                                  onRestart: _startRun,
                                  onMenu: _showMenu,
                                ),
                              if (_game.phase == RunPhase.gameOver)
                                GameOverOverlay(
                                  score: _game.score,
                                  bestScore: _game.bestScore,
                                  deathCause: _game.deathCause,
                                  onRestart: _startRun,
                                  onMenu: _showMenu,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 14),
                  child: Text(
                    'Offline v1 - drag anywhere in the arena to steer',
                    style: TextStyle(
                      color: Color(0xFF7C9387),
                      fontSize: 12,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
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
  const _ReadyOverlay({required this.seconds});

  final double seconds;

  @override
  Widget build(BuildContext context) {
    final label = seconds > 1 ? seconds.ceil().toString() : 'Go';
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xCC142018),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF65F0B4)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
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
