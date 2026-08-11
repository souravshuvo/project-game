import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../data/debug_game_events.dart';
import '../data/level_library.dart';
import '../domain/game_model.dart';
import '../domain/marble_run_game_engine.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({this.initialLevelIndex = 0, super.key});

  final int initialLevelIndex;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late MarbleRunGameEngine _engine;
  late final Ticker _ticker;
  late int _levelIndex;
  Duration? _lastTick;

  @override
  void initState() {
    super.initState();
    _levelIndex = widget.initialLevelIndex
        .clamp(0, v1Levels.length - 1)
        .toInt();
    _engine = _createEngine();
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
      onEvent: debugGameEventSink,
    );
  }

  void _tick(Duration elapsed) {
    final lastTick = _lastTick;
    _lastTick = elapsed;
    if (lastTick == null || _engine.phase != GamePhase.playing) {
      return;
    }

    final dt =
        (elapsed.inMicroseconds - lastTick.inMicroseconds) /
        Duration.microsecondsPerSecond;
    _engine.update(dt);
    if (mounted) {
      setState(() {});
    }
  }

  void _restart() {
    setState(() {
      _lastTick = null;
      _engine.restart();
    });
  }

  void _nextLevel() {
    if (_levelIndex >= v1Levels.length - 1) {
      return;
    }

    setState(() {
      _levelIndex += 1;
      _lastTick = null;
      _engine = _createEngine();
    });
  }

  void _startLaunch(Offset localPosition, Size size) {
    setState(() {
      _updateLauncher(localPosition, size);
      _engine.setLaunching(true);
    });
  }

  void _updateLaunch(Offset localPosition, Size size) {
    setState(() => _updateLauncher(localPosition, size));
  }

  void _stopLaunch() {
    setState(() => _engine.setLaunching(false));
  }

  void _updateLauncher(Offset localPosition, Size size) {
    final worldX =
        localPosition.dx / math.max(1, size.width) * gameWorldSize.width;
    _engine.setLauncherX(worldX);
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _engine.snapshot;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(snapshot: snapshot, onRestart: _restart),
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
                            onPointerDown: (event) =>
                                _startLaunch(event.localPosition, size),
                            onPointerMove: (event) =>
                                _updateLaunch(event.localPosition, size),
                            onPointerUp: (_) => _stopLaunch(),
                            onPointerCancel: (_) => _stopLaunch(),
                            child: CustomPaint(
                              painter: _GamePainter(_engine),
                              child: const SizedBox.expand(),
                            ),
                          ),
                          if (snapshot.isFinished)
                            _ResultOverlay(
                              snapshot: snapshot,
                              onRestart: _restart,
                              onNext: snapshot.hasNextLevel ? _nextLevel : null,
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.snapshot, required this.onRestart});

  final GameSnapshot snapshot;
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
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay({
    required this.snapshot,
    required this.onRestart,
    required this.onNext,
  });

  final GameSnapshot snapshot;
  final VoidCallback onRestart;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final won = snapshot.phase == GamePhase.won;

    return Center(
      child: Container(
        width: 286,
        padding: const EdgeInsets.all(20),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              won ? Icons.check_circle_rounded : Icons.error_rounded,
              color: won ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              won ? 'Level clear' : 'Level lost',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              won
                  ? 'Score ${snapshot.score} | ${snapshot.stars} star${snapshot.stars == 1 ? '' : 's'}'
                  : snapshot.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GamePainter extends CustomPainter {
  _GamePainter(this.engine);

  final MarbleRunGameEngine engine;

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
  }

  void _drawFinish(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(54, engine.level.finishY - 8, 252, 16),
        const Radius.circular(8),
      ),
      paint,
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
      final paint = Paint()
        ..color = used ? color.withValues(alpha: applied ? 0.42 : 0.16) : color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(3), const Radius.circular(6)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = applied ? 4 : 2
          ..color = Colors.white.withValues(alpha: applied ? 0.92 : 0.72),
      );
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
    canvas.drawCircle(launcher, 24, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(launcher, 14, Paint()..color = const Color(0xFF93C5FD));
    canvas.drawLine(
      launcher.translate(0, -22),
      Offset(engine.launcherX, 560),
      Paint()
        ..color = const Color(0xFF1E293B).withValues(alpha: 0.18)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
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
          fontWeight: FontWeight.w800,
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
      Paint()..color = Colors.white.withValues(alpha: 0.84),
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
