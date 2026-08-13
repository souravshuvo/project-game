class RunStats {
  const RunStats({
    this.score = 0,
    this.survivalSeconds = 0,
    this.foodCollected = 0,
    this.brightFoodCollected = 0,
    this.botCrashes = 0,
    this.trailLength = 0,
  });

  static const empty = RunStats();

  final int score;
  final double survivalSeconds;
  final int foodCollected;
  final int brightFoodCollected;
  final int botCrashes;
  final double trailLength;

  RunStats copyWith({
    int? score,
    double? survivalSeconds,
    int? foodCollected,
    int? brightFoodCollected,
    int? botCrashes,
    double? trailLength,
  }) {
    return RunStats(
      score: score ?? this.score,
      survivalSeconds: survivalSeconds ?? this.survivalSeconds,
      foodCollected: foodCollected ?? this.foodCollected,
      brightFoodCollected: brightFoodCollected ?? this.brightFoodCollected,
      botCrashes: botCrashes ?? this.botCrashes,
      trailLength: trailLength ?? this.trailLength,
    );
  }
}
