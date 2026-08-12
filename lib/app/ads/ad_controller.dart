import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/farm/application/analytics_events.dart';
import 'ad_config.dart';

enum InterstitialPlacement { gardenHome, progressReset, gardenComplete }

class AdController extends ChangeNotifier {
  AdController({
    required SharedPreferences preferences,
    required FarmAnalytics analytics,
  }) : _preferences = preferences,
       _analytics = analytics,
       _lastInterstitialShownAtMs = preferences.getInt(_lastShownKey) ?? 0;

  static const _lastShownKey = 'ads_last_interstitial_shown_at_ms';
  static const _minimumInterstitialGap = Duration(minutes: 6);
  static const _minimumActionsBetweenInterstitials = 4;

  final SharedPreferences _preferences;
  final FarmAnalytics _analytics;

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _initialized = false;
  bool _bannerLoading = false;
  bool _interstitialLoading = false;
  int _lastInterstitialShownAtMs;
  int _successfulActionsSinceInterstitial = 0;

  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerReady => _bannerAd != null;
  bool get canRequestAds => AdConfig.canRequestAds;

  Future<void> initialize() async {
    if (_initialized || !AdConfig.canRequestAds) {
      _log(FarmAnalyticsEvents.adsInitializeSkipped, <String, Object?>{
        'supported_platform': AdConfig.isSupportedPlatform,
        'production_ads': AdConfig.useProductionAds,
        'has_production_unit_ids': AdConfig.hasProductionUnitIds,
      });
      return;
    }

    try {
      final testIds = AdConfig.testDeviceIds;
      if (!AdConfig.useProductionAds || testIds.isNotEmpty) {
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: testIds),
        );
      }
      await MobileAds.instance.initialize();
      _initialized = true;
      _log(FarmAnalyticsEvents.adsInitialized, <String, Object?>{
        'production_ads': AdConfig.useProductionAds,
      });
      unawaited(loadBanner());
      unawaited(loadInterstitial());
    } on Object {
      _log(FarmAnalyticsEvents.adsInitializeFailed);
    }
  }

  void recordSuccessfulGameplayAction() {
    _successfulActionsSinceInterstitial += 1;
  }

  Future<void> loadBanner() async {
    if (!_initialized || _bannerLoading || _bannerAd != null) {
      return;
    }

    _bannerLoading = true;
    _log(FarmAnalyticsEvents.adBannerLoadRequested);
    final ad = BannerAd(
      adUnitId: AdConfig.bannerUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _bannerLoading = false;
          _bannerAd = ad as BannerAd;
          _log(FarmAnalyticsEvents.adBannerLoaded);
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          _bannerLoading = false;
          ad.dispose();
          _log(FarmAnalyticsEvents.adBannerFailed, <String, Object?>{
            'code': error.code,
            'domain': error.domain,
          });
          notifyListeners();
        },
        onAdImpression: (_) => _log(FarmAnalyticsEvents.adBannerImpression),
        onAdClicked: (_) => _log(FarmAnalyticsEvents.adBannerClicked),
      ),
    );

    try {
      ad.load();
    } on Object {
      _bannerLoading = false;
      ad.dispose();
      _log(FarmAnalyticsEvents.adBannerFailed);
    }
  }

  Future<void> loadInterstitial() async {
    if (!_initialized || _interstitialLoading || _interstitialAd != null) {
      return;
    }

    _interstitialLoading = true;
    _log(FarmAnalyticsEvents.adInterstitialLoadRequested);
    try {
      InterstitialAd.load(
        adUnitId: AdConfig.interstitialUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialLoading = false;
            _interstitialAd = ad;
            _interstitialAd?.fullScreenContentCallback =
                FullScreenContentCallback<InterstitialAd>(
                  onAdShowedFullScreenContent: (ad) {
                    _lastInterstitialShownAtMs =
                        DateTime.now().millisecondsSinceEpoch;
                    _successfulActionsSinceInterstitial = 0;
                    unawaited(
                      _preferences.setInt(
                        _lastShownKey,
                        _lastInterstitialShownAtMs,
                      ),
                    );
                    _log(FarmAnalyticsEvents.adInterstitialShown);
                  },
                  onAdDismissedFullScreenContent: (ad) {
                    ad.dispose();
                    _interstitialAd = null;
                    _log(FarmAnalyticsEvents.adInterstitialDismissed);
                    notifyListeners();
                    unawaited(loadInterstitial());
                  },
                  onAdFailedToShowFullScreenContent: (ad, error) {
                    ad.dispose();
                    _interstitialAd = null;
                    _log(
                      FarmAnalyticsEvents.adInterstitialShowFailed,
                      <String, Object?>{
                        'code': error.code,
                        'domain': error.domain,
                      },
                    );
                    notifyListeners();
                    unawaited(loadInterstitial());
                  },
                  onAdImpression: (_) =>
                      _log(FarmAnalyticsEvents.adInterstitialImpression),
                  onAdClicked: (_) =>
                      _log(FarmAnalyticsEvents.adInterstitialClicked),
                );
            _log(FarmAnalyticsEvents.adInterstitialLoaded);
            notifyListeners();
          },
          onAdFailedToLoad: (error) {
            _interstitialLoading = false;
            _log(FarmAnalyticsEvents.adInterstitialFailed, <String, Object?>{
              'code': error.code,
              'domain': error.domain,
            });
            notifyListeners();
          },
        ),
      );
    } on Object {
      _interstitialLoading = false;
      _log(FarmAnalyticsEvents.adInterstitialFailed);
    }
  }

  Future<void> maybeShowInterstitial(InterstitialPlacement placement) async {
    final placementName = placement.name;
    if (!_initialized || _interstitialAd == null) {
      _log(FarmAnalyticsEvents.adInterstitialSkipped, <String, Object?>{
        'placement': placementName,
        'reason': 'not_loaded',
      });
      unawaited(loadInterstitial());
      return;
    }

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final elapsedMs = nowMs - _lastInterstitialShownAtMs;
    final hasEnoughTime = elapsedMs >= _minimumInterstitialGap.inMilliseconds;
    final hasEnoughActions =
        _successfulActionsSinceInterstitial >=
        _minimumActionsBetweenInterstitials;
    final isCompletion = placement == InterstitialPlacement.gardenComplete;

    if (!hasEnoughTime || (!hasEnoughActions && !isCompletion)) {
      _log(FarmAnalyticsEvents.adInterstitialCapped, <String, Object?>{
        'placement': placementName,
        'elapsed_seconds': elapsedMs ~/ 1000,
        'actions_since_last': _successfulActionsSinceInterstitial,
      });
      return;
    }

    _log(FarmAnalyticsEvents.adInterstitialEligible, <String, Object?>{
      'placement': placementName,
    });

    try {
      await _interstitialAd?.show();
    } on Object {
      _log(FarmAnalyticsEvents.adInterstitialShowFailed, <String, Object?>{
        'placement': placementName,
      });
      _interstitialAd?.dispose();
      _interstitialAd = null;
      unawaited(loadInterstitial());
    }
  }

  void _log(String eventName, [Map<String, Object?> properties = const {}]) {
    _analytics.log(eventName, <String, Object?>{
      ...properties,
      'production_ads': AdConfig.useProductionAds,
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }
}
