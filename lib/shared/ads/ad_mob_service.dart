import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../analytics/game_analytics.dart';
import 'ad_mob_config.dart';
import 'game_ad_service.dart';

class AdMobGameAdService implements GameAdService {
  AdMobGameAdService({required GameAnalytics analytics})
    : _analytics = analytics;

  static const _minLevelEndsBetweenInterstitials = 3;
  static const _minInterstitialInterval = Duration(minutes: 3);

  final GameAnalytics _analytics;
  InterstitialAd? _interstitialAd;
  DateTime? _lastInterstitialShownAt;
  int _levelEndsSinceInterstitial = 0;
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
        ),
      );
      unawaited(MobileAds.instance.initialize());
      _loadInterstitial();
    } on Object catch (error) {
      debugPrint('AdMob warm-up failed: $error');
      _logAdLoadFailed('startup', error.toString());
    }
  }

  @override
  void recordLevelEnd({required bool won}) {
    _levelEndsSinceInterstitial++;
    _loadInterstitial();
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
    if (!_passesFrequencyCap) {
      _logAdSkipped(placement, 'frequency_cap');
      _loadInterstitial();
      return false;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      _logAdSkipped(
        placement,
        _isLoadingInterstitial ? 'loading' : 'not_ready',
      );
      _loadInterstitial();
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
        _lastInterstitialShownAt = DateTime.now();
        _levelEndsSinceInterstitial = 0;
        _logAdDismissed(placement);
        _loadInterstitial();
        complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        unawaited(ad.dispose());
        _isShowingInterstitial = false;
        _logAdShowFailed(placement, error.toString());
        _loadInterstitial();
        complete(false);
      },
    );

    unawaited(ad.show());
    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        _isShowingInterstitial = false;
        return true;
      },
    );
  }

  bool get _passesFrequencyCap {
    if (_levelEndsSinceInterstitial < _minLevelEndsBetweenInterstitials) {
      return false;
    }
    final lastShownAt = _lastInterstitialShownAt;
    if (lastShownAt == null) {
      return true;
    }
    return DateTime.now().difference(lastShownAt) >= _minInterstitialInterval;
  }

  void _loadInterstitial() {
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
    _logAdLoadStart('level_end');
    InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(nonPersonalizedAds: true),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingInterstitial = false;
          _interstitialAd = ad;
          _logAdLoadSuccess('level_end');
        },
        onAdFailedToLoad: (error) {
          _isLoadingInterstitial = false;
          _interstitialAd = null;
          _logAdLoadFailed('level_end', error.toString());
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
        'using_test_ads': AdMobConfig.useTestAds,
      }),
    );
  }

  void _logAdLoadSuccess(String placement) {
    unawaited(
      _analytics.logEvent(GameAnalyticsEvents.adLoadSuccess, {
        'ad_format': 'interstitial',
        'placement': placement,
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
        'using_test_ads': AdMobConfig.useTestAds,
      }),
    );
  }

  void _logAdShowAttempt(String placement) {
    unawaited(
      _analytics.logEvent(GameAnalyticsEvents.adShowAttempt, {
        'ad_format': 'interstitial',
        'placement': placement,
        'level_ends_since_ad': _levelEndsSinceInterstitial,
        'using_test_ads': AdMobConfig.useTestAds,
      }),
    );
  }

  void _logAdShow(String placement) {
    unawaited(
      _analytics.logEvent(GameAnalyticsEvents.adShow, {
        'ad_format': 'interstitial',
        'placement': placement,
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
        'using_test_ads': AdMobConfig.useTestAds,
      }),
    );
  }

  void _logAdDismissed(String placement) {
    unawaited(
      _analytics.logEvent(GameAnalyticsEvents.adDismissed, {
        'ad_format': 'interstitial',
        'placement': placement,
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
        'level_ends_since_ad': _levelEndsSinceInterstitial,
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
