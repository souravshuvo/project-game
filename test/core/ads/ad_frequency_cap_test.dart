import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/core/ads/ad_config.dart';
import 'package:rapid_jump/core/ads/ad_frequency_cap.dart';

void main() {
  test('interstitial cap blocks first ad until enough completions', () {
    final cap = InterstitialFrequencyCap(now: () => DateTime(2026));

    expect(cap.evaluate().allowed, isFalse);
    expect(cap.evaluate().reason, 'first_ad_cap');

    cap.recordGameCompletion();
    expect(cap.evaluate().allowed, isFalse);

    cap.recordGameCompletion();
    expect(cap.evaluate().allowed, isTrue);
  });

  test('interstitial cap enforces completion, time, and session limits', () {
    var now = DateTime(2026);
    final cap = InterstitialFrequencyCap(maxPerSession: 2, now: () => now);

    cap
      ..recordGameCompletion()
      ..recordGameCompletion();
    expect(cap.evaluate().allowed, isTrue);

    cap.recordInterstitialShown();
    cap
      ..recordGameCompletion()
      ..recordGameCompletion();
    expect(cap.evaluate().allowed, isFalse);
    expect(cap.evaluate().reason, 'time_cap');

    now = now.add(const Duration(minutes: 4));
    expect(cap.evaluate().allowed, isTrue);

    cap.recordInterstitialShown();
    cap
      ..recordGameCompletion()
      ..recordGameCompletion();
    now = now.add(const Duration(minutes: 4));
    expect(cap.evaluate().allowed, isFalse);
    expect(cap.evaluate().reason, 'session_cap');
  });

  test('ad config separates test and release behavior', () {
    final debugConfig = AdMobConfig.fromEnvironment(
      platform: AdPlatform.android,
      isRelease: false,
    );
    expect(debugConfig.mode, AdMobMode.test);
    expect(debugConfig.servesAds, isTrue);
    expect(debugConfig.bannerAdUnitId, AdMobConfig.androidTestBannerAdUnitId);

    final releaseConfig = AdMobConfig.fromEnvironment(
      platform: AdPlatform.android,
      isRelease: true,
    );
    expect(releaseConfig.mode, AdMobMode.disabled);
    expect(releaseConfig.servesAds, isFalse);
    expect(releaseConfig.disabledReason, 'release_test_ads_disabled');
  });
}
