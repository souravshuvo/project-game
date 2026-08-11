import 'package:flutter/foundation.dart';

enum AdsEnvironment { test, production }

class AppRuntimeConfig {
  const AppRuntimeConfig._();

  static const firebaseEnabled = bool.fromEnvironment(
    'ARROW_PUZZLE_FIREBASE_ENABLED',
    defaultValue: true,
  );

  static const crashlyticsEnabled = bool.fromEnvironment(
    'ARROW_PUZZLE_CRASHLYTICS_ENABLED',
    defaultValue: true,
  );

  static const adsEnabled = bool.fromEnvironment(
    'ARROW_PUZZLE_ADS_ENABLED',
    defaultValue: true,
  );

  static const _adsEnvironmentName = String.fromEnvironment(
    'ARROW_PUZZLE_ADS_ENV',
    defaultValue: 'test',
  );

  static AdsEnvironment get adsEnvironment {
    return _adsEnvironmentName == 'production'
        ? AdsEnvironment.production
        : AdsEnvironment.test;
  }

  static bool get isSupportedMobilePlatform {
    return _isAndroid || _isIOS;
  }

  static bool get usesTestAds => adsEnvironment == AdsEnvironment.test;

  static String get bannerAdUnitId {
    if (usesTestAds) {
      return _isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }

    return _isAndroid
        ? const String.fromEnvironment('ADMOB_ANDROID_BANNER_UNIT_ID')
        : const String.fromEnvironment('ADMOB_IOS_BANNER_UNIT_ID');
  }

  static String get interstitialAdUnitId {
    if (usesTestAds) {
      return _isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }

    return _isAndroid
        ? const String.fromEnvironment('ADMOB_ANDROID_INTERSTITIAL_UNIT_ID')
        : const String.fromEnvironment('ADMOB_IOS_INTERSTITIAL_UNIT_ID');
  }

  static String get rewardedAdUnitId {
    if (usesTestAds) {
      return _isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';
    }

    return _isAndroid
        ? const String.fromEnvironment('ADMOB_ANDROID_REWARDED_UNIT_ID')
        : const String.fromEnvironment('ADMOB_IOS_REWARDED_UNIT_ID');
  }

  static bool get hasUsableAdUnitIds {
    return bannerAdUnitId.isNotEmpty &&
        interstitialAdUnitId.isNotEmpty &&
        rewardedAdUnitId.isNotEmpty;
  }

  static bool get _isAndroid {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  static bool get _isIOS {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  }
}
