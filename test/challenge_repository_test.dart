import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/game/challenges/challenge.dart';

void main() {
  test('starter challenge set has fair v1 onboarding structure', () {
    final challenges = productionV1StarterChallenges();

    expect(challenges, hasLength(5));
    expect(challenges.first.keeper, isNull);
    expect(challenges.first.obstacles, isEmpty);
    expect(challenges.any((challenge) => challenge.keeper != null), isTrue);
    expect(challenges.any((challenge) => challenge.obstacles.isNotEmpty), isTrue);
  });
}
