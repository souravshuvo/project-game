import 'dart:ui';

import 'package:flame/components.dart';

class FieldComponent extends PositionComponent {
  FieldComponent() : super(position: Vector2.zero(), size: Vector2(360, 640));

  @override
  void render(Canvas canvas) {
    final background = Paint()..color = const Color(0xFF176857);
    canvas.drawRect(size.toRect(), background);

    final courtPaint = Paint()
      ..color = const Color(0xFFE6F2E5).withValues(alpha: 0.36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(const Rect.fromLTWH(24, 22, 312, 596), courtPaint);
    canvas.drawLine(const Offset(24, 320), const Offset(336, 320), courtPaint);
    canvas.drawCircle(const Offset(180, 320), 48, courtPaint);

    final roofPaint = Paint()..color = const Color(0xFF0F3C44);
    canvas.drawRect(const Rect.fromLTWH(0, 606, 360, 34), roofPaint);
  }
}
