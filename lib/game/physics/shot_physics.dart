import 'dart:math' as math;

import 'package:flame/components.dart';

class ShotConfig {
  const ShotConfig({
    required this.velocity,
    required this.curve,
    required this.power,
  });

  final Vector2 velocity;
  final double curve;
  final double power;
}

class ShotPhysics {
  static const double minDrag = 12;
  static const double maxDrag = 124;
  static const double minShotSpeed = 190;
  static const double maxShotSpeed = 560;
  static const double maxCurveAcceleration = 86;
  static const double frictionPerSecond = 0.58;
  static const double stopSpeed = 18;

  static ShotConfig fromDrag({
    required Vector2 ballPosition,
    required Vector2 dragPosition,
  }) {
    final pull = ballPosition - dragPosition;
    final dragLength = pull.length;
    final power = (dragLength / maxDrag).clamp(0.0, 1.0);

    if (dragLength < minDrag) {
      return ShotConfig(velocity: Vector2.zero(), curve: 0, power: 0);
    }

    final direction = pull.normalized();
    final speed = minShotSpeed + (maxShotSpeed - minShotSpeed) * power;
    final curve = ((dragPosition.x - ballPosition.x) / 92).clamp(-1.0, 1.0);

    return ShotConfig(velocity: direction * speed, curve: curve, power: power);
  }

  static Vector2 nextVelocity({
    required Vector2 velocity,
    required double curve,
    required double dt,
  }) {
    if (velocity.length2 <= 0) {
      return Vector2.zero();
    }

    final side = Vector2(-velocity.y, velocity.x)..normalize();
    final curved = velocity + side * curve * maxCurveAcceleration * dt;
    final drag = math.pow(frictionPerSecond, dt).toDouble();
    return curved * drag;
  }
}
