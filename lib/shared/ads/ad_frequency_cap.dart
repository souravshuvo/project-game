class AdFrequencyCap {
  AdFrequencyCap({
    this.minLevelEndsBetweenInterstitials = 3,
    this.minInterstitialInterval = const Duration(minutes: 3),
  }) : assert(minLevelEndsBetweenInterstitials > 0);

  final int minLevelEndsBetweenInterstitials;
  final Duration minInterstitialInterval;

  DateTime? _lastInterstitialShownAt;
  int _levelEndsSinceInterstitial = 0;

  int get levelEndsSinceInterstitial => _levelEndsSinceInterstitial;

  int secondsSinceLastInterstitial(DateTime now) {
    final lastShownAt = _lastInterstitialShownAt;
    if (lastShownAt == null) {
      return -1;
    }
    return now.difference(lastShownAt).inSeconds;
  }

  void recordLevelEnd({required bool won}) {
    _levelEndsSinceInterstitial++;
  }

  void recordInterstitialShown(DateTime shownAt) {
    _lastInterstitialShownAt = shownAt;
    _levelEndsSinceInterstitial = 0;
  }

  InterstitialAdGateDecision evaluate(DateTime now) {
    if (_levelEndsSinceInterstitial < minLevelEndsBetweenInterstitials) {
      return InterstitialAdGateDecision.blocked(
        reason: 'level_end_cap',
        levelEndsSinceInterstitial: _levelEndsSinceInterstitial,
        secondsSinceLastInterstitial: secondsSinceLastInterstitial(now),
      );
    }

    final lastShownAt = _lastInterstitialShownAt;
    if (lastShownAt != null &&
        now.difference(lastShownAt) < minInterstitialInterval) {
      return InterstitialAdGateDecision.blocked(
        reason: 'time_cap',
        levelEndsSinceInterstitial: _levelEndsSinceInterstitial,
        secondsSinceLastInterstitial: secondsSinceLastInterstitial(now),
      );
    }

    return InterstitialAdGateDecision.allowed(
      levelEndsSinceInterstitial: _levelEndsSinceInterstitial,
      secondsSinceLastInterstitial: secondsSinceLastInterstitial(now),
    );
  }
}

class InterstitialAdGateDecision {
  const InterstitialAdGateDecision._({
    required this.canShow,
    required this.levelEndsSinceInterstitial,
    required this.secondsSinceLastInterstitial,
    this.reason,
  });

  factory InterstitialAdGateDecision.allowed({
    required int levelEndsSinceInterstitial,
    required int secondsSinceLastInterstitial,
  }) {
    return InterstitialAdGateDecision._(
      canShow: true,
      levelEndsSinceInterstitial: levelEndsSinceInterstitial,
      secondsSinceLastInterstitial: secondsSinceLastInterstitial,
    );
  }

  factory InterstitialAdGateDecision.blocked({
    required String reason,
    required int levelEndsSinceInterstitial,
    required int secondsSinceLastInterstitial,
  }) {
    return InterstitialAdGateDecision._(
      canShow: false,
      reason: reason,
      levelEndsSinceInterstitial: levelEndsSinceInterstitial,
      secondsSinceLastInterstitial: secondsSinceLastInterstitial,
    );
  }

  final bool canShow;
  final String? reason;
  final int levelEndsSinceInterstitial;
  final int secondsSinceLastInterstitial;
}
