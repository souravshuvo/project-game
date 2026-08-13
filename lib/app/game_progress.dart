class GameProgress {
  const GameProgress({
    this.highestUnlockedChallengeIndex = 0,
    this.completedCount = 0,
    this.totalStars = 0,
    this.bestStarsByChallenge = const <int, int>{},
  });

  final int highestUnlockedChallengeIndex;
  final int completedCount;
  final int totalStars;
  final Map<int, int> bestStarsByChallenge;

  bool get hasProgress => completedCount > 0 || totalStars > 0;

  int bestStarsFor(int challengeId) {
    return bestStarsByChallenge[challengeId] ?? 0;
  }

  GameProgress recordGoal({
    required int challengeId,
    required int challengeIndex,
    required int attempt,
    required int totalChallenges,
  }) {
    final stars = starsForAttempt(attempt);
    final nextBest = Map<int, int>.from(bestStarsByChallenge);
    final previousBest = nextBest[challengeId] ?? 0;
    if (stars > previousBest) {
      nextBest[challengeId] = stars;
    }

    final completed = nextBest.length.clamp(0, totalChallenges).toInt();
    final nextUnlocked = (challengeIndex + 1)
        .clamp(0, totalChallenges - 1)
        .toInt();

    return GameProgress(
      highestUnlockedChallengeIndex: nextUnlocked,
      completedCount: completed,
      totalStars: nextBest.values.fold<int>(0, (sum, value) => sum + value),
      bestStarsByChallenge: nextBest,
    );
  }

  static int starsForAttempt(int attempt) {
    if (attempt <= 1) {
      return 3;
    }
    if (attempt <= 3) {
      return 2;
    }
    return 1;
  }
}
