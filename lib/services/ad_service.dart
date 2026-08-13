import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_frequency_cap.dart';
import 'analytics_service.dart';

class AdPlacements {
  const AdPlacements._();

  static const mainMenu = 'main_menu';
  static const matchResult = 'match_result';
  static const matchEndInterstitial = 'match_end';
}

class AdFormats {
  const AdFormats._();

  static const banner = 'banner';
  static const interstitial = 'interstitial';
}

class GameAdService {
  GameAdService(this._analytics, {InterstitialFrequencyCap? frequencyCap})
    : _frequencyCap = frequencyCap ?? InterstitialFrequencyCap();

  static const _useTestAds = bool.fromEnvironment(
    'USE_TEST_ADS',
    defaultValue: true,
  );

  static const _androidTestBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _iosTestBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const _androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const _iosTestInterstitial =
      'ca-app-pub-3940256099942544/4411468910';

  static const _androidProdBanner = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_ID',
  );
  static const _iosProdBanner = String.fromEnvironment('ADMOB_IOS_BANNER_ID');
  static const _androidProdInterstitial = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL_ID',
  );
  static const _iosProdInterstitial = String.fromEnvironment(
    'ADMOB_IOS_INTERSTITIAL_ID',
  );

  final GameAnalytics _analytics;
  final InterstitialFrequencyCap _frequencyCap;

  InterstitialAd? _interstitialAd;
  bool _initialized = false;
  bool _interstitialLoading = false;

  bool get useTestAds => _useTestAds;

  bool get canRequestAds => _initialized && _hasConfiguredAdUnits;

  String get bannerAdUnitId {
    if (_useTestAds) {
      return Platform.isIOS ? _iosTestBanner : _androidTestBanner;
    }

    return Platform.isIOS ? _iosProdBanner : _androidProdBanner;
  }

  String get interstitialAdUnitId {
    if (_useTestAds) {
      return Platform.isIOS ? _iosTestInterstitial : _androidTestInterstitial;
    }

    return Platform.isIOS ? _iosProdInterstitial : _androidProdInterstitial;
  }

  bool get _hasConfiguredAdUnits {
    return bannerAdUnitId.isNotEmpty && interstitialAdUnitId.isNotEmpty;
  }

  Future<void> initialize() async {
    if (!_hasConfiguredAdUnits) {
      await _analytics.logAdEvent(
        'ad_config_missing',
        format: 'all',
        placement: 'startup',
        testAds: _useTestAds,
      );
      return;
    }

    try {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          maxAdContentRating: MaxAdContentRating.g,
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
          tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
        ),
      );
      await MobileAds.instance.initialize();
      _initialized = true;
      unawaited(loadInterstitial());
    } catch (error) {
      _initialized = false;
      debugPrint('AdMob disabled: $error');
      await _analytics.logAdEvent(
        'ad_init_failed',
        format: 'all',
        placement: 'startup',
        reason: error.toString(),
        testAds: _useTestAds,
      );
    }
  }

  void recordMatchCompleted() {
    _frequencyCap.recordMatchCompleted();
    unawaited(loadInterstitial());
  }

  Future<void> loadInterstitial() async {
    if (!canRequestAds || _interstitialAd != null || _interstitialLoading) {
      return;
    }

    _interstitialLoading = true;
    await _analytics.logAdEvent(
      'ad_request',
      format: AdFormats.interstitial,
      placement: AdPlacements.matchEndInterstitial,
      testAds: _useTestAds,
    );

    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialLoading = false;
            _interstitialAd = ad;
            unawaited(
              _analytics.logAdEvent(
                'ad_loaded',
                format: AdFormats.interstitial,
                placement: AdPlacements.matchEndInterstitial,
                testAds: _useTestAds,
              ),
            );
          },
          onAdFailedToLoad: (error) {
            _interstitialLoading = false;
            _interstitialAd = null;
            unawaited(
              _analytics.logAdEvent(
                'ad_load_failed',
                format: AdFormats.interstitial,
                placement: AdPlacements.matchEndInterstitial,
                reason: error.code.toString(),
                testAds: _useTestAds,
              ),
            );
          },
        ),
      );
    } catch (error) {
      _interstitialLoading = false;
      _interstitialAd = null;
      debugPrint('Interstitial load skipped: $error');
      await _analytics.logAdEvent(
        'ad_load_failed',
        format: AdFormats.interstitial,
        placement: AdPlacements.matchEndInterstitial,
        reason: error.toString(),
        testAds: _useTestAds,
      );
    }
  }

  Future<void> maybeShowMatchEndInterstitial({
    required bool appIsInSafeBreak,
  }) async {
    final now = DateTime.now();
    final decision = _frequencyCap.evaluate(
      now: now,
      adsEnabled: canRequestAds,
      adReady: _interstitialAd != null,
      safeBreak: appIsInSafeBreak,
    );

    if (!decision.canShow) {
      await _analytics.logAdEvent(
        'ad_show_blocked',
        format: AdFormats.interstitial,
        placement: AdPlacements.matchEndInterstitial,
        reason: decision.reason,
        testAds: _useTestAds,
      );
      if (decision.reason == 'ad_not_ready') {
        unawaited(loadInterstitial());
      }
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      return;
    }

    _interstitialAd = null;
    _frequencyCap.recordShown(now);

    await _analytics.logAdEvent(
      'ad_show_attempt',
      format: AdFormats.interstitial,
      placement: AdPlacements.matchEndInterstitial,
      testAds: _useTestAds,
    );

    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdShowedFullScreenContent: (shownAd) {
        unawaited(
          _analytics.logAdEvent(
            'ad_show',
            format: AdFormats.interstitial,
            placement: AdPlacements.matchEndInterstitial,
            testAds: _useTestAds,
          ),
        );
      },
      onAdImpression: (shownAd) {
        unawaited(
          _analytics.logAdEvent(
            'ad_impression',
            format: AdFormats.interstitial,
            placement: AdPlacements.matchEndInterstitial,
            testAds: _useTestAds,
          ),
        );
      },
      onAdClicked: (shownAd) {
        unawaited(
          _analytics.logAdEvent(
            'ad_clicked',
            format: AdFormats.interstitial,
            placement: AdPlacements.matchEndInterstitial,
            testAds: _useTestAds,
          ),
        );
      },
      onAdDismissedFullScreenContent: (dismissedAd) {
        unawaited(dismissedAd.dispose());
        unawaited(
          _analytics.logAdEvent(
            'ad_dismissed',
            format: AdFormats.interstitial,
            placement: AdPlacements.matchEndInterstitial,
            testAds: _useTestAds,
          ),
        );
        unawaited(loadInterstitial());
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        unawaited(failedAd.dispose());
        unawaited(
          _analytics.logAdEvent(
            'ad_show_failed',
            format: AdFormats.interstitial,
            placement: AdPlacements.matchEndInterstitial,
            reason: error.code.toString(),
            testAds: _useTestAds,
          ),
        );
        unawaited(loadInterstitial());
      },
    );

    try {
      await ad.show();
    } catch (error) {
      unawaited(ad.dispose());
      debugPrint('Interstitial show skipped: $error');
      await _analytics.logAdEvent(
        'ad_show_failed',
        format: AdFormats.interstitial,
        placement: AdPlacements.matchEndInterstitial,
        reason: error.toString(),
        testAds: _useTestAds,
      );
      unawaited(loadInterstitial());
    }
  }
}
