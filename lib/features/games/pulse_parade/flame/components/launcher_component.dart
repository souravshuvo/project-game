import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LauncherComponent extends PositionComponent {
  LauncherComponent() : super(anchor: Anchor.center, priority: 20);

  void sync({required Vector2 screenPosition, required double scale}) {
    position = screenPosition;
    size = Vector2(92 * scale, 46 * scale);
  }

  @override
  void render(Canvas canvas) {
    final body = Rect.fromCenter(
      center: Offset(size.x / 2, size.y / 2),
      width: size.x,
      height: size.y,
    );
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF5CE9D0), Color(0xFF2B8CFF)],
      ).createShader(body);
    final shadow = Paint()..color = const Color(0x552BE7C8);

    canvas.drawOval(body.inflate(8), shadow);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(size.y / 2)),
      paint,
    );
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.y * 0.25,
      Paint()..color = Colors.white.withValues(alpha: 0.86),
    );
  }
}
