import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/game/challenges/challenge.dart';

void main() {
  const field = Rect.fromLTWH(0, 0, 360, 640);

  bool rectInsideField(Rect rect) {
    return rect.left >= field.left &&
        rect.top >= field.top &&
        rect.right <= field.right &&
        rect.bottom <= field.bottom;
  }

  test('production v1 challenge set has release-size content', () {
    final challenges = productionV1Challenges();

    expect(challenges, hasLength(30));
    expect(
      challenges.map((challenge) => challenge.id),
      orderedEquals(List<int>.generate(30, (index) => index + 1)),
    );
    expect(challenges.first.keeper, isNull);
    expect(challenges.first.obstacles, isEmpty);
    expect(
      challenges.take(3).every((challenge) => challenge.keeper == null),
      isTrue,
    );
    expect(challenges.any((challenge) => challenge.keeper != null), isTrue);
    expect(
      challenges.any((challenge) => challenge.obstacles.isNotEmpty),
      isTrue,
    );
    expect(
      challenges.skip(14).any((challenge) => challenge.obstacles.length >= 2),
      isTrue,
    );
    expect(
      challenges.any((challenge) => challenge.goalMouth.width < 140),
      isTrue,
    );
  });

  test('production v1 challenge layout stays inside the readable field', () {
    final challenges = productionV1Challenges();

    for (final challenge in challenges) {
      final ballCenter = Offset(challenge.ballStart.x, challenge.ballStart.y);
      final ballStartZone = Rect.fromCircle(center: ballCenter, radius: 36);

      expect(
        field.deflate(24).contains(ballCenter),
        isTrue,
        reason:
            'Challenge ${challenge.id} ball starts inside touch-safe field.',
      );
      expect(
        rectInsideField(challenge.goalMouth),
        isTrue,
        reason: 'Challenge ${challenge.id} goal is inside the field.',
      );
      expect(
        challenge.goalMouth.width,
        greaterThanOrEqualTo(100),
        reason: 'Challenge ${challenge.id} goal remains readable.',
      );

      final keeper = challenge.keeper;
      if (keeper != null) {
        expect(
          rectInsideField(keeper),
          isTrue,
          reason: 'Challenge ${challenge.id} keeper is inside the field.',
        );
        expect(
          keeper.overlaps(challenge.goalMouth),
          isFalse,
          reason:
              'Challenge ${challenge.id} keeper does not cover the goal line.',
        );
      }

      expect(
        challenge.obstacles.length,
        lessThanOrEqualTo(3),
        reason: 'Challenge ${challenge.id} stays readable for v1.',
      );
      for (final obstacle in challenge.obstacles) {
        expect(
          rectInsideField(obstacle),
          isTrue,
          reason: 'Challenge ${challenge.id} obstacle is inside the field.',
        );
        expect(
          obstacle.overlaps(ballStartZone),
          isFalse,
          reason: 'Challenge ${challenge.id} obstacle does not cover the ball.',
        );
        expect(
          obstacle.overlaps(challenge.goalMouth),
          isFalse,
          reason: 'Challenge ${challenge.id} obstacle does not cover the goal.',
        );
      }
    }
  });

  test('starter challenge alias stays compatible with production content', () {
    expect(productionV1StarterChallenges(), hasLength(30));
  });
}
