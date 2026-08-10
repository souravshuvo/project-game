import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/game/game_result.dart';
import 'package:rapid_jump/game/physics/collision_rules.dart';

void main() {
  const field = Rect.fromLTWH(0, 0, 360, 640);
  const goal = Rect.fromLTWH(96, 30, 168, 38);
  const keeper = Rect.fromLTWH(150, 82, 60, 22);
  const obstacles = [Rect.fromLTWH(122, 318, 40, 72)];

  test('detects goal inside posts', () {
    final result = CollisionRules.resolve(
      ballPosition: Vector2(180, 64),
      ballRadius: 9,
      velocity: Vector2(0, -100),
      fieldBounds: field,
      goalMouth: goal,
      keeper: keeper,
      obstacles: obstacles,
    );

    expect(result, GameResultType.goal);
  });

  test('detects keeper save', () {
    final result = CollisionRules.resolve(
      ballPosition: Vector2(180, 92),
      ballRadius: 9,
      velocity: Vector2(0, -100),
      fieldBounds: field,
      goalMouth: goal,
      keeper: keeper,
      obstacles: obstacles,
    );

    expect(result, GameResultType.saved);
  });

  test('detects obstacle block', () {
    final result = CollisionRules.resolve(
      ballPosition: Vector2(142, 340),
      ballRadius: 9,
      velocity: Vector2(0, -100),
      fieldBounds: field,
      goalMouth: goal,
      keeper: keeper,
      obstacles: obstacles,
    );

    expect(result, GameResultType.blocked);
  });

  test('detects miss outside field', () {
    final result = CollisionRules.resolve(
      ballPosition: Vector2(-20, 200),
      ballRadius: 9,
      velocity: Vector2(-100, 0),
      fieldBounds: field,
      goalMouth: goal,
      keeper: keeper,
      obstacles: obstacles,
    );

    expect(result, GameResultType.missed);
  });

  test('open goal levels can omit keeper', () {
    final result = CollisionRules.resolve(
      ballPosition: Vector2(180, 92),
      ballRadius: 9,
      velocity: Vector2(0, -100),
      fieldBounds: field,
      goalMouth: goal,
      keeper: null,
      obstacles: obstacles,
    );

    expect(result, isNull);
  });
}
