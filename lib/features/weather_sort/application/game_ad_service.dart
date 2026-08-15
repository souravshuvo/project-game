abstract interface class GameAdService {
  Future<void> initialize();

  void preloadLevelEndInterstitial();

  Future<bool> maybeShowLevelEndInterstitial({
    required int levelId,
    required int levelNumber,
  });

  void dispose();
}

final class NoOpGameAdService implements GameAdService {
  const NoOpGameAdService();

  @override
  Future<void> initialize() async {}

  @override
  void preloadLevelEndInterstitial() {}

  @override
  Future<bool> maybeShowLevelEndInterstitial({
    required int levelId,
    required int levelNumber,
  }) async {
    return false;
  }

  @override
  void dispose() {}
}
