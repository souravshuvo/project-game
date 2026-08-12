import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../analytics/game_analytics.dart';
import 'ad_config.dart';
import 'ad_frequency_cap.dart';
import 'app_ads_controller.dart';

class GoogleMobileAdsController implements AppAdsController {
  GoogleMobileAdsController({
    required this.config,
    required this.analytics,
    InterstitialFrequencyCap? frequencyCap,
  }) : _frequencyCap = frequencyCap ?? InterstitialFrequencyCap() {
    _initialization = _initialize();
  }

  final AdMobConfig config;
  final GameAnalytics analytics;
  final InterstitialFrequencyCap _frequencyCap;

  late final Future<bool> _initialization;
  InterstitialAd? _interstitialAd;
  bool _isLoadingInterstitial = false;
  bool _disposed = false;

  @override
  bool get isEnabled => config.servesAds && !_disposed;

  @override
  Widget buildHomeBanner() {
    if (!isEnabled) {
      return const SizedBox.shrink();
    }
    return SafeHomeBannerAd(
      config: config,
      analytics: analytics,
      initialization: _initialization,
    );
  }

  @override
  void preloadInterstitial() {
    if (!isEnabled || _interstitialAd != null || _isLoadingInterstitial) {
      return;
    }
    unawaited(_loadInterstitial());
  }

  @override
  Future<void> recordCompletedGameBreak({
    required String gameId,
    required String gameTitle,
  }) async {
    if (!isEnabled) {
      analytics.adOpportunity(
        placement: 'completed_game_home_return',
        format: 'interstitial',
        adMode: config.modeName,
        decision: 'blocked',
        reason: config.disabledReason ?? 'ads_disabled',
        gameId: gameId,
      );
      return;
    }

    _frequencyCap.recordGameCompletion();
    final decision = _frequencyCap.evaluate();
    analytics.adOpportunity(
      placement: 'completed_game_home_return',
      format: 'interstitial',
      adMode: config.modeName,
      decision: decision.allowed ? 'allowed' : 'blocked',
      reason: decision.reason,
      gameId: gameId,
    );
    if (!decision.allowed) {
      preloadInterstitial();
      return;
    }

    await _showInterstitial(gameId: gameId);
  }

  Future<bool> _initialize() async {
    if (!config.servesAds) {
      return false;
    }
    try {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          maxAdContentRating: MaxAdContentRating.g,
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
          testDeviceIds: config.testDeviceIds,
        ),
      );
      await MobileAds.instance.initialize().timeout(const Duration(seconds: 4));
      analytics.adEvent(
        event: 'init',
        placement: 'app_start',
        format: 'sdk',
        adMode: config.modeName,
      );
      preloadInterstitial();
      return true;
    } on Object catch (error) {
      analytics.adEvent(
        event: 'error',
        placement: 'app_start',
        format: 'sdk',
        adMode: config.modeName,
        reason: 'init_failed_$error',
      );
      return false;
    }
  }

  Future<void> _loadInterstitial() async {
    if (!isEnabled || _interstitialAd != null || _isLoadingInterstitial) {
      return;
    }
    _isLoadingInterstitial = true;
    try {
      final ready = await _initialization;
      if (!ready || !isEnabled || _interstitialAd != null) {
        return;
      }
      await InterstitialAd.load(
        adUnitId: config.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            analytics.adEvent(
              event: 'load',
              placement: 'completed_game_home_return',
              format: 'interstitial',
              adMode: config.modeName,
            );
          },
          onAdFailedToLoad: (error) {
            analytics.adEvent(
              event: 'error',
              placement: 'completed_game_home_return',
              format: 'interstitial',
              adMode: config.modeName,
              reason: 'load_failed_$error',
            );
          },
        ),
      );
    } on Object catch (error) {
      analytics.adEvent(
        event: 'error',
        placement: 'completed_game_home_return',
        format: 'interstitial',
        adMode: config.modeName,
        reason: 'load_exception_$error',
      );
    } finally {
      _isLoadingInterstitial = false;
    }
  }

  Future<void> _showInterstitial({required String gameId}) async {
    try {
      final ready = await _initialization;
      final ad = _interstitialAd;
      _interstitialAd = null;
      if (!ready || !isEnabled || ad == null) {
        analytics.adOpportunity(
          placement: 'completed_game_home_return',
          format: 'interstitial',
          adMode: config.modeName,
          decision: 'blocked',
          reason: 'not_loaded',
          gameId: gameId,
        );
        preloadInterstitial();
        return;
      }

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          _frequencyCap.recordInterstitialShown();
          analytics.adEvent(
            event: 'show',
            placement: 'completed_game_home_return',
            format: 'interstitial',
            adMode: config.modeName,
            gameId: gameId,
          );
        },
        onAdImpression: (ad) {
          analytics.adEvent(
            event: 'impression',
            placement: 'completed_game_home_return',
            format: 'interstitial',
            adMode: config.modeName,
            gameId: gameId,
          );
        },
        onAdClicked: (ad) {
          analytics.adEvent(
            event: 'click',
            placement: 'completed_game_home_return',
            format: 'interstitial',
            adMode: config.modeName,
            gameId: gameId,
          );
        },
        onAdDismissedFullScreenContent: (ad) {
          unawaited(ad.dispose());
          analytics.adEvent(
            event: 'dismiss',
            placement: 'completed_game_home_return',
            format: 'interstitial',
            adMode: config.modeName,
            gameId: gameId,
          );
          preloadInterstitial();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          unawaited(ad.dispose());
          analytics.adEvent(
            event: 'error',
            placement: 'completed_game_home_return',
            format: 'interstitial',
            adMode: config.modeName,
            gameId: gameId,
            reason: 'show_failed_$error',
          );
          preloadInterstitial();
        },
      );

      await ad.show();
    } on Object catch (error) {
      analytics.adEvent(
        event: 'error',
        placement: 'completed_game_home_return',
        format: 'interstitial',
        adMode: config.modeName,
        gameId: gameId,
        reason: 'show_exception_$error',
      );
      preloadInterstitial();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    final ad = _interstitialAd;
    if (ad != null) {
      unawaited(ad.dispose());
    }
    _interstitialAd = null;
  }
}

class SafeHomeBannerAd extends StatefulWidget {
  const SafeHomeBannerAd({
    required this.config,
    required this.analytics,
    required this.initialization,
    super.key,
  });

  final AdMobConfig config;
  final GameAnalytics analytics;
  final Future<bool> initialization;

  @override
  State<SafeHomeBannerAd> createState() => _SafeHomeBannerAdState();
}

class _SafeHomeBannerAdState extends State<SafeHomeBannerAd> {
  BannerAd? _bannerAd;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    if (!widget.config.servesAds) {
      return;
    }
    try {
      final ready = await widget.initialization;
      if (!ready || !mounted || !widget.config.servesAds) {
        return;
      }

      final banner = BannerAd(
        adUnitId: widget.config.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!mounted) {
              unawaited(ad.dispose());
              return;
            }
            setState(() {
              _bannerAd = ad as BannerAd;
              _loaded = true;
            });
            widget.analytics.adEvent(
              event: 'load',
              placement: 'home_footer',
              format: 'banner',
              adMode: widget.config.modeName,
            );
          },
          onAdFailedToLoad: (ad, error) {
            unawaited(ad.dispose());
            widget.analytics.adEvent(
              event: 'error',
              placement: 'home_footer',
              format: 'banner',
              adMode: widget.config.modeName,
              reason: 'load_failed_$error',
            );
          },
          onAdImpression: (ad) {
            widget.analytics.adEvent(
              event: 'impression',
              placement: 'home_footer',
              format: 'banner',
              adMode: widget.config.modeName,
            );
          },
          onAdClicked: (ad) {
            widget.analytics.adEvent(
              event: 'click',
              placement: 'home_footer',
              format: 'banner',
              adMode: widget.config.modeName,
            );
          },
        ),
      );
      await banner.load();
    } on Object catch (error) {
      widget.analytics.adEvent(
        event: 'error',
        placement: 'home_footer',
        format: 'banner',
        adMode: widget.config.modeName,
        reason: 'load_exception_$error',
      );
    }
  }

  @override
  void dispose() {
    final banner = _bannerAd;
    if (banner != null) {
      unawaited(banner.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _bannerAd;
    if (!_loaded || banner == null) {
      return const SizedBox.shrink();
    }

    return Semantics(
      label: 'Advertisement',
      child: SizedBox(
        width: banner.size.width.toDouble(),
        height: banner.size.height.toDouble(),
        child: AdWidget(ad: banner),
      ),
    );
  }
}
