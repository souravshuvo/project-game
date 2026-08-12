abstract interface class GameAdService {
  Future<void> warmUp();

  void recordLevelEnd({required bool won});

  Future<bool> showInterstitialIfAvailable({required String placement});

  Future<void> dispose();
}

class NoopGameAdService implements GameAdService {
  const NoopGameAdService();

  @override
  Future<void> warmUp() async {}

  @override
  void recordLevelEnd({required bool won}) {}

  @override
  Future<bool> showInterstitialIfAvailable({required String placement}) async {
    return false;
  }

  @override
  Future<void> dispose() async {}
}
