import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../domain/level_definition.dart';

class PowerNodeComponent extends PositionComponent {
  PowerNodeComponent(this.definition) : super(priority: 7);

  final PulsePowerNodeDefinition definition;
  bool reached = false;
  bool visible = true;

  void sync({
    required Rect screenRect,
    required bool isReached,
    required bool isVisible,
  }) {
    position = Vector2(screenRect.left, screenRect.top);
    size = Vector2(screenRect.width, screenRect.height);
    reached = isReached;
    visible = isVisible;
  }

  @override
  void render(Canvas canvas) {
    if (!visible) {
      return;
    }

    final rect = Offset.zero & Size(size.x, size.y);
    final fill = Paint()
      ..shader = LinearGradient(
        colors: reached
            ? const [Color(0xFF8DFF8A), Color(0xFF2BE7C8)]
            : const [Color(0xFF6C5CE7), Color(0xFF2B8CFF)],
      ).createShader(rect);
    final glow = Paint()
      ..color = (reached ? const Color(0xFF8DFF8A) : const Color(0xFF2B8CFF))
          .withValues(alpha: 0.3);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(8), const Radius.circular(20)),
      glow,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(18)),
      fill,
    );

    final painter = TextPainter(
      text: TextSpan(
        text: 'NODE ${definition.chargeRequired}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
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
