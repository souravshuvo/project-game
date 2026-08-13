import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/services/ad_frequency_cap.dart';

void main() {
  test('blocks interstitials before the first eligible transition', () {
    final cap = AdFrequencyCap();
    final now = DateTime(2026, 8, 13, 12);

    expect(
      cap.canShowInterstitial(
        completedRuns: 1,
        routeCompleted: false,
        now: now,
        lastShownAt: null,
      ),
      false,
    );
    expect(
      cap.canShowInterstitial(
        completedRuns: 4,
        routeCompleted: false,
        now: now,
        lastShownAt: null,
      ),
      true,
    );
  });

  test('blocks interstitials on route completion and recent show', () {
    final cap = AdFrequencyCap();
    final now = DateTime(2026, 8, 13, 12);

    expect(
      cap.canShowInterstitial(
        completedRuns: 4,
        routeCompleted: true,
        now: now,
        lastShownAt: null,
      ),
      false,
    );
    expect(
      cap.canShowInterstitial(
        completedRuns: 8,
        routeCompleted: false,
        now: now,
        lastShownAt: now.subtract(const Duration(minutes: 2)),
      ),
      false,
    );
  });
}
