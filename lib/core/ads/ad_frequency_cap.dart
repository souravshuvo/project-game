class InterstitialDecision {
  const InterstitialDecision.allow() : allowed = true, reason = 'allowed';

  const InterstitialDecision.block(this.reason) : allowed = false;

  final bool allowed;
  final String reason;
}

class InterstitialFrequencyCap {
  InterstitialFrequencyCap({
    this.completionsBeforeFirstAd = 2,
    this.completionsBetweenAds = 2,
    this.minimumInterval = const Duration(minutes: 4),
    this.maxPerSession = 3,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final int completionsBeforeFirstAd;
  final int completionsBetweenAds;
  final Duration minimumInterval;
  final int maxPerSession;
  final DateTime Function() _now;

  int _completionsSinceLastInterstitial = 0;
  int _shownThisSession = 0;
  DateTime? _lastShownAt;

  int get completionsSinceLastInterstitial => _completionsSinceLastInterstitial;

  int get shownThisSession => _shownThisSession;

  void recordGameCompletion() {
    _completionsSinceLastInterstitial += 1;
  }

  InterstitialDecision evaluate() {
    if (maxPerSession <= 0) {
      return const InterstitialDecision.block('session_cap_zero');
    }
    if (_shownThisSession >= maxPerSession) {
      return const InterstitialDecision.block('session_cap');
    }

    final requiredCompletions = _shownThisSession == 0
        ? completionsBeforeFirstAd
        : completionsBetweenAds;
    if (_completionsSinceLastInterstitial < requiredCompletions) {
      return InterstitialDecision.block(
        _shownThisSession == 0 ? 'first_ad_cap' : 'completion_cap',
      );
    }

    final lastShownAt = _lastShownAt;
    if (lastShownAt != null &&
        _now().difference(lastShownAt) < minimumInterval) {
      return const InterstitialDecision.block('time_cap');
    }

    return const InterstitialDecision.allow();
  }

  void recordInterstitialShown() {
    _shownThisSession += 1;
    _completionsSinceLastInterstitial = 0;
    _lastShownAt = _now();
  }
}
