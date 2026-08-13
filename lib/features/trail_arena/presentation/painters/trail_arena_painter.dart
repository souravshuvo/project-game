import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/food_type.dart';
import '../../domain/run_state.dart';
import '../../game/components/trail_actor_component.dart';
import '../../game/trail_arena_game.dart';

class TrailArenaPainter extends CustomPainter {
  TrailArenaPainter(this.game) : super(repaint: game);

  final TrailArenaGame game;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / TrailArenaGame.arenaWidth;
    final scaleY = size.height / TrailArenaGame.arenaHeight;
    canvas
      ..save()
      ..scale(scaleX, scaleY);

    _drawArena(canvas);
    _drawFood(canvas);
    for (final bot in game.bots) {
      if (bot.alive) {
        _drawTrail(canvas, bot, const Color(0xFFFFD166));
      }
    }
    _drawTrail(canvas, game.player, const Color(0xFF65F0B4));

    canvas.restore();
  }

  void _drawArena(Canvas canvas) {
    const arenaRect = Rect.fromLTWH(
      0,
      0,
      TrailArenaGame.arenaWidth,
      TrailArenaGame.arenaHeight,
    );
    canvas.drawRect(arenaRect, Paint()..color = const Color(0xFF101510));

    final dotPaint = Paint()..color = const Color(0x1A9CF8CC);
    for (var x = 36.0; x < TrailArenaGame.arenaWidth; x += 72) {
      for (var y = 36.0; y < TrailArenaGame.arenaHeight; y += 72) {
        canvas.drawCircle(Offset(x, y), 1.7, dotPaint);
      }
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(arenaRect.deflate(4), const Radius.circular(24)),
      Paint()
        ..color = const Color(0xFF365A44)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  void _drawFood(Canvas canvas) {
    for (final item in game.food) {
      final color = switch (item.type) {
        FoodType.seed => const Color(0xFFFF8A76),
        FoodType.brightSeed => const Color(0xFFFFD166),
      };
      final pulse =
          1 +
          (math.sin((game.elapsedSeconds * 7) + item.position.x * 0.02) * 0.08);
      final center = Offset(item.position.x, item.position.y);
      canvas.drawCircle(
        center,
        item.type.radius * 2.25 * pulse,
        Paint()..color = color.withValues(alpha: 0.13),
      );
      canvas.drawCircle(center, item.type.radius, Paint()..color = color);
      canvas.drawCircle(
        center.translate(-2, -2),
        item.type.radius * 0.3,
        Paint()..color = Colors.white.withValues(alpha: 0.5),
      );
    }
  }

  void _drawTrail(Canvas canvas, TrailActorComponent actor, Color color) {
    final trail = actor.trail;
    if (trail.length < 2) {
      return;
    }

    final path = Path()..moveTo(trail.first.x, trail.first.y);
    for (final point in trail.skip(1)) {
      path.lineTo(point.x, point.y);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = TrailArenaGame.bodyRadius * 3.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = TrailArenaGame.bodyRadius * 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final head = Offset(actor.head.x, actor.head.y);
    canvas.drawCircle(
      head,
      TrailArenaGame.headRadius * 1.65,
      Paint()..color = color.withValues(alpha: 0.22),
    );
    canvas.drawCircle(
      head,
      TrailArenaGame.headRadius,
      Paint()
        ..color = actor.kind == ActorKind.player
            ? color
            : const Color(0xFFFFE29A),
    );
    canvas.drawCircle(
      head + Offset(math.cos(actor.heading) * 4, math.sin(actor.heading) * 4),
      4,
      Paint()..color = const Color(0xFF142018),
    );
  }

  @override
  bool shouldRepaint(covariant TrailArenaPainter oldDelegate) {
    return false;
  }
}
