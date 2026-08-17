import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/shared/ads/ad_frequency_cap.dart';

void main() {
  test('blocks interstitials until enough level ends have happened', () {
    final gate = AdFrequencyCap();
    final now = DateTime(2026);

    expect(gate.evaluate(now).canShow, isFalse);

    gate.recordLevelEnd(won: true);
    gate.recordLevelEnd(won: false);

    final blocked = gate.evaluate(now);
    expect(blocked.canShow, isFalse);
    expect(blocked.reason, 'level_end_cap');

    gate.recordLevelEnd(won: true);

    final allowed = gate.evaluate(now);
    expect(allowed.canShow, isTrue);
    expect(allowed.levelEndsSinceInterstitial, 3);
  });

  test('resets after an interstitial and enforces the time cap', () {
    final gate = AdFrequencyCap(
      minInterstitialInterval: const Duration(minutes: 3),
    );
    final shownAt = DateTime(2026);

    gate.recordLevelEnd(won: true);
    gate.recordLevelEnd(won: true);
    gate.recordLevelEnd(won: true);
    gate.recordInterstitialShown(shownAt);

    expect(gate.levelEndsSinceInterstitial, 0);

    gate.recordLevelEnd(won: true);
    gate.recordLevelEnd(won: true);
    gate.recordLevelEnd(won: true);

    final tooSoon = gate.evaluate(shownAt.add(const Duration(minutes: 2)));
    expect(tooSoon.canShow, isFalse);
    expect(tooSoon.reason, 'time_cap');

    final later = gate.evaluate(shownAt.add(const Duration(minutes: 3)));
    expect(later.canShow, isTrue);
  });
}
