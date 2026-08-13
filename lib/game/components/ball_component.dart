import 'dart:ui';

import 'package:flame/components.dart';

import '../physics/shot_physics.dart';

class BallComponent extends CircleComponent {
  BallComponent({required Vector2 start})
    : super(
        position: start,
        radius: ballRadius,
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xFFF7F0D2),
      );

  static const double ballRadius = 11;

  Vector2 velocity = Vector2.zero();
  double curve = 0;
  bool inFlight = false;

  void reset(Vector2 start) {
    position = start.clone();
    velocity = Vector2.zero();
    curve = 0;
    inFlight = false;
  }

  void shoot(ShotConfig shot) {
    velocity = shot.velocity.clone();
    curve = shot.curve;
    inFlight = shot.power > 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!inFlight) {
      return;
    }

    velocity = ShotPhysics.nextVelocity(
      velocity: velocity,
      curve: curve,
      dt: dt,
    );
    position += velocity * dt;
  }

  @override
  void render(Canvas canvas) {
    const center = Offset(ballRadius, ballRadius);
    if (!inFlight) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD166).withValues(alpha: 0.22)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 28, glowPaint);

      final ringPaint = Paint()
        ..color = const Color(0xFFFFD166).withValues(alpha: 0.78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;
      canvas.drawCircle(center, 22, ringPaint);

      final pullPaint = Paint()
        ..color = const Color(0xFFFFD166).withValues(alpha: 0.74)
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      final arrowStart = center.translate(0, 31);
      final arrowEnd = center.translate(0, 64);
      canvas.drawLine(arrowStart, arrowEnd, pullPaint);
      canvas.drawLine(arrowEnd, arrowEnd.translate(-7, -9), pullPaint);
      canvas.drawLine(arrowEnd, arrowEnd.translate(7, -9), pullPaint);
    }
    super.render(canvas);
    final seamPaint = Paint()
      ..color = const Color(0xFF24312D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawLine(
      center.translate(-6.5, 0),
      center.translate(6.5, 0),
      seamPaint,
    );
    canvas.drawCircle(center, 4.2, seamPaint);
  }
}
