import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../analytics/analytics_service.dart';
import 'ad_frequency_cap.dart';
import 'ad_mob_config.dart';

class AdMobService {
  AdMobService({
    required AnalyticsService analytics,
    AdFrequencyCap? frequencyCap,
  }) : _analytics = analytics,
       _frequencyCap = frequencyCap ?? AdFrequencyCap();

  final AnalyticsService _analytics;
  final AdFrequencyCap _frequencyCap;

  bool _initialized = false;
  bool _initializing = false;
  bool _loadingInterstitial = false;
  bool _showingInterstitial = false;
  InterstitialAd? _interstitialAd;

  void start() {
    if (!AdMobConfig.enabled || _initializing || _initialized) {
      return;
    }

    _initializing = true;
    unawaited(_initialize());
  }

  Future<void> showLevelEndInterstitialIfAllowed({
    required int levelNumber,
    required bool completed,
    required FutureOr<void> Function() onContinue,
  }) async {
    final decision = _frequencyCap.registerLevelEnd(
      levelNumber: levelNumber,
      completed: completed,
      now: DateTime.now(),
    );

    if (!decision.allowed) {
      _logAdEvent('ad_capped', levelNumber, {
        'reason': decision.reason,
        'completed_levels_since_ad': decision.completedLevelsSinceAd,
      });
      await onContinue();
      return;
    }

    if (!_initialized || _showingInterstitial) {
      _logAdEvent('ad_unavailable', levelNumber, {
        'reason': _showingInterstitial ? 'already_showing' : 'sdk_not_ready',
      });
      await onContinue();
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      _logAdEvent('ad_unavailable', levelNumber, {'reason': 'not_loaded'});
      _loadInterstitial();
      await onContinue();
      return;
    }

    _interstitialAd = null;
    _showingInterstitial = true;
    final completedShow = Completer<void>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _logAdEvent('ad_show', levelNumber, const {});
      },
      onAdImpression: (ad) {
        _logAdEvent('ad_impression', levelNumber, const {});
      },
      onAdDismissedFullScreenContent: (ad) {
        _frequencyCap.recordInterstitialShown(DateTime.now());
        unawaited(ad.dispose());
        _showingInterstitial = false;
        _loadInterstitial();
        if (!completedShow.isCompleted) {
          completedShow.complete();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _logAdEvent('ad_show_failed', levelNumber, {
          'error_code': error.code,
          'error_domain': error.domain,
        });
        unawaited(ad.dispose());
        _showingInterstitial = false;
        _loadInterstitial();
        if (!completedShow.isCompleted) {
          completedShow.complete();
        }
      },
    );

    try {
      _logAdEvent('ad_show_attempt', levelNumber, const {});
      unawaited(ad.show());
      await completedShow.future.timeout(
        const Duration(seconds: 45),
        onTimeout: () {},
      );
    } catch (error) {
      debugPrint('Interstitial show failed: $error');
      _logAdEvent('ad_show_failed', levelNumber, {
        'error_type': error.runtimeType.toString(),
      });
    } finally {
      _showingInterstitial = false;
      await onContinue();
    }
  }

  void dispose() {
    final interstitialAd = _interstitialAd;
    if (interstitialAd != null) {
      unawaited(interstitialAd.dispose());
    }
    _interstitialAd = null;
  }

  Future<void> _initialize() async {
    try {
      await MobileAds.instance.initialize().timeout(const Duration(seconds: 8));
      _initialized = true;
      _analytics.logEvent('ad_sdk_init', {
        'ad_environment': AdMobConfig.environment,
      });
      _loadInterstitial();
    } catch (error) {
      debugPrint('AdMob initialization failed: $error');
      _analytics.logEvent('ad_sdk_init_failed', {
        'ad_environment': AdMobConfig.environment,
        'error_type': error.runtimeType.toString(),
      });
    } finally {
      _initializing = false;
    }
  }

  void _loadInterstitial() {
    if (!_initialized || _loadingInterstitial || _interstitialAd != null) {
      return;
    }

    final adUnitId = AdMobConfig.interstitialAdUnitId;
    if (adUnitId == null) {
      _analytics.logEvent('ad_unavailable', {
        'ad_format': 'interstitial',
        'ad_environment': AdMobConfig.environment,
        'reason': 'missing_ad_unit',
      });
      return;
    }

    _loadingInterstitial = true;
    _analytics.logEvent('ad_request', {
      'ad_format': 'interstitial',
      'ad_environment': AdMobConfig.environment,
    });

    unawaited(
      InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _loadingInterstitial = false;
            _interstitialAd = ad;
            _analytics.logEvent('ad_loaded', {
              'ad_format': 'interstitial',
              'ad_environment': AdMobConfig.environment,
            });
          },
          onAdFailedToLoad: (error) {
            _loadingInterstitial = false;
            _analytics.logEvent('ad_load_failed', {
              'ad_format': 'interstitial',
              'ad_environment': AdMobConfig.environment,
              'error_code': error.code,
              'error_domain': error.domain,
            });
          },
        ),
      ).catchError((Object error) {
        _loadingInterstitial = false;
        _analytics.logEvent('ad_load_failed', {
          'ad_format': 'interstitial',
          'ad_environment': AdMobConfig.environment,
          'error_type': error.runtimeType.toString(),
        });
        debugPrint('Interstitial load failed unexpectedly: $error');
      }),
    );
  }

  void _logAdEvent(
    String eventName,
    int levelNumber,
    Map<String, Object?> extra,
  ) {
    _analytics.logEvent(eventName, {
      'ad_format': 'interstitial',
      'ad_environment': AdMobConfig.environment,
      'placement': 'level_end_transition',
      'level_number': levelNumber,
      ...extra,
    });
  }
}
