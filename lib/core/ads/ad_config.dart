import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

enum AdMobMode { disabled, test, production }

enum AdPlatform { android, ios, unsupported }

class AdMobConfig {
  const AdMobConfig({
    required this.mode,
    required this.platform,
    required this.bannerAdUnitId,
    required this.interstitialAdUnitId,
    this.testDeviceIds = const <String>[],
    this.disabledReason,
  });

  static const String androidTestAppId =
      'ca-app-pub-3940256099942544~3347511713';
  static const String iosTestAppId = 'ca-app-pub-3940256099942544~1458002511';

  static const String androidTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String iosTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/2934735716';
  static const String androidTestInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String iosTestInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/4411468910';

  final AdMobMode mode;
  final AdPlatform platform;
  final String bannerAdUnitId;
  final String interstitialAdUnitId;
  final List<String> testDeviceIds;
  final String? disabledReason;

  bool get servesAds =>
      mode != AdMobMode.disabled &&
      bannerAdUnitId.isNotEmpty &&
      interstitialAdUnitId.isNotEmpty;

  String get modeName => mode.name;

  static AdMobConfig fromEnvironment({
    AdPlatform? platform,
    bool isRelease = kReleaseMode,
  }) {
    final resolvedPlatform = platform ?? currentPlatform();
    if (resolvedPlatform == AdPlatform.unsupported) {
      return const AdMobConfig.disabled('unsupported_platform');
    }

    const requestedMode = String.fromEnvironment(
      'ADMOB_MODE',
      defaultValue: 'test',
    );
    final normalizedMode = requestedMode.trim().toLowerCase();
    if (normalizedMode == 'disabled' || normalizedMode == 'off') {
      return AdMobConfig.disabled('disabled_by_dart_define');
    }

    if (normalizedMode == 'production' || normalizedMode == 'prod') {
      return _productionConfig(resolvedPlatform);
    }

    if (isRelease && normalizedMode == 'test') {
      return const AdMobConfig.disabled('release_test_ads_disabled');
    }

    return _testConfig(resolvedPlatform);
  }

  static AdPlatform currentPlatform() {
    if (Platform.isAndroid) {
      return AdPlatform.android;
    }
    if (Platform.isIOS) {
      return AdPlatform.ios;
    }
    return AdPlatform.unsupported;
  }

  const AdMobConfig.disabled(String reason)
    : mode = AdMobMode.disabled,
      platform = AdPlatform.unsupported,
      bannerAdUnitId = '',
      interstitialAdUnitId = '',
      testDeviceIds = const <String>[],
      disabledReason = reason;

  static AdMobConfig _testConfig(AdPlatform platform) {
    return switch (platform) {
      AdPlatform.android => const AdMobConfig(
        mode: AdMobMode.test,
        platform: AdPlatform.android,
        bannerAdUnitId: androidTestBannerAdUnitId,
        interstitialAdUnitId: androidTestInterstitialAdUnitId,
      ),
      AdPlatform.ios => const AdMobConfig(
        mode: AdMobMode.test,
        platform: AdPlatform.ios,
        bannerAdUnitId: iosTestBannerAdUnitId,
        interstitialAdUnitId: iosTestInterstitialAdUnitId,
      ),
      AdPlatform.unsupported => const AdMobConfig.disabled(
        'unsupported_platform',
      ),
    };
  }

  static AdMobConfig _productionConfig(AdPlatform platform) {
    const androidBanner = String.fromEnvironment('ADMOB_ANDROID_BANNER_ID');
    const androidInterstitial = String.fromEnvironment(
      'ADMOB_ANDROID_INTERSTITIAL_ID',
    );
    const iosBanner = String.fromEnvironment('ADMOB_IOS_BANNER_ID');
    const iosInterstitial = String.fromEnvironment('ADMOB_IOS_INTERSTITIAL_ID');
    const testDeviceIds = String.fromEnvironment('ADMOB_TEST_DEVICE_IDS');

    final ids = testDeviceIds
        .split(',')
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

    final config = switch (platform) {
      AdPlatform.android => AdMobConfig(
        mode: AdMobMode.production,
        platform: AdPlatform.android,
        bannerAdUnitId: androidBanner,
        interstitialAdUnitId: androidInterstitial,
        testDeviceIds: ids,
      ),
      AdPlatform.ios => AdMobConfig(
        mode: AdMobMode.production,
        platform: AdPlatform.ios,
        bannerAdUnitId: iosBanner,
        interstitialAdUnitId: iosInterstitial,
        testDeviceIds: ids,
      ),
      AdPlatform.unsupported => const AdMobConfig.disabled(
        'unsupported_platform',
      ),
    };

    if (!config.servesAds) {
      return const AdMobConfig.disabled('missing_production_ad_units');
    }
    return config;
  }
}
