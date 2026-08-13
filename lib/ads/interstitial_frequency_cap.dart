class InterstitialDecision {
  const InterstitialDecision({required this.allowed, required this.reason});

  final bool allowed;
  final String reason;
}

class InterstitialFrequencyCap {
  InterstitialFrequencyCap({
    this.firstEligibleCompletion = 4,
    this.completionInterval = 3,
    this.minimumGap = const Duration(minutes: 2),
  });

  final int firstEligibleCompletion;
  final int completionInterval;
  final Duration minimumGap;

  DateTime? _lastShownAt;

  InterstitialDecision evaluate({
    required int completedChallenges,
    required DateTime now,
  }) {
    if (completedChallenges < firstEligibleCompletion) {
      return const InterstitialDecision(
        allowed: false,
        reason: 'before_first_eligible_completion',
      );
    }

    if ((completedChallenges - firstEligibleCompletion) % completionInterval !=
        0) {
      return const InterstitialDecision(
        allowed: false,
        reason: 'completion_interval',
      );
    }

    final lastShownAt = _lastShownAt;
    if (lastShownAt != null && now.difference(lastShownAt) < minimumGap) {
      return const InterstitialDecision(
        allowed: false,
        reason: 'minimum_time_gap',
      );
    }

    return const InterstitialDecision(allowed: true, reason: 'allowed');
  }

  void recordShown(DateTime now) {
    _lastShownAt = now;
  }
}
