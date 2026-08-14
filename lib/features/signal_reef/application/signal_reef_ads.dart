import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'signal_reef_telemetry.dart';

enum SignalReefAdPlacement {
  homeBanner('home_banner'),
  resultBanner('result_banner'),
  resultInterstitial('result_interstitial');

  const SignalReefAdPlacement(this.analyticsName);

  final String analyticsName;
}

final class SignalReefAdConfig {
  const SignalReefAdConfig();

  static const useProductionAds = bool.fromEnvironment(
    'SIGNAL_REEF_USE_PRODUCTION_ADS',
  );

  static const _androidTestBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _iosTestBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const _androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const _iosTestInterstitial = 'ca-app-pub-3940256099942544/4411468910';

  static const _androidProdBanner = String.fromEnvironment(
    'SIGNAL_REEF_ANDROID_BANNER_AD_UNIT_ID',
  );
  static const _iosProdBanner = String.fromEnvironment(
    'SIGNAL_REEF_IOS_BANNER_AD_UNIT_ID',
  );
  static const _androidProdInterstitial = String.fromEnvironment(
    'SIGNAL_REEF_ANDROID_INTERSTITIAL_AD_UNIT_ID',
  );
  static const _iosProdInterstitial = String.fromEnvironment(
    'SIGNAL_REEF_IOS_INTERSTITIAL_AD_UNIT_ID',
  );

  bool get supportsAds {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  String get environment {
    return _usingProductionAdUnits ? 'production' : 'test';
  }

  String? bannerAdUnitId() {
    if (!supportsAds) {
      return null;
    }

    if (_usingProductionAdUnits) {
      return defaultTargetPlatform == TargetPlatform.android
          ? _androidProdBanner
          : _iosProdBanner;
    }

    return defaultTargetPlatform == TargetPlatform.android
        ? _androidTestBanner
        : _iosTestBanner;
  }

  String? interstitialAdUnitId() {
    if (!supportsAds) {
      return null;
    }

    if (_usingProductionAdUnits) {
      return defaultTargetPlatform == TargetPlatform.android
          ? _androidProdInterstitial
          : _iosProdInterstitial;
    }

    return defaultTargetPlatform == TargetPlatform.android
        ? _androidTestInterstitial
        : _iosTestInterstitial;
  }

  bool get _usingProductionAdUnits {
    if (!useProductionAds) {
      return false;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidProdBanner.isNotEmpty &&
          _androidProdInterstitial.isNotEmpty;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _iosProdBanner.isNotEmpty && _iosProdInterstitial.isNotEmpty;
    }

    return false;
  }
}

final class SignalReefAdService {
  SignalReefAdService({
    required this.telemetry,
    this.config = const SignalReefAdConfig(),
  });

  static const interstitialRunFrequency = 3;
  static const interstitialMinimumInterval = Duration(minutes: 2);

  final SignalReefTelemetry telemetry;
  final SignalReefAdConfig config;

  InterstitialAd? _interstitialAd;
  Future<void>? _initializeFuture;
  var _isInterstitialLoading = false;
  var _initialized = false;
  var _completedRunsSinceInterstitial = 0;
  DateTime? _lastInterstitialShownAt;

  bool get supportsAds => config.supportsAds;

  bool get isInitialized => _initialized;

  String get adEnvironment => config.environment;

  Future<void> initialize() async {
    if (_initialized || !config.supportsAds) {
      return;
    }

    final existingInitialize = _initializeFuture;
    if (existingInitialize != null) {
      await existingInitialize;
      return;
    }

    final initializeFuture = _initialize();
    _initializeFuture = initializeFuture;
    await initializeFuture;
  }

  Future<void> _initialize() async {
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      _trackAd(action: 'sdk_initialized', placement: 'app');
      loadResultInterstitial();
    } on Object catch (error) {
      _initializeFuture = null;
      _trackAd(
        action: 'sdk_failed',
        placement: 'app',
        reason: error.runtimeType.toString(),
      );
    }
  }

  void recordRunFinished() {
    _completedRunsSinceInterstitial++;
    loadResultInterstitial();
  }

  void loadResultInterstitial() {
    final adUnitId = config.interstitialAdUnitId();
    if (!_initialized ||
        adUnitId == null ||
        _interstitialAd != null ||
        _isInterstitialLoading) {
      return;
    }

    _isInterstitialLoading = true;
    _trackAd(
      action: 'load_start',
      placement: SignalReefAdPlacement.resultInterstitial.analyticsName,
    );

    unawaited(
      InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _isInterstitialLoading = false;
            _interstitialAd = ad;
            _trackAd(
              action: 'loaded',
              placement: SignalReefAdPlacement.resultInterstitial.analyticsName,
            );
          },
          onAdFailedToLoad: (error) {
            _isInterstitialLoading = false;
            _trackAd(
              action: 'load_failed',
              placement: SignalReefAdPlacement.resultInterstitial.analyticsName,
              reason: error.code.toString(),
            );
          },
        ),
      ).catchError((Object error) {
        if (_isInterstitialLoading) {
          _isInterstitialLoading = false;
        }
        _trackAd(
          action: 'load_failed',
          placement: SignalReefAdPlacement.resultInterstitial.analyticsName,
          reason: error.runtimeType.toString(),
        );
      }),
    );
  }

  void maybeShowResultInterstitial() {
    if (!config.supportsAds) {
      _trackInterstitialSkip('unsupported_platform');
      return;
    }

    if (!_initialized) {
      unawaited(initialize());
      _trackInterstitialSkip('sdk_not_ready');
      return;
    }

    if (_completedRunsSinceInterstitial < interstitialRunFrequency) {
      _trackInterstitialSkip('run_frequency_cap');
      return;
    }

    final now = DateTime.now();
    final lastShownAt = _lastInterstitialShownAt;
    if (lastShownAt != null &&
        now.difference(lastShownAt) < interstitialMinimumInterval) {
      _trackInterstitialSkip('time_frequency_cap');
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      loadResultInterstitial();
      _trackInterstitialSkip('ad_not_loaded');
      return;
    }

    _interstitialAd = null;
    _completedRunsSinceInterstitial = 0;
    _lastInterstitialShownAt = now;

    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdShowedFullScreenContent: (shownAd) {
        _trackAd(
          action: 'showed',
          placement: SignalReefAdPlacement.resultInterstitial.analyticsName,
        );
      },
      onAdDismissedFullScreenContent: (dismissedAd) {
        dismissedAd.dispose();
        _trackAd(
          action: 'dismissed',
          placement: SignalReefAdPlacement.resultInterstitial.analyticsName,
        );
        loadResultInterstitial();
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        failedAd.dispose();
        _trackAd(
          action: 'show_failed',
          placement: SignalReefAdPlacement.resultInterstitial.analyticsName,
          reason: error.code.toString(),
        );
        loadResultInterstitial();
      },
    );

    unawaited(
      ad.show().catchError((Object error) {
        ad.dispose();
        _trackAd(
          action: 'show_failed',
          placement: SignalReefAdPlacement.resultInterstitial.analyticsName,
          reason: error.runtimeType.toString(),
        );
        loadResultInterstitial();
      }),
    );
  }

  void trackBannerLoadStart(SignalReefAdPlacement placement) {
    _trackAd(action: 'load_start', placement: placement.analyticsName);
  }

  void trackBannerLoaded(SignalReefAdPlacement placement) {
    _trackAd(action: 'loaded', placement: placement.analyticsName);
  }

  void trackBannerLoadFailed(
    SignalReefAdPlacement placement,
    LoadAdError error,
  ) {
    _trackAd(
      action: 'load_failed',
      placement: placement.analyticsName,
      reason: error.code.toString(),
    );
  }

  void trackBannerLoadException(SignalReefAdPlacement placement, Object error) {
    _trackAd(
      action: 'load_failed',
      placement: placement.analyticsName,
      reason: error.runtimeType.toString(),
    );
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }

  void _trackInterstitialSkip(String reason) {
    _trackAd(
      action: 'skipped',
      placement: SignalReefAdPlacement.resultInterstitial.analyticsName,
      reason: reason,
    );
  }

  void _trackAd({
    required String action,
    required String placement,
    String? reason,
  }) {
    telemetry.track(
      SignalReefTelemetryEvents.adEvent(
        action: action,
        placement: placement,
        environment: config.environment,
        reason: reason,
      ),
    );
  }
}
