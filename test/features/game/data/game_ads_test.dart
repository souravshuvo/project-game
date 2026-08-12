import 'package:flutter_test/flutter_test.dart';
import 'package:project_game/features/game/data/game_ads.dart';

void main() {
  test('ad frequency tracker caps interstitial cadence', () {
    final tracker = AdFrequencyTracker(
      cap: const AdFrequencyCap(
        minFinishedLevelsBeforeFirstInterstitial: 2,
        minFinishedLevelsBetweenInterstitials: 3,
        minSecondsBetweenInterstitials: 180,
        maxInterstitialsPerSession: 2,
      ),
    );
    final now = DateTime(2026, 1, 1, 12);

    tracker.recordLevelEnd();
    expect(tracker.skipReason(now), 'early_session');

    tracker.recordLevelEnd();
    expect(tracker.skipReason(now), 'level_frequency_cap');

    tracker.recordLevelEnd();
    expect(tracker.skipReason(now), isNull);

    tracker.recordInterstitialShown(now);
    tracker
      ..recordLevelEnd()
      ..recordLevelEnd()
      ..recordLevelEnd();
    expect(
      tracker.skipReason(now.add(const Duration(seconds: 60))),
      'time_frequency_cap',
    );

    expect(tracker.skipReason(now.add(const Duration(seconds: 181))), isNull);
    tracker.recordInterstitialShown(now.add(const Duration(seconds: 181)));

    tracker
      ..recordLevelEnd()
      ..recordLevelEnd()
      ..recordLevelEnd();
    expect(
      tracker.skipReason(now.add(const Duration(seconds: 400))),
      'session_cap',
    );
  });
}
