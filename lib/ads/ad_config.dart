import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdConfig {
  static const bool adsEnabled = bool.fromEnvironment(
    'ADMOB_ENABLED',
    defaultValue: false,
  );
  static const bool useTestAds = bool.fromEnvironment(
    'ADMOB_USE_TEST_ADS',
    defaultValue: true,
  );
  static const bool bannerEnabled = bool.fromEnvironment(
    'ADMOB_BANNER_ENABLED',
    defaultValue: true,
  );
  static const bool interstitialEnabled = bool.fromEnvironment(
    'ADMOB_INTERSTITIAL_ENABLED',
    defaultValue: true,
  );

  static const String _androidBannerTest =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _androidInterstitialTest =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _iosBannerTest = 'ca-app-pub-3940256099942544/2934735716';
  static const String _iosInterstitialTest =
      'ca-app-pub-3940256099942544/4411468910';

  static const String _androidBannerProd = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_AD_UNIT_ID',
  );
  static const String _androidInterstitialProd = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL_AD_UNIT_ID',
  );
  static const String _iosBannerProd = String.fromEnvironment(
    'ADMOB_IOS_BANNER_AD_UNIT_ID',
  );
  static const String _iosInterstitialProd = String.fromEnvironment(
    'ADMOB_IOS_INTERSTITIAL_AD_UNIT_ID',
  );

  static AdRequest get request => AdRequest(nonPersonalizedAds: true);

  static String? get bannerAdUnitId {
    if (!adsEnabled || !bannerEnabled) {
      return null;
    }
    if (useTestAds) {
      return Platform.isIOS ? _iosBannerTest : _androidBannerTest;
    }
    final adUnitId = Platform.isIOS ? _iosBannerProd : _androidBannerProd;
    return adUnitId.isEmpty ? null : adUnitId;
  }

  static String? get interstitialAdUnitId {
    if (!adsEnabled || !interstitialEnabled) {
      return null;
    }
    if (useTestAds) {
      return Platform.isIOS ? _iosInterstitialTest : _androidInterstitialTest;
    }
    final adUnitId = Platform.isIOS
        ? _iosInterstitialProd
        : _androidInterstitialProd;
    return adUnitId.isEmpty ? null : adUnitId;
  }
}
