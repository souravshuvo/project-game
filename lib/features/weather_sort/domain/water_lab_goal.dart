import 'water_level.dart';
import 'water_player_progress.dart';

enum WaterLabGoalKind {
  firstClear,
  clearForecastSet,
  perfectForecastSet,
  starCollector,
  clearCampaign,
  perfectCampaign,
}

class WaterLabGoal {
  const WaterLabGoal({
    required this.id,
    required this.kind,
    required this.title,
    required this.description,
    required this.current,
    required this.target,
  });

  final String id;
  final WaterLabGoalKind kind;
  final String title;
  final String description;
  final int current;
  final int target;

  bool get isComplete => target > 0 && current >= target;

  double get progress {
    if (target <= 0) {
      return 0;
    }

    return (current / target).clamp(0, 1).toDouble();
  }
}

class WaterLabGoals {
  const WaterLabGoals._();

  static List<WaterLabGoal> evaluate({
    required List<WaterLevel> levels,
    required WaterPlayerProgress progress,
  }) {
    if (levels.isEmpty) {
      return const [];
    }

    final completedTotal = _completedCount(levels, progress);
    final totalStars = _starCount(levels, progress);
    final goals = <WaterLabGoal>[
      _goal(
        id: 'first_clear',
        kind: WaterLabGoalKind.firstClear,
        title: 'First Clean Sort',
        description: 'Clear any forecast board.',
        current: completedTotal,
        target: 1,
      ),
      _goal(
        id: 'star_starter',
        kind: WaterLabGoalKind.starCollector,
        title: 'Star Starter',
        description: 'Earn 30 route stars.',
        current: totalStars,
        target: 30,
      ),
    ];

    for (var setIndex = 0; setIndex < _forecastSetNames.length; setIndex++) {
      final start = setIndex * _levelsPerSet;
      if (start >= levels.length) {
        break;
      }

      final setLevels = levels.skip(start).take(_levelsPerSet).toList();
      final setName = _forecastSetNames[setIndex];
      final completed = _completedCount(setLevels, progress);
      final stars = _starCount(setLevels, progress);
      final starTarget = setLevels.length * 3;

      goals.add(
        _goal(
          id: 'clear_set_$setIndex',
          kind: WaterLabGoalKind.clearForecastSet,
          title: '$setName Complete',
          description: 'Clear all ${setLevels.length} forecasts in this set.',
          current: completed,
          target: setLevels.length,
        ),
      );

      goals.add(
        _goal(
          id: 'perfect_set_$setIndex',
          kind: WaterLabGoalKind.perfectForecastSet,
          title: '$setName Perfect',
          description: 'Earn every star in this forecast set.',
          current: stars,
          target: starTarget,
        ),
      );
    }

    goals.addAll([
      _goal(
        id: 'star_specialist',
        kind: WaterLabGoalKind.starCollector,
        title: 'Route Specialist',
        description: 'Earn 90 route stars.',
        current: totalStars,
        target: 90,
      ),
      _goal(
        id: 'campaign_clear',
        kind: WaterLabGoalKind.clearCampaign,
        title: 'Campaign Cleared',
        description: 'Complete every Weather Lab forecast.',
        current: completedTotal,
        target: levels.length,
      ),
      _goal(
        id: 'perfect_campaign',
        kind: WaterLabGoalKind.perfectCampaign,
        title: 'Perfect Forecast Route',
        description: 'Earn 3 stars on every forecast.',
        current: totalStars,
        target: levels.length * 3,
      ),
    ]);

    return List.unmodifiable(goals);
  }

  static WaterLabGoal _goal({
    required String id,
    required WaterLabGoalKind kind,
    required String title,
    required String description,
    required int current,
    required int target,
  }) {
    return WaterLabGoal(
      id: id,
      kind: kind,
      title: title,
      description: description,
      current: current.clamp(0, target).toInt(),
      target: target,
    );
  }

  static int _completedCount(
    Iterable<WaterLevel> levels,
    WaterPlayerProgress progress,
  ) {
    return levels
        .where((level) => progress.completedLevelIds.contains(level.id))
        .length;
  }

  static int _starCount(
    Iterable<WaterLevel> levels,
    WaterPlayerProgress progress,
  ) {
    return levels.fold<int>(0, (sum, level) {
      return sum +
          (progress.bestStarsByLevel[level.id] ?? 0).clamp(0, 3).toInt();
    });
  }

  static const _levelsPerSet = 10;
  static const _forecastSetNames = [
    'Clear Skies',
    'Cloud Shift',
    'Frost Line',
    'Pressure Systems',
    'Lab Mastery',
  ];
}
