import 'dart:ui';

import 'package:flame/components.dart';

import '../physics/shot_physics.dart';

class AimPreviewComponent extends PositionComponent {
  Vector2? start;
  Vector2? drag;
  ShotConfig? shot;

  void updateAim({
    required Vector2 startPosition,
    required Vector2 dragPosition,
    required ShotConfig shotConfig,
  }) {
    start = startPosition.clone();
    drag = dragPosition.clone();
    shot = shotConfig;
  }

  void clear() {
    start = null;
    drag = null;
    shot = null;
  }

  @override
  void render(Canvas canvas) {
    final startPosition = start;
    final dragPosition = drag;
    final shotConfig = shot;
    if (startPosition == null || dragPosition == null || shotConfig == null) {
      return;
    }

    final pullPaint = Paint()
      ..color = const Color(0xFFFFD166).withValues(alpha: 0.95)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      startPosition.toOffset(),
      dragPosition.toOffset(),
      pullPaint,
    );
    canvas.drawCircle(
      dragPosition.toOffset(),
      7,
      Paint()..color = const Color(0xFFFFD166).withValues(alpha: 0.9),
    );

    final previewPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(startPosition.x, startPosition.y);
    var previewPosition = startPosition.clone();
    var velocity = shotConfig.velocity.clone() * 0.9;
    for (var i = 0; i < 78; i++) {
      velocity = ShotPhysics.nextVelocity(
        velocity: velocity,
        curve: shotConfig.curve,
        dt: 1 / 60,
      );
      previewPosition += velocity * (1 / 60);
      path.lineTo(previewPosition.x, previewPosition.y);
    }
    canvas.drawPath(path, previewPaint);

    final endPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawCircle(previewPosition.toOffset(), 7, endPaint);
  }
}
