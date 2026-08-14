class AdFrequencyCap {
  AdFrequencyCap({
    this.minimumCompletedLevelsBetweenAds = 3,
    this.minimumLevelNumber = 4,
    this.minimumTimeBetweenAds = const Duration(minutes: 4),
  });

  final int minimumCompletedLevelsBetweenAds;
  final int minimumLevelNumber;
  final Duration minimumTimeBetweenAds;

  int _completedLevelsSinceInterstitial = 0;
  DateTime? _lastInterstitialAt;

  AdCapDecision registerLevelEnd({
    required int levelNumber,
    required bool completed,
    required DateTime now,
  }) {
    if (!completed) {
      return AdCapDecision.blocked(
        reason: 'failed_level',
        completedLevelsSinceAd: _completedLevelsSinceInterstitial,
      );
    }

    _completedLevelsSinceInterstitial++;

    if (levelNumber < minimumLevelNumber) {
      return AdCapDecision.blocked(
        reason: 'early_level',
        completedLevelsSinceAd: _completedLevelsSinceInterstitial,
      );
    }

    if (_completedLevelsSinceInterstitial < minimumCompletedLevelsBetweenAds) {
      return AdCapDecision.blocked(
        reason: 'level_frequency',
        completedLevelsSinceAd: _completedLevelsSinceInterstitial,
      );
    }

    final lastInterstitialAt = _lastInterstitialAt;
    if (lastInterstitialAt != null &&
        now.difference(lastInterstitialAt) < minimumTimeBetweenAds) {
      return AdCapDecision.blocked(
        reason: 'time_frequency',
        completedLevelsSinceAd: _completedLevelsSinceInterstitial,
      );
    }

    return AdCapDecision.allowed(
      completedLevelsSinceAd: _completedLevelsSinceInterstitial,
    );
  }

  void recordInterstitialShown(DateTime now) {
    _completedLevelsSinceInterstitial = 0;
    _lastInterstitialAt = now;
  }
}

class AdCapDecision {
  const AdCapDecision._({
    required this.allowed,
    required this.reason,
    required this.completedLevelsSinceAd,
  });

  factory AdCapDecision.allowed({required int completedLevelsSinceAd}) {
    return AdCapDecision._(
      allowed: true,
      reason: 'allowed',
      completedLevelsSinceAd: completedLevelsSinceAd,
    );
  }

  factory AdCapDecision.blocked({
    required String reason,
    required int completedLevelsSinceAd,
  }) {
    return AdCapDecision._(
      allowed: false,
      reason: reason,
      completedLevelsSinceAd: completedLevelsSinceAd,
    );
  }

  final bool allowed;
  final String reason;
  final int completedLevelsSinceAd;
}
