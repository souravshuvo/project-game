import 'package:flutter/foundation.dart';

class AdConfig {
  const AdConfig({
    this.adsEnabled = const bool.fromEnvironment(
      'ADS_ENABLED',
      defaultValue: true,
    ),
    this.useProductionAds = const bool.fromEnvironment('USE_PRODUCTION_ADS'),
    this.androidInterstitialId = const String.fromEnvironment(
      'ADMOB_ANDROID_INTERSTITIAL_ID',
    ),
    this.iosInterstitialId = const String.fromEnvironment(
      'ADMOB_IOS_INTERSTITIAL_ID',
    ),
    this.androidRewardedId = const String.fromEnvironment(
      'ADMOB_ANDROID_REWARDED_ID',
    ),
    this.iosRewardedId = const String.fromEnvironment('ADMOB_IOS_REWARDED_ID'),
  });

  static const testAndroidInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const testIosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';
  static const testAndroidRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const testIosRewardedId = 'ca-app-pub-3940256099942544/1712485313';

  final bool adsEnabled;
  final bool useProductionAds;
  final String androidInterstitialId;
  final String iosInterstitialId;
  final String androidRewardedId;
  final String iosRewardedId;

  bool get usesTestAds {
    return !useProductionAds ||
        androidInterstitialId.isEmpty ||
        iosInterstitialId.isEmpty ||
        androidRewardedId.isEmpty ||
        iosRewardedId.isEmpty;
  }

  String interstitialAdUnitId(TargetPlatform platform) {
    if (useProductionAds) {
      final configuredId = switch (platform) {
        TargetPlatform.iOS => iosInterstitialId,
        _ => androidInterstitialId,
      };
      if (configuredId.isNotEmpty) {
        return configuredId;
      }
    }

    return switch (platform) {
      TargetPlatform.iOS => testIosInterstitialId,
      _ => testAndroidInterstitialId,
    };
  }

  String rewardedAdUnitId(TargetPlatform platform) {
    if (useProductionAds) {
      final configuredId = switch (platform) {
        TargetPlatform.iOS => iosRewardedId,
        _ => androidRewardedId,
      };
      if (configuredId.isNotEmpty) {
        return configuredId;
      }
    }

    return switch (platform) {
      TargetPlatform.iOS => testIosRewardedId,
      _ => testAndroidRewardedId,
    };
  }
}
