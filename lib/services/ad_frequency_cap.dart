class InterstitialAdDecision {
  const InterstitialAdDecision._(this.canShow, this.reason);

  const InterstitialAdDecision.allow() : this._(true, 'allowed');

  const InterstitialAdDecision.block(String reason) : this._(false, reason);

  final bool canShow;
  final String reason;
}

class InterstitialFrequencyCap {
  InterstitialFrequencyCap({
    this.minCompletedMatches = 2,
    this.minMatchesBetweenShows = 2,
    this.minSecondsBetweenShows = 300,
    this.maxShowsPerSession = 3,
  });

  final int minCompletedMatches;
  final int minMatchesBetweenShows;
  final int minSecondsBetweenShows;
  final int maxShowsPerSession;

  int _completedMatches = 0;
  int _matchesSinceLastShow = 0;
  int _showsThisSession = 0;
  DateTime? _lastShownAt;

  int get completedMatches => _completedMatches;
  int get matchesSinceLastShow => _matchesSinceLastShow;
  int get showsThisSession => _showsThisSession;

  void recordMatchCompleted() {
    _completedMatches++;
    _matchesSinceLastShow++;
  }

  InterstitialAdDecision evaluate({
    required DateTime now,
    required bool adsEnabled,
    required bool adReady,
    required bool safeBreak,
  }) {
    if (!adsEnabled) {
      return const InterstitialAdDecision.block('ads_disabled');
    }

    if (!safeBreak) {
      return const InterstitialAdDecision.block('not_safe_break');
    }

    if (!adReady) {
      return const InterstitialAdDecision.block('ad_not_ready');
    }

    if (_completedMatches < minCompletedMatches) {
      return const InterstitialAdDecision.block('too_few_matches');
    }

    if (_matchesSinceLastShow < minMatchesBetweenShows) {
      return const InterstitialAdDecision.block('match_gap');
    }

    if (_showsThisSession >= maxShowsPerSession) {
      return const InterstitialAdDecision.block('session_cap');
    }

    final lastShownAt = _lastShownAt;
    if (lastShownAt != null &&
        now.difference(lastShownAt).inSeconds < minSecondsBetweenShows) {
      return const InterstitialAdDecision.block('cooldown');
    }

    return const InterstitialAdDecision.allow();
  }

  void recordShown(DateTime now) {
    _showsThisSession++;
    _matchesSinceLastShow = 0;
    _lastShownAt = now;
  }
}
