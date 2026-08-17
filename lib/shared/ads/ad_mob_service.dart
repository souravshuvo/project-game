import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../analytics/game_analytics.dart';
import 'ad_frequency_cap.dart';
import 'ad_mob_config.dart';
import 'game_ad_service.dart';

class AdMobGameAdService implements GameAdService {
  AdMobGameAdService({
    required GameAnalytics analytics,
    AdFrequencyCap? frequencyCap,
  }) : _analytics = analytics,
       _frequencyCap = frequencyCap ?? AdFrequencyCap();

  final GameAnalytics _analytics;
  final AdFrequencyCap _frequencyCap;
  InterstitialAd? _interstitialAd;
  bool _isLoadingInterstitial = false;
  bool _isShowingInterstitial = false;

  @override
  Future<void> warmUp() async {
    if (!AdMobConfig.adsEnabled) {
      _logAdSkipped('startup', 'ads_disabled');
      return;
    }

    try {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          maxAdContentRating: MaxAdContentRating.g,
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
          tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
        ),
      );
      await MobileAds.instance.initialize();
      _loadInterstitial('warm_up');
    } on Object catch (error) {
      debugPrint('AdMob warm-up failed: $error');
      _logAdLoadFailed('startup', error.toString());
    }
  }

  @override
  void recordLevelEnd({required bool won}) {
    _frequencyCap.recordLevelEnd(won: won);
    _logAdGateState(won ? 'level_end_won' : 'level_end_lost');
    _loadInterstitial('level_end');
  }

  @override
  Future<bool> showInterstitialIfAvailable({required String placement}) async {
    final unitId = AdMobConfig.interstitialUnitId;
    if (!AdMobConfig.adsEnabled) {
      _logAdSkipped(placement, 'ads_disabled');
      return false;
    }
    if (unitId.isEmpty) {
      _logAdSkipped(placement, 'missing_unit_id');
      return false;
    }
    if (_isShowingInterstitial) {
      _logAdSkipped(placement, 'already_showing');
      return false;
    }
    final gateDecision = _frequencyCap.evaluate(DateTime.now());
    if (!gateDecision.canShow) {
      _logAdSkipped(placement, gateDecision.reason ?? 'frequency_cap');
      _loadInterstitial('frequency_cap_skip');
      return false;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      _logAdSkipped(
        placement,
        _isLoadingInterstitial ? 'loading' : 'not_ready',
      );
      _loadInterstitial('not_ready');
      return false;
    }

    _interstitialAd = null;
    _isShowingInterstitial = true;
    final completer = Completer<bool>();
    void complete(bool shown) {
      if (!completer.isCompleted) {
        completer.complete(shown);
      }
    }

    _logAdShowAttempt(placement);
    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdShowedFullScreenContent: (ad) {
        _logAdShow(placement);
      },
      onAdDismissedFullScreenContent: (ad) {
        unawaited(ad.dispose());
        _isShowingInterstitial = false;
        _frequencyCap.recordInterstitialShown(DateTime.now());
        _logAdDismissed(placement);
        _loadInterstitial('dismissed');
        complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        unawaited(ad.dispose());
        _isShowingInterstitial = false;
        _logAdShowFailed(placement, error.toString());
        _loadInterstitial('show_failed');
        complete(false);
      },
    );

    try {
      await ad.show().timeout(const Duration(seconds: 2));
    } on Object catch (error) {
      _isShowingInterstitial = false;
      _logAdShowFailed(placement, error.toString());
      _loadInterstitial('show_throw');
      complete(false);
    }
    return completer.future;
  }

  void _loadInterstitial(String placement) {
    final unitId = AdMobConfig.interstitialUnitId;
    if (!AdMobConfig.adsEnabled || unitId.isEmpty) {
      return;
    }
    if (_interstitialAd != null ||
        _isLoadingInterstitial ||
        _isShowingInterstitial) {
      return;
    }

    _isLoadingInterstitial = true;
    _logAdLoadStart(placement);
    InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(nonPersonalizedAds: true),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingInterstitial = false;
          _interstitialAd = ad;
          _logAdLoadSuccess(placement);
        },
        onAdFailedToLoad: (error) {
          _isLoadingInterstitial = false;
          _interstitialAd = null;
          _logAdLoadFailed(placement, error.toString());
        },
      ),
    );
  }

  @override
  Future<void> dispose() async {
    await _interstitialAd?.dispose();
    _interstitialAd = null;
  }

  void _logAdLoadStart(String placement) {
    unawaited(
      _analytics.logEvent(GameAnalyticsEvents.adLoadStart, {
        'ad_format': 'interstitial',
        'placement': placement,
        'ad_mode': AdMobConfig.runtimeMode,
        'using_test_ads': AdMobConfig.useTestAds,
      }),
    );
  }

  void _logAdLoadSuccess(String placement) {
    unawaited(
      _analytics.logEvent(GameAnalyticsEvents.adLoadSuccess, {
        'ad_format': 'interstitial',
        'placement': placement,
        'ad_mode': AdMobConfig.runtimeMode,
        'using_test_ads': AdMobConfig.useTestAds,
      }),
    );
  }

  void _logAdLoadFailed(String placement, String reason) {
    unawaited(
      _analytics.logEvent(GameAnalyticsEvents.adLoadFailed, {
        'ad_format': 'interstitial',
        'placement': placement,
        'reason': _shortReason(reason),
        'ad_mode': AdMobConfig.runtimeMode,
        'using_test_ads': AdMobConfig.useTestAds,
      }),
    );
  }

  void _logAdShowAttempt(String placement) {
    unawaited(
      _analytics.logEvent(GameAnalyticsEvents.adShowAttempt, {
        'ad_format': 'interstitial',
        'placement': placement,
        'level_ends_since_ad': _frequencyCap.levelEndsSinceInterstitial,
        'seconds_since_last_ad': _frequencyCap.secondsSinceLastInterstitial(
          DateTime.now(),
        ),
        'min_level_ends_between_ads':
            _frequencyCap.minLevelEndsBetweenInterstitials,
        'min_seconds_between_ads':
            _frequencyCap.minInterstitialInterval.inSeconds,
        'ad_mode': AdMobConfig.runtimeMode,
        'using_test_ads': AdMobConfig.useTestAds,
      }),
    );
  }

  void _logAdShow(String placement) {
    unawaited(
      _analytics.logEvent(GameAnalyticsEvents.adShow, {
        'ad_format': 'interstitial',
        'placement': placement,
        'ad_mode': AdMobConfig.runtimeMode,
        'using_test_ads': AdMobConfig.useTestAds,
      }),
    );
  }

  void _logAdShowFailed(String placement, String reason) {
    unawaited(
      _analytics.logEvent(GameAnalyticsEvents.adShowFailed, {
        'ad_format': 'interstitial',
        'placement': placement,
        'reason': _shortReason(reason),
        'ad_mode': AdMobConfig.runtimeMode,
        'using_test_ads': AdMobConfig.useTestAds,
      }),
    );
  }

  void _logAdDismissed(String placement) {
    unawaited(
      _analytics.logEvent(GameAnalyticsEvents.adDismissed, {
        'ad_format': 'interstitial',
        'placement': placement,
        'ad_mode': AdMobConfig.runtimeMode,
        'using_test_ads': AdMobConfig.useTestAds,
      }),
    );
  }

  void _logAdSkipped(String placement, String reason) {
    unawaited(
      _analytics.logEvent(GameAnalyticsEvents.adSkipped, {
        'ad_format': 'interstitial',
        'placement': placement,
        'reason': reason,
        'level_ends_since_ad': _frequencyCap.levelEndsSinceInterstitial,
        'seconds_since_last_ad': _frequencyCap.secondsSinceLastInterstitial(
          DateTime.now(),
        ),
        'min_level_ends_between_ads':
            _frequencyCap.minLevelEndsBetweenInterstitials,
        'min_seconds_between_ads':
            _frequencyCap.minInterstitialInterval.inSeconds,
        'ad_mode': AdMobConfig.runtimeMode,
        'using_test_ads': AdMobConfig.useTestAds,
      }),
    );
  }

  void _logAdGateState(String placement) {
    final decision = _frequencyCap.evaluate(DateTime.now());
    unawaited(
      _analytics.logEvent(GameAnalyticsEvents.adGateState, {
        'ad_format': 'interstitial',
        'placement': placement,
        'can_show': decision.canShow,
        'reason': decision.reason ?? 'eligible',
        'level_ends_since_ad': decision.levelEndsSinceInterstitial,
        'seconds_since_last_ad': decision.secondsSinceLastInterstitial,
        'min_level_ends_between_ads':
            _frequencyCap.minLevelEndsBetweenInterstitials,
        'min_seconds_between_ads':
            _frequencyCap.minInterstitialInterval.inSeconds,
        'ad_mode': AdMobConfig.runtimeMode,
        'using_test_ads': AdMobConfig.useTestAds,
      }),
    );
  }

  String _shortReason(String reason) {
    if (reason.length <= 96) {
      return reason;
    }
    return reason.substring(0, 96);
  }
}
