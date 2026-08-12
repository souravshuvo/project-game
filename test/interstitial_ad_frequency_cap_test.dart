import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/application/interstitial_ad_frequency_cap.dart';

void main() {
  const cap = InterstitialAdFrequencyCap();
  final now = DateTime(2026, 8, 12, 12);

  test('blocks interstitials during active gameplay', () {
    final decision = cap.evaluate(
      completedMatchesThisSession: 10,
      adsShownThisSession: 0,
      now: now,
      lastShownAt: null,
      isActiveGameplay: true,
      isAdLoaded: true,
      isAdShowing: false,
    );

    expect(decision.canShow, isFalse);
    expect(decision.reason, 'active_gameplay');
  });

  test('requires warmup matches before the first interstitial', () {
    final decision = cap.evaluate(
      completedMatchesThisSession: 2,
      adsShownThisSession: 0,
      now: now,
      lastShownAt: null,
      isActiveGameplay: false,
      isAdLoaded: true,
      isAdShowing: false,
    );

    expect(decision.canShow, isFalse);
    expect(decision.reason, 'warmup_cap');
  });

  test('blocks when no ad is loaded', () {
    final decision = cap.evaluate(
      completedMatchesThisSession: 3,
      adsShownThisSession: 0,
      now: now,
      lastShownAt: null,
      isActiveGameplay: false,
      isAdLoaded: false,
      isAdShowing: false,
    );

    expect(decision.canShow, isFalse);
    expect(decision.reason, 'not_loaded');
  });

  test('enforces session and interval caps', () {
    final intervalDecision = cap.evaluate(
      completedMatchesThisSession: 4,
      adsShownThisSession: 1,
      now: now,
      lastShownAt: now.subtract(const Duration(minutes: 5)),
      isActiveGameplay: false,
      isAdLoaded: true,
      isAdShowing: false,
    );
    final sessionDecision = cap.evaluate(
      completedMatchesThisSession: 10,
      adsShownThisSession: 3,
      now: now,
      lastShownAt: now.subtract(const Duration(minutes: 10)),
      isActiveGameplay: false,
      isAdLoaded: true,
      isAdShowing: false,
    );

    expect(intervalDecision.canShow, isFalse);
    expect(intervalDecision.reason, 'interval_cap');
    expect(sessionDecision.canShow, isFalse);
    expect(sessionDecision.reason, 'session_cap');
  });

  test('allows after warmup when loaded, idle, and under caps', () {
    final decision = cap.evaluate(
      completedMatchesThisSession: 3,
      adsShownThisSession: 0,
      now: now,
      lastShownAt: null,
      isActiveGameplay: false,
      isAdLoaded: true,
      isAdShowing: false,
    );

    expect(decision.canShow, isTrue);
    expect(decision.reason, 'ok');
  });
}
