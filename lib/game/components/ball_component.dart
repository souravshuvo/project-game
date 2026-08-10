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

  static const double ballRadius = 9;

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
    super.render(canvas);
    final seamPaint = Paint()
      ..color = const Color(0xFF24312D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawLine(const Offset(4, 9), const Offset(14, 9), seamPaint);
    canvas.drawCircle(const Offset(9, 9), 3.4, seamPaint);
  }
}
