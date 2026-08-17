import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/shared/ads/ad_mob_service.dart';
import 'package:rapid_jump/shared/analytics/game_analytics.dart';

void main() {
  test(
    'does not attempt to show interstitials when ads are disabled',
    () async {
      final service = AdMobGameAdService(analytics: const NoopGameAnalytics());

      expect(
        await service.showInterstitialIfAvailable(placement: 'unit_test'),
        isFalse,
      );
    },
  );
}
