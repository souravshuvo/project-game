import 'package:flutter/foundation.dart';

class AdMobConfig {
  const AdMobConfig._();

  static const enabled = bool.fromEnvironment(
    'ADMOB_ENABLED',
    defaultValue: true,
  );
  static const useProductionAds = bool.fromEnvironment(
    'ADMOB_USE_PRODUCTION',
    defaultValue: false,
  );

  static const _androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const _iosTestInterstitial = 'ca-app-pub-3940256099942544/4411468910';

  static const _androidProductionInterstitial = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL_ID',
  );
  static const _iosProductionInterstitial = String.fromEnvironment(
    'ADMOB_IOS_INTERSTITIAL_ID',
  );

  static String get environment => useProductionAds ? 'production' : 'test';

  static String? get interstitialAdUnitId {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _adUnitIdForPlatform(
        productionId: _androidProductionInterstitial,
        testId: _androidTestInterstitial,
      ),
      TargetPlatform.iOS => _adUnitIdForPlatform(
        productionId: _iosProductionInterstitial,
        testId: _iosTestInterstitial,
      ),
      _ => null,
    };
  }

  static String? _adUnitIdForPlatform({
    required String productionId,
    required String testId,
  }) {
    if (!useProductionAds) {
      return testId;
    }
    return productionId.isEmpty ? null : productionId;
  }
}
