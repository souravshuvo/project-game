import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../domain/level_definition.dart';

class EnemyGroupComponent extends PositionComponent {
  EnemyGroupComponent(this.definition) : super(priority: 8);

  final PulseEnemyDefinition definition;
  bool resolved = false;
  bool visible = true;

  void sync({
    required Rect screenRect,
    required bool isResolved,
    required bool isVisible,
  }) {
    position = Vector2(screenRect.left, screenRect.top);
    size = Vector2(screenRect.width, screenRect.height);
    resolved = isResolved;
    visible = isVisible;
  }

  @override
  void render(Canvas canvas) {
    if (!visible) {
      return;
    }

    final rect = Offset.zero & Size(size.x, size.y);
    final baseColor = resolved
        ? const Color(0xFF5E6472)
        : const Color(0xFFFF4F7A);
    final fill = Paint()..color = baseColor.withValues(alpha: 0.76);
    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: resolved ? 0.28 : 0.86)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(14)),
      fill,
    );

    final glitchPaint = Paint()
      ..color = Colors.black.withValues(alpha: resolved ? 0.16 : 0.3);
    for (var i = 0; i < 9; i++) {
      final x = (i + 1) * size.x / 10;
      final y = size.y * (0.35 + math.sin(i * 1.7) * 0.18);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: 18, height: 5),
        glitchPaint,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(14)),
      stroke,
    );

    final painter = TextPainter(
      text: TextSpan(
        text: resolved ? 'CLEAR' : '${definition.strength}',
        style: TextStyle(
          color: Colors.white.withValues(alpha: resolved ? 0.56 : 1),
          fontSize: 21,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.x);
    painter.paint(
      canvas,
      Offset((size.x - painter.width) / 2, (size.y - painter.height) / 2),
    );
  }
}
