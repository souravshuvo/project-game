import 'run_stats.dart';

enum TrailGoalMetric {
  score,
  survivalSeconds,
  foodCollected,
  brightFoodCollected,
  botCrashes,
  trailLength,
}

class TrailGoalDefinition {
  const TrailGoalDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.metric,
    required this.target,
  });

  final String id;
  final String title;
  final String description;
  final TrailGoalMetric metric;
  final int target;

  int progressFrom(RunStats stats) {
    final raw = switch (metric) {
      TrailGoalMetric.score => stats.score,
      TrailGoalMetric.survivalSeconds => stats.survivalSeconds.floor(),
      TrailGoalMetric.foodCollected => stats.foodCollected,
      TrailGoalMetric.brightFoodCollected => stats.brightFoodCollected,
      TrailGoalMetric.botCrashes => stats.botCrashes,
      TrailGoalMetric.trailLength => stats.trailLength.floor(),
    };
    return raw > target ? target : raw;
  }

  bool isCompletedBy(RunStats stats) {
    return progressFrom(stats) >= target;
  }

  String progressLabel(RunStats stats) {
    return '${progressFrom(stats)}/$target ${unitLabel(target)}';
  }

  String unitLabel(int value) {
    return switch (metric) {
      TrailGoalMetric.score => 'pts',
      TrailGoalMetric.survivalSeconds => value == 1 ? 'sec' : 'sec',
      TrailGoalMetric.foodCollected => value == 1 ? 'seed' : 'seeds',
      TrailGoalMetric.brightFoodCollected => value == 1 ? 'bright' : 'bright',
      TrailGoalMetric.botCrashes => value == 1 ? 'crash' : 'crashes',
      TrailGoalMetric.trailLength => 'length',
    };
  }
}

class TrailGoalCatalog {
  const TrailGoalCatalog._();

  static const List<TrailGoalDefinition> goals = [
    TrailGoalDefinition(
      id: 'trail_seed_01',
      title: 'First Seed',
      description: 'Collect 1 seed in a run.',
      metric: TrailGoalMetric.foodCollected,
      target: 1,
    ),
    TrailGoalDefinition(
      id: 'trail_survive_20',
      title: 'Stay Moving',
      description: 'Survive for 20 seconds.',
      metric: TrailGoalMetric.survivalSeconds,
      target: 20,
    ),
    TrailGoalDefinition(
      id: 'trail_score_60',
      title: 'Score Spark',
      description: 'Reach 60 points in a run.',
      metric: TrailGoalMetric.score,
      target: 60,
    ),
    TrailGoalDefinition(
      id: 'trail_seed_06',
      title: 'Seed Line',
      description: 'Collect 6 seeds in a run.',
      metric: TrailGoalMetric.foodCollected,
      target: 6,
    ),
    TrailGoalDefinition(
      id: 'trail_length_200',
      title: 'Longer Glow',
      description: 'Grow your trail to 200 length.',
      metric: TrailGoalMetric.trailLength,
      target: 200,
    ),
    TrailGoalDefinition(
      id: 'trail_bright_01',
      title: 'Bright Find',
      description: 'Collect 1 bright seed in a run.',
      metric: TrailGoalMetric.brightFoodCollected,
      target: 1,
    ),
    TrailGoalDefinition(
      id: 'trail_crash_01',
      title: 'Rival Mistake',
      description: 'Make 1 bot crash into your trail.',
      metric: TrailGoalMetric.botCrashes,
      target: 1,
    ),
    TrailGoalDefinition(
      id: 'trail_survive_40',
      title: 'Calm Turns',
      description: 'Survive for 40 seconds.',
      metric: TrailGoalMetric.survivalSeconds,
      target: 40,
    ),
    TrailGoalDefinition(
      id: 'trail_score_150',
      title: 'Green Run',
      description: 'Reach 150 points in a run.',
      metric: TrailGoalMetric.score,
      target: 150,
    ),
    TrailGoalDefinition(
      id: 'trail_seed_12',
      title: 'Clean Sweep',
      description: 'Collect 12 seeds in a run.',
      metric: TrailGoalMetric.foodCollected,
      target: 12,
    ),
    TrailGoalDefinition(
      id: 'trail_length_260',
      title: 'Wide Arc',
      description: 'Grow your trail to 260 length.',
      metric: TrailGoalMetric.trailLength,
      target: 260,
    ),
    TrailGoalDefinition(
      id: 'trail_bright_02',
      title: 'Double Bright',
      description: 'Collect 2 bright seeds in a run.',
      metric: TrailGoalMetric.brightFoodCollected,
      target: 2,
    ),
    TrailGoalDefinition(
      id: 'trail_crash_02',
      title: 'Trail Trap',
      description: 'Make 2 bots crash in a run.',
      metric: TrailGoalMetric.botCrashes,
      target: 2,
    ),
    TrailGoalDefinition(
      id: 'trail_survive_60',
      title: 'One Minute',
      description: 'Survive for 60 seconds.',
      metric: TrailGoalMetric.survivalSeconds,
      target: 60,
    ),
    TrailGoalDefinition(
      id: 'trail_score_260',
      title: 'Strong Score',
      description: 'Reach 260 points in a run.',
      metric: TrailGoalMetric.score,
      target: 260,
    ),
    TrailGoalDefinition(
      id: 'trail_seed_20',
      title: 'Seed Hunter',
      description: 'Collect 20 seeds in a run.',
      metric: TrailGoalMetric.foodCollected,
      target: 20,
    ),
    TrailGoalDefinition(
      id: 'trail_length_340',
      title: 'Arena Ribbon',
      description: 'Grow your trail to 340 length.',
      metric: TrailGoalMetric.trailLength,
      target: 340,
    ),
    TrailGoalDefinition(
      id: 'trail_bright_04',
      title: 'Bright Route',
      description: 'Collect 4 bright seeds in a run.',
      metric: TrailGoalMetric.brightFoodCollected,
      target: 4,
    ),
    TrailGoalDefinition(
      id: 'trail_crash_03',
      title: 'Rival Sweep',
      description: 'Make 3 bots crash in a run.',
      metric: TrailGoalMetric.botCrashes,
      target: 3,
    ),
    TrailGoalDefinition(
      id: 'trail_survive_90',
      title: 'Steady Hands',
      description: 'Survive for 90 seconds.',
      metric: TrailGoalMetric.survivalSeconds,
      target: 90,
    ),
    TrailGoalDefinition(
      id: 'trail_score_420',
      title: 'Glow Streak',
      description: 'Reach 420 points in a run.',
      metric: TrailGoalMetric.score,
      target: 420,
    ),
    TrailGoalDefinition(
      id: 'trail_seed_32',
      title: 'Arena Harvest',
      description: 'Collect 32 seeds in a run.',
      metric: TrailGoalMetric.foodCollected,
      target: 32,
    ),
    TrailGoalDefinition(
      id: 'trail_survive_120',
      title: 'Two Minute Trail',
      description: 'Survive for 120 seconds.',
      metric: TrailGoalMetric.survivalSeconds,
      target: 120,
    ),
    TrailGoalDefinition(
      id: 'trail_score_650',
      title: 'Arena Master',
      description: 'Reach 650 points in a run.',
      metric: TrailGoalMetric.score,
      target: 650,
    ),
  ];

  static TrailGoalDefinition? firstIncomplete(Set<String> completedIds) {
    for (final goal in goals) {
      if (!completedIds.contains(goal.id)) {
        return goal;
      }
    }
    return null;
  }

  static List<TrailGoalDefinition> nextIncomplete(
    Set<String> completedIds, {
    int count = 3,
  }) {
    return goals
        .where((goal) => !completedIds.contains(goal.id))
        .take(count)
        .toList(growable: false);
  }

  static List<TrailGoalDefinition> newlyCompleted(
    RunStats stats,
    Set<String> completedIds,
  ) {
    return goals
        .where(
          (goal) =>
              !completedIds.contains(goal.id) && goal.isCompletedBy(stats),
        )
        .toList(growable: false);
  }
}
