import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/application/ad_frequency_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('blocks interstitials before enough level transitions', () {
    const policy = InterstitialFrequencyPolicy();
    final now = DateTime(2026, 8, 14, 12);
    final state = InterstitialFrequencyState.initial()
        .recordLevelTransition()
        .recordLevelTransition();

    final decision = policy.evaluate(state: state, now: now);

    expect(decision.canShow, isFalse);
    expect(decision.reason, 'level_spacing');
  });

  test('allows first interstitial after the configured transition count', () {
    const policy = InterstitialFrequencyPolicy();
    final now = DateTime(2026, 8, 14, 12);
    final state = InterstitialFrequencyState.initial()
        .recordLevelTransition()
        .recordLevelTransition()
        .recordLevelTransition();

    final decision = policy.evaluate(state: state, now: now);

    expect(decision.canShow, isTrue);
    expect(decision.reason, 'eligible');
  });

  test('blocks interstitials inside the minimum time window', () {
    const policy = InterstitialFrequencyPolicy();
    final now = DateTime(2026, 8, 14, 12);
    final state = InterstitialFrequencyState.initial()
        .recordLevelTransition()
        .recordLevelTransition()
        .recordLevelTransition()
        .recordInterstitialShown(now.subtract(const Duration(minutes: 1)))
        .recordLevelTransition()
        .recordLevelTransition()
        .recordLevelTransition();

    final decision = policy.evaluate(state: state, now: now);

    expect(decision.canShow, isFalse);
    expect(decision.reason, 'time_spacing');
  });

  test('blocks interstitials after the session cap', () {
    const policy = InterstitialFrequencyPolicy(maxInterstitialsPerSession: 1);
    final now = DateTime(2026, 8, 14, 12);
    final state = InterstitialFrequencyState.initial()
        .recordLevelTransition()
        .recordLevelTransition()
        .recordLevelTransition()
        .recordInterstitialShown(now.subtract(const Duration(minutes: 5)))
        .recordLevelTransition()
        .recordLevelTransition()
        .recordLevelTransition();

    final decision = policy.evaluate(state: state, now: now);

    expect(decision.canShow, isFalse);
    expect(decision.reason, 'session_cap');
  });
}
