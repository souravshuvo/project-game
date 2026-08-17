import 'dart:io';

class AdMobConfig {
  const AdMobConfig._();

  static const adsEnabled = bool.fromEnvironment(
    'ADS_ENABLED',
    defaultValue: false,
  );
  static const useTestAds = bool.fromEnvironment(
    'ADMOB_USE_TEST_ADS',
    defaultValue: true,
  );

  static const androidInterstitialId = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL_ID',
  );
  static const iosInterstitialId = String.fromEnvironment(
    'ADMOB_IOS_INTERSTITIAL_ID',
  );

  static const androidTestInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const iosTestInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  static String get runtimeMode {
    if (!adsEnabled) {
      return 'disabled';
    }
    return useTestAds ? 'test' : 'production';
  }

  static String get interstitialUnitId {
    if (!adsEnabled) {
      return '';
    }
    if (Platform.isAndroid) {
      return useTestAds
          ? androidTestInterstitialId
          : _productionInterstitialId(androidInterstitialId);
    }
    if (Platform.isIOS) {
      return useTestAds
          ? iosTestInterstitialId
          : _productionInterstitialId(iosInterstitialId);
    }
    return '';
  }

  static bool get hasInterstitialUnitId => interstitialUnitId.isNotEmpty;

  static String _productionInterstitialId(String candidate) {
    if (candidate.isEmpty ||
        candidate == androidTestInterstitialId ||
        candidate == iosTestInterstitialId) {
      return '';
    }
    return candidate;
  }
}
