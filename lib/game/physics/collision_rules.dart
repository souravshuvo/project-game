import 'dart:ui';

import 'package:flame/components.dart';

import '../game_result.dart';
import 'shot_physics.dart';

class CollisionRules {
  static GameResultType? resolve({
    required Vector2 ballPosition,
    required double ballRadius,
    required Vector2 velocity,
    required Rect fieldBounds,
    required Rect goalMouth,
    required Rect? keeper,
    required List<Rect> obstacles,
  }) {
    final ballRect = Rect.fromCircle(
      center: Offset(ballPosition.x, ballPosition.y),
      radius: ballRadius,
    );

    if (_isGoal(ballPosition, ballRadius, goalMouth)) {
      return GameResultType.goal;
    }

    if (keeper != null && ballRect.overlaps(keeper)) {
      return GameResultType.saved;
    }

    for (final obstacle in obstacles) {
      if (ballRect.overlaps(obstacle)) {
        return GameResultType.blocked;
      }
    }

    if (!fieldBounds
        .inflate(ballRadius)
        .contains(Offset(ballPosition.x, ballPosition.y))) {
      return GameResultType.missed;
    }

    if (velocity.length < ShotPhysics.stopSpeed) {
      return GameResultType.tooWeak;
    }

    return null;
  }

  static bool _isGoal(Vector2 ballPosition, double radius, Rect goalMouth) {
    final crossedLine = ballPosition.y - radius <= goalMouth.bottom;
    final insidePosts =
        ballPosition.x + radius >= goalMouth.left &&
        ballPosition.x - radius <= goalMouth.right;

    return crossedLine && insidePosts;
  }
}
