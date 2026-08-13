class AdFrequencyCap {
  const AdFrequencyCap({
    this.minRunsBeforeInterstitial = 2,
    this.runsBetweenInterstitials = 4,
    this.minInterval = const Duration(minutes: 3),
  });

  final int minRunsBeforeInterstitial;
  final int runsBetweenInterstitials;
  final Duration minInterval;

  bool canShowInterstitial({
    required int completedRuns,
    required bool routeCompleted,
    required DateTime now,
    required DateTime? lastShownAt,
  }) {
    if (routeCompleted) {
      return false;
    }

    if (completedRuns < minRunsBeforeInterstitial) {
      return false;
    }

    if (completedRuns % runsBetweenInterstitials != 0) {
      return false;
    }

    if (lastShownAt != null && now.difference(lastShownAt) < minInterval) {
      return false;
    }

    return true;
  }
}
