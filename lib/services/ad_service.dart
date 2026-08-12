import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'analytics_service.dart';

enum AdPlacement {
  postMatchRetry,
  postMatchMenu;

  String get analyticsName {
    return switch (this) {
      AdPlacement.postMatchRetry => 'post_match_retry',
      AdPlacement.postMatchMenu => 'post_match_menu',
    };
  }
}

class AdMobConfig {
  const AdMobConfig();

  static const useProductionAds = bool.fromEnvironment('USE_PRODUCTION_ADS');
  static const disableAds = bool.fromEnvironment('DISABLE_ADS');
  static const nonPersonalizedAds = bool.fromEnvironment(
    'ADS_NON_PERSONALIZED',
    defaultValue: true,
  );
  static const _androidProductionInterstitialId = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL_ID',
  );
  static const _iosProductionInterstitialId = String.fromEnvironment(
    'ADMOB_IOS_INTERSTITIAL_ID',
  );

  static const androidTestAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const iosTestAppId = 'ca-app-pub-3940256099942544~1458002511';
  static const androidTestInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const iosTestInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  String get environmentName => useProductionAds ? 'production' : 'test';

  bool get isSupportedPlatform {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  String? get interstitialAdUnitId {
    if (!isSupportedPlatform || disableAds) {
      return null;
    }

    if (!useProductionAds) {
      return defaultTargetPlatform == TargetPlatform.android
          ? androidTestInterstitialId
          : iosTestInterstitialId;
    }

    final productionId = defaultTargetPlatform == TargetPlatform.android
        ? _androidProductionInterstitialId
        : _iosProductionInterstitialId;
    return productionId.isEmpty ? null : productionId;
  }
}

class InterstitialFrequencyCap {
  InterstitialFrequencyCap({
    this.minCompletedMatchesBeforeFirstAd = 2,
    this.completedMatchInterval = 3,
    this.minTimeBetweenAds = const Duration(minutes: 8),
  });

  final int minCompletedMatchesBeforeFirstAd;
  final int completedMatchInterval;
  final Duration minTimeBetweenAds;

  var _completedMatches = 0;
  var _lastShownCompletedMatch = 0;
  DateTime? _lastShownAt;

  int get completedMatches => _completedMatches;

  void recordMatchFinished() {
    _completedMatches += 1;
  }

  InterstitialDecision evaluate(DateTime now) {
    if (_completedMatches < minCompletedMatchesBeforeFirstAd) {
      return InterstitialDecision.blocked(
        reason: 'minimum_matches',
        completedMatches: _completedMatches,
      );
    }

    if (_lastShownCompletedMatch > 0 &&
        _completedMatches - _lastShownCompletedMatch < completedMatchInterval) {
      return InterstitialDecision.blocked(
        reason: 'match_interval',
        completedMatches: _completedMatches,
      );
    }

    final lastShownAt = _lastShownAt;
    if (lastShownAt != null &&
        now.difference(lastShownAt) < minTimeBetweenAds) {
      return InterstitialDecision.blocked(
        reason: 'time_interval',
        completedMatches: _completedMatches,
      );
    }

    return InterstitialDecision.allowed(completedMatches: _completedMatches);
  }

  void recordShown(DateTime now) {
    _lastShownCompletedMatch = _completedMatches;
    _lastShownAt = now;
  }
}

class InterstitialDecision {
  const InterstitialDecision._({
    required this.allowed,
    required this.reason,
    required this.completedMatches,
  });

  factory InterstitialDecision.allowed({required int completedMatches}) {
    return InterstitialDecision._(
      allowed: true,
      reason: 'allowed',
      completedMatches: completedMatches,
    );
  }

  factory InterstitialDecision.blocked({
    required String reason,
    required int completedMatches,
  }) {
    return InterstitialDecision._(
      allowed: false,
      reason: reason,
      completedMatches: completedMatches,
    );
  }

  final bool allowed;
  final String reason;
  final int completedMatches;
}

class AdMobService {
  AdMobService({
    required this.analytics,
    AdMobConfig config = const AdMobConfig(),
    InterstitialFrequencyCap? frequencyCap,
  }) : _config = config,
       _frequencyCap = frequencyCap ?? InterstitialFrequencyCap(),
       _disabled = false;

  AdMobService.disabled()
    : analytics = AppAnalytics.disabled(),
      _config = const AdMobConfig(),
      _frequencyCap = InterstitialFrequencyCap(),
      _disabled = true;

  final AppAnalytics analytics;
  final AdMobConfig _config;
  final InterstitialFrequencyCap _frequencyCap;
  final bool _disabled;

  InterstitialAd? _interstitialAd;
  var _initialized = false;
  var _isLoadingInterstitial = false;

  Future<void> initialize() async {
    if (_disabled) {
      return;
    }

    if (!_config.isSupportedPlatform || _config.interstitialAdUnitId == null) {
      unawaited(
        analytics.logAdEvent(
          'ad_sdk_disabled',
          placement: 'startup',
          reason: _config.isSupportedPlatform ? 'missing_ad_unit' : 'platform',
          environment: _config.environmentName,
        ),
      );
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      unawaited(
        analytics.logAdEvent(
          'ad_sdk_ready',
          placement: 'startup',
          reason: 'initialized',
          environment: _config.environmentName,
        ),
      );
      _loadInterstitial();
    } catch (_) {
      _initialized = false;
      unawaited(
        analytics.logAdEvent(
          'ad_sdk_failed',
          placement: 'startup',
          reason: 'initialize_failed',
          environment: _config.environmentName,
        ),
      );
    }
  }

  void recordMatchFinished() {
    if (_disabled) {
      return;
    }

    _frequencyCap.recordMatchFinished();
    _loadInterstitial();
  }

  Future<bool> showPostMatchInterstitial({
    required AdPlacement placement,
    required FutureOr<void> Function() onComplete,
  }) async {
    if (_disabled || !_initialized) {
      await Future<void>.sync(onComplete);
      return false;
    }

    final decision = _frequencyCap.evaluate(DateTime.now());
    if (!decision.allowed) {
      unawaited(
        analytics.logAdEvent(
          'ad_interstitial_skip',
          placement: placement.analyticsName,
          reason: decision.reason,
          environment: _config.environmentName,
        ),
      );
      _loadInterstitial();
      await Future<void>.sync(onComplete);
      return false;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      unawaited(
        analytics.logAdEvent(
          'ad_interstitial_skip',
          placement: placement.analyticsName,
          reason: 'not_loaded',
          environment: _config.environmentName,
        ),
      );
      _loadInterstitial();
      await Future<void>.sync(onComplete);
      return false;
    }

    _interstitialAd = null;
    final dismissed = Completer<void>();
    var completed = false;

    void finishOnce() {
      if (!completed) {
        completed = true;
        dismissed.complete();
      }
    }

    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdShowedFullScreenContent: (shownAd) {
        _frequencyCap.recordShown(DateTime.now());
        unawaited(
          analytics.logInterstitialShown(
            placement: placement.analyticsName,
            environment: _config.environmentName,
          ),
        );
      },
      onAdImpression: (shownAd) {
        unawaited(
          analytics.logAdImpression(
            placement: placement.analyticsName,
            adUnitId: shownAd.adUnitId,
            environment: _config.environmentName,
          ),
        );
      },
      onAdDismissedFullScreenContent: (dismissedAd) {
        unawaited(dismissedAd.dispose());
        unawaited(
          analytics.logInterstitialDismissed(
            placement: placement.analyticsName,
            environment: _config.environmentName,
          ),
        );
        _loadInterstitial();
        finishOnce();
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        unawaited(failedAd.dispose());
        unawaited(
          analytics.logAdEvent(
            'ad_interstitial_fail',
            placement: placement.analyticsName,
            reason: 'show_${error.code}',
            environment: _config.environmentName,
          ),
        );
        _loadInterstitial();
        finishOnce();
      },
    );

    try {
      await ad.show();
      await dismissed.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () {},
      );
      await Future<void>.sync(onComplete);
      return true;
    } catch (_) {
      unawaited(ad.dispose());
      _loadInterstitial();
      await Future<void>.sync(onComplete);
      return false;
    }
  }

  void dispose() {
    final ad = _interstitialAd;
    _interstitialAd = null;
    if (ad != null) {
      unawaited(ad.dispose());
    }
  }

  void _loadInterstitial() {
    if (_disabled || !_initialized || _isLoadingInterstitial) {
      return;
    }

    final adUnitId = _config.interstitialAdUnitId;
    if (adUnitId == null || _interstitialAd != null) {
      return;
    }

    _isLoadingInterstitial = true;
    unawaited(
      analytics.logAdEvent(
        'ad_interstitial_load',
        placement: 'cache',
        reason: 'request',
        environment: _config.environmentName,
      ),
    );

    unawaited(
      InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(
          nonPersonalizedAds: AdMobConfig.nonPersonalizedAds,
        ),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _isLoadingInterstitial = false;
            _interstitialAd = ad;
            unawaited(ad.setImmersiveMode(true));
            unawaited(
              analytics.logAdEvent(
                'ad_interstitial_ready',
                placement: 'cache',
                reason: 'loaded',
                environment: _config.environmentName,
              ),
            );
          },
          onAdFailedToLoad: (error) {
            _isLoadingInterstitial = false;
            _interstitialAd = null;
            unawaited(
              analytics.logAdEvent(
                'ad_interstitial_fail',
                placement: 'cache',
                reason: 'load_${error.code}',
                environment: _config.environmentName,
              ),
            );
          },
        ),
      ).catchError((Object _) {
        _isLoadingInterstitial = false;
        _interstitialAd = null;
      }),
    );
  }
}
