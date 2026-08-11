class AnalyticsService {
  const AnalyticsService();

  void runStarted({required int bestScoreBefore}) {}

  void runEnded({
    required int score,
    required int bestScore,
    required String deathReason,
  }) {}

  void restartTapped({required int previousScore}) {}
}
