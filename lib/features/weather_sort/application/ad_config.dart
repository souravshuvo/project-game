import 'package:flutter/foundation.dart';

import 'ad_frequency_policy.dart';

enum WeatherSortAdsEnvironment { test, production }

class WeatherSortAdConfig {
  const WeatherSortAdConfig({
    this.frequencyPolicy = const InterstitialFrequencyPolicy(),
  });

  static const _adsEnabled = bool.fromEnvironment(
    'WEATHER_SORT_ADS_ENABLED',
    defaultValue: true,
  );
  static const _adsEnvironment = String.fromEnvironment(
    'WEATHER_SORT_ADS_ENV',
    defaultValue: 'test',
  );
  static const _androidProductionInterstitialId = String.fromEnvironment(
    'WEATHER_SORT_ADMOB_ANDROID_INTERSTITIAL_ID',
    defaultValue: 'ca-app-pub-1358699173061266/1193410127',
  );
  static const _iosProductionInterstitialId = String.fromEnvironment(
    'WEATHER_SORT_ADMOB_IOS_INTERSTITIAL_ID',
  );

  static const androidTestAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const iosTestAppId = 'ca-app-pub-3940256099942544~1458002511';
  static const androidTestInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const iosTestInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/4411468910';

  final InterstitialFrequencyPolicy frequencyPolicy;

  bool get adsEnabled => _adsEnabled;

  WeatherSortAdsEnvironment get environment {
    final normalized = _adsEnvironment.toLowerCase().trim();
    if (normalized == 'prod' || normalized == 'production') {
      return WeatherSortAdsEnvironment.production;
    }

    return WeatherSortAdsEnvironment.test;
  }

  bool get usesTestAds => environment == WeatherSortAdsEnvironment.test;

  bool get canRequestAds {
    return adsEnabled && levelEndInterstitialAdUnitId != null;
  }

  String? get levelEndInterstitialAdUnitId {
    if (!adsEnabled || kIsWeb) {
      return null;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        usesTestAds
            ? androidTestInterstitialAdUnitId
            : _productionIdOrNull(_androidProductionInterstitialId),
      TargetPlatform.iOS =>
        usesTestAds
            ? iosTestInterstitialAdUnitId
            : _productionIdOrNull(_iosProductionInterstitialId),
      _ => null,
    };
  }

  String? _productionIdOrNull(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.contains('3940256099942544')) {
      return null;
    }

    return trimmed;
  }
}
