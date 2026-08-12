import 'package:flutter/foundation.dart';

class AdConfig {
  const AdConfig._();

  static const useProductionAds = bool.fromEnvironment(
    'USE_PROD_ADS',
    defaultValue: false,
  );

  static const androidTestAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const iosTestAppId = 'ca-app-pub-3940256099942544~1458002511';

  static const _androidTestBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const _androidTestInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const _iosTestBannerId = 'ca-app-pub-3940256099942544/2934735716';
  static const _iosTestInterstitialId =
      'ca-app-pub-3940256099942544/4411468910';

  static const _androidProductionBannerId = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_ID',
  );
  static const _androidProductionInterstitialId = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL_ID',
  );
  static const _iosProductionBannerId = String.fromEnvironment(
    'ADMOB_IOS_BANNER_ID',
  );
  static const _iosProductionInterstitialId = String.fromEnvironment(
    'ADMOB_IOS_INTERSTITIAL_ID',
  );

  static bool get _isAndroid {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  static bool get _isIOS {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  }

  static bool get isSupportedPlatform {
    return _isAndroid || _isIOS;
  }

  static bool get hasProductionUnitIds {
    if (!isSupportedPlatform) {
      return false;
    }
    if (_isAndroid) {
      return _androidProductionBannerId.isNotEmpty &&
          _androidProductionInterstitialId.isNotEmpty;
    }
    return _iosProductionBannerId.isNotEmpty &&
        _iosProductionInterstitialId.isNotEmpty;
  }

  static bool get canRequestAds {
    return isSupportedPlatform && (!useProductionAds || hasProductionUnitIds);
  }

  static String get bannerUnitId {
    if (useProductionAds && hasProductionUnitIds) {
      return _isAndroid ? _androidProductionBannerId : _iosProductionBannerId;
    }
    return _isAndroid ? _androidTestBannerId : _iosTestBannerId;
  }

  static String get interstitialUnitId {
    if (useProductionAds && hasProductionUnitIds) {
      return _isAndroid
          ? _androidProductionInterstitialId
          : _iosProductionInterstitialId;
    }
    return _isAndroid ? _androidTestInterstitialId : _iosTestInterstitialId;
  }

  static List<String> get testDeviceIds {
    const raw = String.fromEnvironment('ADMOB_TEST_DEVICE_IDS');
    return raw
        .split(',')
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
  }
}
