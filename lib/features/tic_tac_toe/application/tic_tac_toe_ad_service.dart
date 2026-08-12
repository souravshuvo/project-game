typedef AdSafetyCheck = bool Function();

abstract interface class TicTacToeAdService {
  bool get usesTestAds;

  Future<void> initialize();

  Future<void> preloadInterstitial();

  Future<void> onMatchCompleted({
    required int completedMatchesThisSession,
    required AdSafetyCheck canShowNow,
  });

  void dispose();
}

final class NoOpTicTacToeAdService implements TicTacToeAdService {
  const NoOpTicTacToeAdService();

  @override
  bool get usesTestAds => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> preloadInterstitial() async {}

  @override
  Future<void> onMatchCompleted({
    required int completedMatchesThisSession,
    required AdSafetyCheck canShowNow,
  }) async {}

  @override
  void dispose() {}
}
