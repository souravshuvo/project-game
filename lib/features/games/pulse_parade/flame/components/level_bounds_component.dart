import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LevelBoundsComponent extends PositionComponent {
  LevelBoundsComponent() : super(priority: -10);

  void sync(Vector2 viewportSize) {
    size = viewportSize;
  }

  @override
  void render(Canvas canvas) {
    final bounds = Offset.zero & Size(size.x, size.y);
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF11151F), Color(0xFF182236), Color(0xFF101018)],
      ).createShader(bounds);

    canvas.drawRect(bounds, background);

    final gridPaint = Paint()
      ..color = const Color(0x332BE7C8)
      ..strokeWidth = 1;
    const spacing = 36.0;
    final animatedOffset =
        (DateTime.now().millisecondsSinceEpoch / 45) % spacing;

    for (var x = 0.0; x <= size.x; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), gridPaint);
    }
    for (var y = -spacing; y <= size.y + spacing; y += spacing) {
      canvas.drawLine(
        Offset(0, y + animatedOffset),
        Offset(size.x, y + animatedOffset),
        gridPaint,
      );
    }

    final tracePaint = Paint()
      ..color = const Color(0x402BE7C8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(size.x * 0.5, size.y + 40);
    for (var i = 0; i < 7; i++) {
      final y = size.y - (i * size.y / 6);
      final x = size.x * (0.5 + math.sin(i * 1.2) * 0.12);
      path.lineTo(x, y);
    }
    canvas.drawPath(path, tracePaint);
  }
}
