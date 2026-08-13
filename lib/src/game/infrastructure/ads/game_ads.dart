import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../analytics/game_analytics.dart';

class GameAdConfig {
  const GameAdConfig._();

  static const environment = String.fromEnvironment(
    'AD_ENVIRONMENT',
    defaultValue: 'test',
  );
  static const androidInterstitialId = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL_ID',
  );
  static const iosInterstitialId = String.fromEnvironment(
    'ADMOB_IOS_INTERSTITIAL_ID',
  );

  static const testAndroidInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const testIosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  static bool get isProduction => environment == 'production';

  static String? get interstitialAdUnitId {
    if (isProduction) {
      final id = Platform.isAndroid ? androidInterstitialId : iosInterstitialId;
      return id.isEmpty ? null : id;
    }
    return Platform.isAndroid
        ? testAndroidInterstitialId
        : testIosInterstitialId;
  }
}

class GameAdsController {
  GameAdsController._({
    required GameAnalytics analytics,
    required bool initialized,
  }) : _analytics = analytics,
       _initialized = initialized;

  static const minMatchesBetweenInterstitials = 2;
  static const minInterstitialInterval = Duration(minutes: 8);
  static const postResultDelay = Duration(milliseconds: 900);
  static const placementMatchEnd = 'match_end';

  final GameAnalytics _analytics;
  final bool _initialized;
  InterstitialAd? _interstitialAd;
  bool _isLoadingInterstitial = false;
  bool _isShowingInterstitial = false;
  bool _activeGameplay = false;
  int _completedMatchesSinceInterstitial = 0;
  DateTime? _lastInterstitialShownAt;

  bool get isInitialized => _initialized;
  bool get hasLoadedInterstitial => _interstitialAd != null;

  factory GameAdsController.disabled(GameAnalytics analytics) {
    return GameAdsController._(analytics: analytics, initialized: false);
  }

  static Future<GameAdsController> initialize(GameAnalytics analytics) async {
    try {
      await MobileAds.instance.initialize();
      final controller = GameAdsController._(
        analytics: analytics,
        initialized: true,
      );
      controller.loadInterstitial();
      return controller;
    } catch (error) {
      await analytics.logAdEvent(
        action: 'initialize_failed',
        placement: 'startup',
        adFormat: 'interstitial',
        error: error.toString(),
      );
      debugPrint('AdMob disabled: $error');
      return GameAdsController._(analytics: analytics, initialized: false);
    }
  }

  void markGameplayStarted() {
    _activeGameplay = true;
  }

  void markGameplayEnded() {
    _activeGameplay = false;
  }

  void markMatchFinished() {
    _activeGameplay = false;
    _completedMatchesSinceInterstitial++;
    loadInterstitial();
  }

  void loadInterstitial() {
    if (!_initialized ||
        _isLoadingInterstitial ||
        _interstitialAd != null ||
        GameAdConfig.interstitialAdUnitId == null) {
      return;
    }

    _isLoadingInterstitial = true;
    unawaited(
      _analytics.logAdEvent(
        action: 'load_requested',
        placement: placementMatchEnd,
        adFormat: 'interstitial',
      ),
    );

    InterstitialAd.load(
      adUnitId: GameAdConfig.interstitialAdUnitId!,
      request: const AdRequest(nonPersonalizedAds: true),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingInterstitial = false;
          _interstitialAd = ad..setImmersiveMode(true);
          unawaited(
            _analytics.logAdEvent(
              action: 'loaded',
              placement: placementMatchEnd,
              adFormat: 'interstitial',
            ),
          );
        },
        onAdFailedToLoad: (error) {
          _isLoadingInterstitial = false;
          _interstitialAd = null;
          unawaited(
            _analytics.logAdEvent(
              action: 'load_failed',
              placement: placementMatchEnd,
              adFormat: 'interstitial',
              error: error.toString(),
            ),
          );
        },
      ),
    );
  }

  Future<bool> maybeShowMatchEndInterstitial() async {
    final skipReason = _skipReason();
    if (skipReason != null) {
      await _analytics.logAdEvent(
        action: 'show_skipped',
        placement: placementMatchEnd,
        adFormat: 'interstitial',
        reason: skipReason,
      );
      loadInterstitial();
      return false;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      return false;
    }

    _interstitialAd = null;
    _isShowingInterstitial = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        _completedMatchesSinceInterstitial = 0;
        _lastInterstitialShownAt = DateTime.now();
        unawaited(
          _analytics.logAdEvent(
            action: 'shown',
            placement: placementMatchEnd,
            adFormat: 'interstitial',
          ),
        );
      },
      onAdDismissedFullScreenContent: (dismissedAd) {
        _isShowingInterstitial = false;
        dismissedAd.dispose();
        unawaited(
          _analytics.logAdEvent(
            action: 'dismissed',
            placement: placementMatchEnd,
            adFormat: 'interstitial',
          ),
        );
        loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        _isShowingInterstitial = false;
        failedAd.dispose();
        unawaited(
          _analytics.logAdEvent(
            action: 'show_failed',
            placement: placementMatchEnd,
            adFormat: 'interstitial',
            error: error.toString(),
          ),
        );
        loadInterstitial();
      },
    );

    try {
      ad.show();
      return true;
    } catch (error) {
      _isShowingInterstitial = false;
      ad.dispose();
      await _analytics.logAdEvent(
        action: 'show_failed',
        placement: placementMatchEnd,
        adFormat: 'interstitial',
        error: error.toString(),
      );
      loadInterstitial();
      return false;
    }
  }

  String? _skipReason() {
    if (!_initialized) {
      return 'not_initialized';
    }
    if (_activeGameplay) {
      return 'active_gameplay';
    }
    if (_isShowingInterstitial) {
      return 'already_showing';
    }
    if (_interstitialAd == null) {
      return 'not_loaded';
    }
    if (_completedMatchesSinceInterstitial < minMatchesBetweenInterstitials) {
      return 'frequency_match_count';
    }
    final lastShownAt = _lastInterstitialShownAt;
    if (lastShownAt != null &&
        DateTime.now().difference(lastShownAt) < minInterstitialInterval) {
      return 'frequency_time';
    }
    return null;
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}

class GameAdsScope extends InheritedWidget {
  const GameAdsScope({super.key, required this.ads, required super.child});

  final GameAdsController ads;

  static GameAdsController read(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<GameAdsScope>()
        ?.widget;
    final adsScope = scope as GameAdsScope?;
    assert(adsScope != null, 'GameAdsScope is missing.');
    return adsScope!.ads;
  }

  @override
  bool updateShouldNotify(GameAdsScope oldWidget) {
    return ads != oldWidget.ads;
  }
}
