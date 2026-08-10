import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/game/physics/shot_physics.dart';

void main() {
  test('dragging below the ball creates an upward shot', () {
    final shot = ShotPhysics.fromDrag(
      ballPosition: Vector2(180, 540),
      dragPosition: Vector2(180, 620),
    );

    expect(shot.power, greaterThan(0));
    expect(shot.velocity.y, lessThan(0));
  });

  test('short drag does not shoot', () {
    final shot = ShotPhysics.fromDrag(
      ballPosition: Vector2(180, 540),
      dragPosition: Vector2(180, 534),
    );

    expect(shot.power, 0);
    expect(shot.velocity.length, 0);
  });

  test('sideways drag adds curve and clamps it', () {
    final shot = ShotPhysics.fromDrag(
      ballPosition: Vector2(180, 540),
      dragPosition: Vector2(420, 620),
    );

    expect(shot.curve, 1);
  });
}
