import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../analytics/analytics_service.dart';
import 'ad_config.dart';
import 'interstitial_frequency_cap.dart';

class AdService extends ChangeNotifier {
  AdService({
    required this.analytics,
    InterstitialFrequencyCap? frequencyCap,
    bool disabled = false,
  }) : _frequencyCap = frequencyCap ?? InterstitialFrequencyCap(),
       _disabled = disabled;

  AdService.disabled({required this.analytics})
    : _frequencyCap = InterstitialFrequencyCap(),
      _disabled = true;

  final AnalyticsService analytics;
  final InterstitialFrequencyCap _frequencyCap;
  final bool _disabled;

  InterstitialAd? _interstitialAd;
  bool _initialized = false;
  bool _loadingInterstitial = false;

  bool get canRequestBanner =>
      !_disabled && _initialized && AdConfig.bannerAdUnitId != null;

  String? get bannerAdUnitId => AdConfig.bannerAdUnitId;

  Future<void> initialize() async {
    if (_disabled || !AdConfig.adsEnabled) {
      await analytics.logAdEvent(
        AnalyticsEvents.adSkipped,
        format: 'all',
        placement: 'startup',
        reason: 'disabled',
      );
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      notifyListeners();
      unawaited(_loadInterstitial());
    } catch (error) {
      _initialized = false;
      await analytics.logAdEvent(
        AnalyticsEvents.adFailed,
        format: 'all',
        placement: 'startup',
        reason: 'sdk_init_failed',
        errorMessage: error.toString(),
      );
      _debug('AdMob init failed: $error');
    }
  }

  Future<bool> maybeShowInterstitial({
    required String placement,
    required int completedChallenges,
    required int challengeNumber,
  }) async {
    if (_disabled || !_initialized || !AdConfig.interstitialEnabled) {
      await analytics.logAdEvent(
        AnalyticsEvents.adSkipped,
        format: 'interstitial',
        placement: placement,
        reason: 'disabled_or_not_initialized',
        challengeNumber: challengeNumber,
        completedCount: completedChallenges,
      );
      return false;
    }

    final now = DateTime.now();
    final decision = _frequencyCap.evaluate(
      completedChallenges: completedChallenges,
      now: now,
    );
    if (!decision.allowed) {
      await analytics.logAdEvent(
        AnalyticsEvents.adCapped,
        format: 'interstitial',
        placement: placement,
        reason: decision.reason,
        challengeNumber: challengeNumber,
        completedCount: completedChallenges,
      );
      return false;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      await analytics.logAdEvent(
        AnalyticsEvents.adSkipped,
        format: 'interstitial',
        placement: placement,
        reason: 'not_ready',
        challengeNumber: challengeNumber,
        completedCount: completedChallenges,
      );
      unawaited(_loadInterstitial());
      return false;
    }

    _interstitialAd = null;
    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdShowedFullScreenContent: (ad) {
        _frequencyCap.recordShown(now);
        unawaited(
          analytics.logAdEvent(
            AnalyticsEvents.adShow,
            format: 'interstitial',
            placement: placement,
            challengeNumber: challengeNumber,
            completedCount: completedChallenges,
          ),
        );
      },
      onAdImpression: (ad) {
        unawaited(
          analytics.logAdEvent(
            AnalyticsEvents.adImpression,
            format: 'interstitial',
            placement: placement,
            challengeNumber: challengeNumber,
            completedCount: completedChallenges,
          ),
        );
      },
      onAdClicked: (ad) {
        unawaited(
          analytics.logAdEvent(
            AnalyticsEvents.adClick,
            format: 'interstitial',
            placement: placement,
            challengeNumber: challengeNumber,
            completedCount: completedChallenges,
          ),
        );
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        unawaited(_loadInterstitial());
        unawaited(
          analytics.logAdEvent(
            AnalyticsEvents.adDismiss,
            format: 'interstitial',
            placement: placement,
            challengeNumber: challengeNumber,
            completedCount: completedChallenges,
          ),
        );
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        unawaited(_loadInterstitial());
        unawaited(
          analytics.logAdEvent(
            AnalyticsEvents.adFailed,
            format: 'interstitial',
            placement: placement,
            reason: 'show_failed',
            challengeNumber: challengeNumber,
            completedCount: completedChallenges,
            errorCode: error.code,
            errorMessage: error.message,
          ),
        );
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    try {
      ad.show();
    } catch (error) {
      ad.dispose();
      unawaited(_loadInterstitial());
      await analytics.logAdEvent(
        AnalyticsEvents.adFailed,
        format: 'interstitial',
        placement: placement,
        reason: 'show_exception',
        challengeNumber: challengeNumber,
        completedCount: completedChallenges,
        errorMessage: error.toString(),
      );
      return false;
    }

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => true,
    );
  }

  void logBannerRequest(String placement) {
    unawaited(
      analytics.logAdEvent(
        AnalyticsEvents.adRequest,
        format: 'banner',
        placement: placement,
      ),
    );
  }

  void logBannerLoaded(String placement) {
    unawaited(
      analytics.logAdEvent(
        AnalyticsEvents.adLoaded,
        format: 'banner',
        placement: placement,
      ),
    );
  }

  void logBannerFailed(String placement, LoadAdError error) {
    unawaited(
      analytics.logAdEvent(
        AnalyticsEvents.adFailed,
        format: 'banner',
        placement: placement,
        reason: 'load_failed',
        errorCode: error.code,
        errorMessage: error.message,
      ),
    );
  }

  void logBannerImpression(String placement) {
    unawaited(
      analytics.logAdEvent(
        AnalyticsEvents.adImpression,
        format: 'banner',
        placement: placement,
      ),
    );
  }

  void logBannerClick(String placement) {
    unawaited(
      analytics.logAdEvent(
        AnalyticsEvents.adClick,
        format: 'banner',
        placement: placement,
      ),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    super.dispose();
  }

  Future<void> _loadInterstitial() async {
    if (_disabled ||
        !_initialized ||
        _loadingInterstitial ||
        _interstitialAd != null) {
      return;
    }

    final adUnitId = AdConfig.interstitialAdUnitId;
    if (adUnitId == null) {
      await analytics.logAdEvent(
        AnalyticsEvents.adSkipped,
        format: 'interstitial',
        placement: 'preload',
        reason: 'missing_ad_unit_id',
      );
      return;
    }

    _loadingInterstitial = true;
    await analytics.logAdEvent(
      AnalyticsEvents.adRequest,
      format: 'interstitial',
      placement: 'preload',
    );

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: AdConfig.request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingInterstitial = false;
          _interstitialAd = ad;
          unawaited(
            analytics.logAdEvent(
              AnalyticsEvents.adLoaded,
              format: 'interstitial',
              placement: 'preload',
            ),
          );
        },
        onAdFailedToLoad: (error) {
          _loadingInterstitial = false;
          unawaited(
            analytics.logAdEvent(
              AnalyticsEvents.adFailed,
              format: 'interstitial',
              placement: 'preload',
              reason: 'load_failed',
              errorCode: error.code,
              errorMessage: error.message,
            ),
          );
        },
      ),
    );
  }

  void _debug(String message) {
    if (kDebugMode) {
      debugPrint('ads: $message');
    }
  }
}
