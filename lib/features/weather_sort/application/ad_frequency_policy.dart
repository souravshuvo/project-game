class InterstitialFrequencyState {
  const InterstitialFrequencyState({
    required this.completedLevelTransitionsSinceInterstitial,
    required this.lastInterstitialShownAtMillis,
    required this.sessionInterstitialShowCount,
  });

  factory InterstitialFrequencyState.initial() {
    return const InterstitialFrequencyState(
      completedLevelTransitionsSinceInterstitial: 0,
      lastInterstitialShownAtMillis: null,
      sessionInterstitialShowCount: 0,
    );
  }

  final int completedLevelTransitionsSinceInterstitial;
  final int? lastInterstitialShownAtMillis;
  final int sessionInterstitialShowCount;

  DateTime? get lastInterstitialShownAt {
    final millis = lastInterstitialShownAtMillis;
    if (millis == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  InterstitialFrequencyState copyWith({
    int? completedLevelTransitionsSinceInterstitial,
    int? lastInterstitialShownAtMillis,
    int? sessionInterstitialShowCount,
  }) {
    return InterstitialFrequencyState(
      completedLevelTransitionsSinceInterstitial:
          completedLevelTransitionsSinceInterstitial ??
          this.completedLevelTransitionsSinceInterstitial,
      lastInterstitialShownAtMillis:
          lastInterstitialShownAtMillis ?? this.lastInterstitialShownAtMillis,
      sessionInterstitialShowCount:
          sessionInterstitialShowCount ?? this.sessionInterstitialShowCount,
    );
  }

  InterstitialFrequencyState recordLevelTransition() {
    return copyWith(
      completedLevelTransitionsSinceInterstitial:
          completedLevelTransitionsSinceInterstitial + 1,
    );
  }

  InterstitialFrequencyState recordInterstitialShown(DateTime shownAt) {
    return InterstitialFrequencyState(
      completedLevelTransitionsSinceInterstitial: 0,
      lastInterstitialShownAtMillis: shownAt.millisecondsSinceEpoch,
      sessionInterstitialShowCount: sessionInterstitialShowCount + 1,
    );
  }
}

class InterstitialFrequencyDecision {
  const InterstitialFrequencyDecision({
    required this.canShow,
    required this.reason,
  });

  final bool canShow;
  final String reason;
}

class InterstitialFrequencyPolicy {
  const InterstitialFrequencyPolicy({
    this.firstAdAfterCompletedTransitions = 3,
    this.completedTransitionsBetweenAds = 3,
    this.minimumTimeBetweenAds = const Duration(minutes: 3),
    this.maxInterstitialsPerSession = 4,
  });

  final int firstAdAfterCompletedTransitions;
  final int completedTransitionsBetweenAds;
  final Duration minimumTimeBetweenAds;
  final int maxInterstitialsPerSession;

  InterstitialFrequencyDecision evaluate({
    required InterstitialFrequencyState state,
    required DateTime now,
  }) {
    if (state.sessionInterstitialShowCount >= maxInterstitialsPerSession) {
      return const InterstitialFrequencyDecision(
        canShow: false,
        reason: 'session_cap',
      );
    }

    final requiredTransitions = state.lastInterstitialShownAt == null
        ? firstAdAfterCompletedTransitions
        : completedTransitionsBetweenAds;
    if (state.completedLevelTransitionsSinceInterstitial <
        requiredTransitions) {
      return const InterstitialFrequencyDecision(
        canShow: false,
        reason: 'level_spacing',
      );
    }

    final lastShownAt = state.lastInterstitialShownAt;
    if (lastShownAt != null &&
        now.difference(lastShownAt) < minimumTimeBetweenAds) {
      return const InterstitialFrequencyDecision(
        canShow: false,
        reason: 'time_spacing',
      );
    }

    return const InterstitialFrequencyDecision(
      canShow: true,
      reason: 'eligible',
    );
  }
}
