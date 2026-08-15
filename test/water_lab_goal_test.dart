import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/data/local_water_level_pack.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/domain/water_lab_goal.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/domain/water_player_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v1 campaign exposes a complete lab goal set', () {
    final goals = WaterLabGoals.evaluate(
      levels: localWaterLevelPack,
      progress: WaterPlayerProgress.initial(),
    );

    expect(goals, hasLength(15));
    expect(goals.map((goal) => goal.id).toSet(), hasLength(goals.length));
    expect(goals.every((goal) => goal.target > 0), isTrue);
    expect(goals.every((goal) => goal.current == 0), isTrue);
    expect(goals.where((goal) => goal.isComplete), isEmpty);
    expect(
      goals.map((goal) => goal.kind),
      containsAll([
        WaterLabGoalKind.firstClear,
        WaterLabGoalKind.clearForecastSet,
        WaterLabGoalKind.perfectForecastSet,
        WaterLabGoalKind.starCollector,
        WaterLabGoalKind.clearCampaign,
        WaterLabGoalKind.perfectCampaign,
      ]),
    );
  });

  test('forecast set goals track clears and perfect stars', () {
    final clearSkiesIds = localWaterLevelPack
        .take(10)
        .map((level) => level.id)
        .toSet();
    final progress = WaterPlayerProgress.initial().copyWith(
      completedLevelIds: clearSkiesIds,
      bestStarsByLevel: {for (final id in clearSkiesIds) id: 3},
    );

    final goals = WaterLabGoals.evaluate(
      levels: localWaterLevelPack,
      progress: progress,
    );

    expect(_goalById(goals, 'first_clear').isComplete, isTrue);
    expect(_goalById(goals, 'clear_set_0').current, 10);
    expect(_goalById(goals, 'clear_set_0').isComplete, isTrue);
    expect(_goalById(goals, 'perfect_set_0').current, 30);
    expect(_goalById(goals, 'perfect_set_0').isComplete, isTrue);
    expect(_goalById(goals, 'star_starter').isComplete, isTrue);
    expect(_goalById(goals, 'star_specialist').current, 30);
    expect(_goalById(goals, 'star_specialist').isComplete, isFalse);
    expect(_goalById(goals, 'campaign_clear').current, 10);
  });

  test('perfect campaign goal requires every saved route star', () {
    final completedIds = localWaterLevelPack.map((level) => level.id).toSet();
    final progress = WaterPlayerProgress.initial().copyWith(
      completedLevelIds: completedIds,
      bestStarsByLevel: {for (final id in completedIds) id: 3},
    );

    final goals = WaterLabGoals.evaluate(
      levels: localWaterLevelPack,
      progress: progress,
    );

    expect(_goalById(goals, 'campaign_clear').isComplete, isTrue);
    expect(_goalById(goals, 'perfect_campaign').current, 150);
    expect(_goalById(goals, 'perfect_campaign').isComplete, isTrue);
    expect(goals.where((goal) => goal.isComplete), hasLength(goals.length));
  });

  test('goals ignore stale progress for levels outside the campaign', () {
    final progress = WaterPlayerProgress.initial().copyWith(
      completedLevelIds: {999},
      bestStarsByLevel: const {999: 3},
    );

    final goals = WaterLabGoals.evaluate(
      levels: localWaterLevelPack,
      progress: progress,
    );

    expect(_goalById(goals, 'first_clear').current, 0);
    expect(_goalById(goals, 'campaign_clear').current, 0);
    expect(_goalById(goals, 'perfect_campaign').current, 0);
  });
}

WaterLabGoal _goalById(List<WaterLabGoal> goals, String id) {
  return goals.singleWhere((goal) => goal.id == id);
}
