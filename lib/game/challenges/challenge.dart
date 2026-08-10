import 'dart:ui';

import 'package:flame/components.dart';

class Challenge {
  const Challenge({
    required this.id,
    required this.name,
    required this.objective,
    required this.ballStart,
    required this.goalMouth,
    this.keeper,
    required this.obstacles,
  });

  final int id;
  final String name;
  final String objective;
  final Vector2 ballStart;
  final Rect goalMouth;
  final Rect? keeper;
  final List<Rect> obstacles;
}

List<Challenge> productionV1StarterChallenges() {
  return [
    Challenge(
      id: 1,
      name: 'Open Rooftop',
      objective: 'Score into the open goal.',
      ballStart: Vector2(180, 500),
      goalMouth: const Rect.fromLTWH(96, 32, 168, 38),
      obstacles: const [],
    ),
    Challenge(
      id: 2,
      name: 'Left Angle',
      objective: 'Score from the left side.',
      ballStart: Vector2(105, 500),
      goalMouth: const Rect.fromLTWH(96, 32, 168, 38),
      obstacles: const [],
    ),
    Challenge(
      id: 3,
      name: 'Keeper Center',
      objective: 'Beat the keeper by finding either side.',
      ballStart: Vector2(180, 508),
      goalMouth: const Rect.fromLTWH(96, 32, 168, 38),
      keeper: const Rect.fromLTWH(150, 92, 60, 24),
      obstacles: const [],
    ),
    Challenge(
      id: 4,
      name: 'Training Board',
      objective: 'Curve around the blocker.',
      ballStart: Vector2(188, 516),
      goalMouth: const Rect.fromLTWH(96, 32, 168, 38),
      obstacles: const [Rect.fromLTWH(154, 298, 44, 72)],
    ),
    Challenge(
      id: 5,
      name: 'Rooftop Lane',
      objective: 'Use curve and power to beat both hazards.',
      ballStart: Vector2(196, 520),
      goalMouth: const Rect.fromLTWH(96, 32, 168, 38),
      keeper: const Rect.fromLTWH(150, 92, 60, 24),
      obstacles: const [Rect.fromLTWH(118, 312, 42, 72)],
    ),
  ];
}
