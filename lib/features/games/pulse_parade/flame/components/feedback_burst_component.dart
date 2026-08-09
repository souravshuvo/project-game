import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class FeedbackBurstComponent extends PositionComponent {
  FeedbackBurstComponent({
    required this.label,
    required this.color,
    required Vector2 position,
    this.lifetime = 0.95,
  }) : super(position: position, anchor: Anchor.center, priority: 90);

  final String label;
  final Color color;
  final double lifetime;

  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    position.y -= 34 * dt;
    if (_age >= lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / lifetime).clamp(0, 1).toDouble();
    final opacity = math.max(0.0, 1 - t);
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.42 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset.zero, 18 + (t * 30), ringPaint);

    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: opacity),
          fontSize: 22 + ((1 - t) * 4),
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(color: color.withValues(alpha: opacity), blurRadius: 12),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final bubble = Rect.fromCenter(
      center: Offset.zero,
      width: painter.width + 22,
      height: painter.height + 12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bubble, const Radius.circular(99)),
      Paint()..color = const Color(0xDD141A25).withValues(alpha: opacity),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bubble, const Radius.circular(99)),
      Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
  }
}
