import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../domain/level_definition.dart';

class GateComponent extends PositionComponent {
  GateComponent(this.definition) : super(priority: 5);

  final PulseGateDefinition definition;
  bool activated = false;
  bool visible = true;

  void sync({
    required Rect screenRect,
    required bool isActivated,
    required bool isVisible,
  }) {
    position = Vector2(screenRect.left, screenRect.top);
    size = Vector2(screenRect.width, screenRect.height);
    activated = isActivated;
    visible = isVisible;
  }

  @override
  void render(Canvas canvas) {
    if (!visible) {
      return;
    }

    final rect = Offset.zero & Size(size.x, size.y);
    final color = _gateColor(definition);
    final alpha = activated ? 0.25 : 0.72;
    final fill = Paint()..color = color.withValues(alpha: alpha);
    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: activated ? 0.28 : 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rounded = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.drawRRect(rounded, fill);
    canvas.drawRRect(rounded, stroke);

    final painter = TextPainter(
      text: TextSpan(
        text: definition.label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: activated ? 0.58 : 1),
          fontSize: 22,
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

  Color _gateColor(PulseGateDefinition gate) {
    return switch (gate.type) {
      PulseGateType.amplifier => const Color(0xFF25C98D),
      PulseGateType.resonator => const Color(0xFF398DFF),
      PulseGateType.polarity => const Color(0xFF43F0D8),
    };
  }
}
