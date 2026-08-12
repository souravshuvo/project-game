class InterstitialAdDecision {
  const InterstitialAdDecision._({required this.canShow, required this.reason});

  const InterstitialAdDecision.allow() : this._(canShow: true, reason: 'ok');

  const InterstitialAdDecision.block(String reason)
    : this._(canShow: false, reason: reason);

  final bool canShow;
  final String reason;
}

class InterstitialAdFrequencyCap {
  const InterstitialAdFrequencyCap({
    this.completedMatchesBeforeFirstAd = 3,
    this.maxAdsPerSession = 3,
    this.minInterval = const Duration(minutes: 6),
  });

  final int completedMatchesBeforeFirstAd;
  final int maxAdsPerSession;
  final Duration minInterval;

  InterstitialAdDecision evaluate({
    required int completedMatchesThisSession,
    required int adsShownThisSession,
    required DateTime now,
    required DateTime? lastShownAt,
    required bool isActiveGameplay,
    required bool isAdLoaded,
    required bool isAdShowing,
  }) {
    if (isActiveGameplay) {
      return const InterstitialAdDecision.block('active_gameplay');
    }
    if (isAdShowing) {
      return const InterstitialAdDecision.block('ad_already_showing');
    }
    if (completedMatchesThisSession < completedMatchesBeforeFirstAd) {
      return const InterstitialAdDecision.block('warmup_cap');
    }
    if (adsShownThisSession >= maxAdsPerSession) {
      return const InterstitialAdDecision.block('session_cap');
    }
    if (!isAdLoaded) {
      return const InterstitialAdDecision.block('not_loaded');
    }
    if (lastShownAt != null && now.difference(lastShownAt) < minInterval) {
      return const InterstitialAdDecision.block('interval_cap');
    }

    return const InterstitialAdDecision.allow();
  }
}
