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

List<Challenge> productionV1Challenges() {
  const wideGoal = Rect.fromLTWH(96, 32, 168, 38);
  const leftGoal = Rect.fromLTWH(70, 32, 132, 38);
  const rightGoal = Rect.fromLTWH(158, 32, 132, 38);
  const narrowCenterGoal = Rect.fromLTWH(112, 32, 136, 38);
  const narrowLeftGoal = Rect.fromLTWH(82, 32, 116, 38);
  const narrowRightGoal = Rect.fromLTWH(162, 32, 116, 38);

  return [
    Challenge(
      id: 1,
      name: 'Open Rooftop',
      objective: 'Score into the open goal.',
      ballStart: Vector2(180, 500),
      goalMouth: wideGoal,
      obstacles: const [],
    ),
    Challenge(
      id: 2,
      name: 'Left Angle',
      objective: 'Score from the left side.',
      ballStart: Vector2(105, 500),
      goalMouth: wideGoal,
      obstacles: const [],
    ),
    Challenge(
      id: 3,
      name: 'Right Angle',
      objective: 'Score from the right side.',
      ballStart: Vector2(255, 500),
      goalMouth: wideGoal,
      obstacles: const [],
    ),
    Challenge(
      id: 4,
      name: 'Keeper Center',
      objective: 'Beat the keeper by finding either side.',
      ballStart: Vector2(180, 508),
      goalMouth: wideGoal,
      keeper: const Rect.fromLTWH(150, 92, 60, 24),
      obstacles: const [],
    ),
    Challenge(
      id: 5,
      name: 'Training Board',
      objective: 'Curve around the blocker.',
      ballStart: Vector2(188, 516),
      goalMouth: wideGoal,
      obstacles: const [Rect.fromLTWH(154, 298, 44, 72)],
    ),
    Challenge(
      id: 6,
      name: 'Left Board Lane',
      objective: 'Start left and bend the ball inside the open lane.',
      ballStart: Vector2(118, 512),
      goalMouth: wideGoal,
      obstacles: const [Rect.fromLTWH(188, 322, 42, 82)],
    ),
    Challenge(
      id: 7,
      name: 'Right Board Lane',
      objective: 'Start right and bend the ball inside the open lane.',
      ballStart: Vector2(242, 512),
      goalMouth: wideGoal,
      obstacles: const [Rect.fromLTWH(130, 322, 42, 82)],
    ),
    Challenge(
      id: 8,
      name: 'Low Gate',
      objective: 'Thread the shot through the center gap.',
      ballStart: Vector2(180, 528),
      goalMouth: wideGoal,
      obstacles: const [
        Rect.fromLTWH(96, 356, 46, 70),
        Rect.fromLTWH(218, 356, 46, 70),
      ],
    ),
    Challenge(
      id: 9,
      name: 'Keeper Left Step',
      objective: 'Shoot to the open side of the shifted keeper.',
      ballStart: Vector2(174, 514),
      goalMouth: wideGoal,
      keeper: const Rect.fromLTWH(116, 92, 62, 24),
      obstacles: const [],
    ),
    Challenge(
      id: 10,
      name: 'Keeper Right Step',
      objective: 'Shoot to the open side of the shifted keeper.',
      ballStart: Vector2(186, 514),
      goalMouth: wideGoal,
      keeper: const Rect.fromLTWH(182, 92, 62, 24),
      obstacles: const [],
    ),
    Challenge(
      id: 11,
      name: 'Rooftop Lane',
      objective: 'Use curve and power to beat both hazards.',
      ballStart: Vector2(196, 520),
      goalMouth: wideGoal,
      keeper: const Rect.fromLTWH(150, 92, 60, 24),
      obstacles: const [Rect.fromLTWH(118, 312, 42, 72)],
    ),
    Challenge(
      id: 12,
      name: 'Mirror Lane',
      objective: 'Use the opposite lane to beat the keeper and board.',
      ballStart: Vector2(164, 520),
      goalMouth: wideGoal,
      keeper: const Rect.fromLTWH(150, 92, 60, 24),
      obstacles: const [Rect.fromLTWH(200, 312, 42, 72)],
    ),
    Challenge(
      id: 13,
      name: 'Near Post Left',
      objective: 'Aim for the left rooftop target.',
      ballStart: Vector2(132, 512),
      goalMouth: leftGoal,
      keeper: const Rect.fromLTWH(128, 92, 54, 24),
      obstacles: const [],
    ),
    Challenge(
      id: 14,
      name: 'Near Post Right',
      objective: 'Aim for the right rooftop target.',
      ballStart: Vector2(228, 512),
      goalMouth: rightGoal,
      keeper: const Rect.fromLTWH(178, 92, 54, 24),
      obstacles: const [],
    ),
    Challenge(
      id: 15,
      name: 'Split Boards',
      objective: 'Send the ball through the middle split.',
      ballStart: Vector2(180, 526),
      goalMouth: wideGoal,
      obstacles: const [
        Rect.fromLTWH(114, 286, 48, 88),
        Rect.fromLTWH(198, 286, 48, 88),
      ],
    ),
    Challenge(
      id: 16,
      name: 'Late Bend Left',
      objective: 'Start wide and bend back after the board.',
      ballStart: Vector2(104, 526),
      goalMouth: wideGoal,
      keeper: const Rect.fromLTWH(158, 92, 58, 24),
      obstacles: const [Rect.fromLTWH(138, 350, 44, 74)],
    ),
    Challenge(
      id: 17,
      name: 'Late Bend Right',
      objective: 'Start wide and bend back after the board.',
      ballStart: Vector2(256, 526),
      goalMouth: wideGoal,
      keeper: const Rect.fromLTWH(144, 92, 58, 24),
      obstacles: const [Rect.fromLTWH(178, 350, 44, 74)],
    ),
    Challenge(
      id: 18,
      name: 'Raised Crossbar',
      objective: 'Curve around the high board before the ball slows.',
      ballStart: Vector2(180, 532),
      goalMouth: wideGoal,
      obstacles: const [Rect.fromLTWH(110, 216, 140, 24)],
    ),
    Challenge(
      id: 19,
      name: 'Narrow Window',
      objective: 'Hit the smaller center goal with a clean line.',
      ballStart: Vector2(180, 520),
      goalMouth: narrowCenterGoal,
      keeper: const Rect.fromLTWH(154, 92, 52, 24),
      obstacles: const [],
    ),
    Challenge(
      id: 20,
      name: 'Double Gate',
      objective: 'Pass through both gates without clipping a board.',
      ballStart: Vector2(180, 536),
      goalMouth: wideGoal,
      obstacles: const [
        Rect.fromLTWH(96, 392, 44, 70),
        Rect.fromLTWH(220, 392, 44, 70),
        Rect.fromLTWH(154, 258, 52, 76),
      ],
    ),
    Challenge(
      id: 21,
      name: 'Left Thread',
      objective: 'Use a soft curve through the left-side gap.',
      ballStart: Vector2(116, 534),
      goalMouth: leftGoal,
      keeper: const Rect.fromLTWH(130, 92, 54, 24),
      obstacles: const [
        Rect.fromLTWH(176, 390, 42, 76),
        Rect.fromLTWH(106, 252, 42, 76),
      ],
    ),
    Challenge(
      id: 22,
      name: 'Right Thread',
      objective: 'Use a soft curve through the right-side gap.',
      ballStart: Vector2(244, 534),
      goalMouth: rightGoal,
      keeper: const Rect.fromLTWH(176, 92, 54, 24),
      obstacles: const [
        Rect.fromLTWH(142, 390, 42, 76),
        Rect.fromLTWH(212, 252, 42, 76),
      ],
    ),
    Challenge(
      id: 23,
      name: 'Keeper Wall',
      objective: 'Beat the keeper after clearing the central board.',
      ballStart: Vector2(180, 540),
      goalMouth: narrowCenterGoal,
      keeper: const Rect.fromLTWH(138, 92, 84, 24),
      obstacles: const [Rect.fromLTWH(154, 296, 52, 76)],
    ),
    Challenge(
      id: 24,
      name: 'Zig Left',
      objective: 'Bend left, then let the curve carry back toward goal.',
      ballStart: Vector2(130, 538),
      goalMouth: wideGoal,
      obstacles: const [
        Rect.fromLTWH(104, 382, 44, 72),
        Rect.fromLTWH(206, 256, 44, 72),
      ],
    ),
    Challenge(
      id: 25,
      name: 'Zig Right',
      objective: 'Bend right, then let the curve carry back toward goal.',
      ballStart: Vector2(230, 538),
      goalMouth: wideGoal,
      obstacles: const [
        Rect.fromLTWH(212, 382, 44, 72),
        Rect.fromLTWH(110, 256, 44, 72),
      ],
    ),
    Challenge(
      id: 26,
      name: 'Narrow Left Target',
      objective: 'Find the tight left target past the keeper.',
      ballStart: Vector2(142, 530),
      goalMouth: narrowLeftGoal,
      keeper: const Rect.fromLTWH(112, 92, 62, 24),
      obstacles: const [Rect.fromLTWH(204, 324, 42, 78)],
    ),
    Challenge(
      id: 27,
      name: 'Narrow Right Target',
      objective: 'Find the tight right target past the keeper.',
      ballStart: Vector2(218, 530),
      goalMouth: narrowRightGoal,
      keeper: const Rect.fromLTWH(186, 92, 62, 24),
      obstacles: const [Rect.fromLTWH(114, 324, 42, 78)],
    ),
    Challenge(
      id: 28,
      name: 'Roofline Weave',
      objective: 'Weave through three readable boards.',
      ballStart: Vector2(180, 544),
      goalMouth: wideGoal,
      keeper: const Rect.fromLTWH(150, 92, 60, 24),
      obstacles: const [
        Rect.fromLTWH(104, 402, 42, 68),
        Rect.fromLTWH(214, 326, 42, 68),
        Rect.fromLTWH(126, 236, 42, 68),
      ],
    ),
    Challenge(
      id: 29,
      name: 'Last Gap',
      objective: 'Choose the late gap before the keeper closes the center.',
      ballStart: Vector2(180, 548),
      goalMouth: narrowCenterGoal,
      keeper: const Rect.fromLTWH(146, 92, 68, 24),
      obstacles: const [
        Rect.fromLTWH(96, 388, 44, 84),
        Rect.fromLTWH(220, 388, 44, 84),
        Rect.fromLTWH(154, 260, 52, 72),
      ],
    ),
    Challenge(
      id: 30,
      name: 'Final Curve',
      objective: 'Use full control: power, curve, timing, and a clean lane.',
      ballStart: Vector2(180, 552),
      goalMouth: narrowCenterGoal,
      keeper: const Rect.fromLTWH(148, 92, 64, 24),
      obstacles: const [
        Rect.fromLTWH(112, 408, 44, 76),
        Rect.fromLTWH(204, 330, 44, 76),
        Rect.fromLTWH(136, 234, 44, 70),
      ],
    ),
  ];
}

List<Challenge> productionV1StarterChallenges() {
  return productionV1Challenges();
}
