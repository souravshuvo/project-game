import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../domain/game_model.dart';
import 'game_analytics.dart';

class GameAdConfig {
  const GameAdConfig({
    required this.useProductionAds,
    required this.androidInterstitialId,
    required this.iosInterstitialId,
  });

  factory GameAdConfig.fromEnvironment() {
    return const GameAdConfig(
      useProductionAds: bool.fromEnvironment('USE_PRODUCTION_ADS'),
      androidInterstitialId: String.fromEnvironment(
        'ADMOB_ANDROID_INTERSTITIAL_ID',
      ),
      iosInterstitialId: String.fromEnvironment('ADMOB_IOS_INTERSTITIAL_ID'),
    );
  }

  static const androidTestInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const iosTestInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  final bool useProductionAds;
  final String androidInterstitialId;
  final String iosInterstitialId;

  String get modeName => useProductionAds ? 'production' : 'test';

  bool get isSupportedPlatform {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  String get interstitialId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return useProductionAds ? iosInterstitialId : iosTestInterstitialId;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return useProductionAds
          ? androidInterstitialId
          : androidTestInterstitialId;
    }

    return '';
  }

  bool get canRequestInterstitial {
    return isSupportedPlatform && interstitialId.isNotEmpty;
  }
}

class AdFrequencyCap {
  const AdFrequencyCap({
    this.minFinishedLevelsBeforeFirstInterstitial = 2,
    this.minFinishedLevelsBetweenInterstitials = 3,
    this.minSecondsBetweenInterstitials = 180,
    this.maxInterstitialsPerSession = 8,
  });

  final int minFinishedLevelsBeforeFirstInterstitial;
  final int minFinishedLevelsBetweenInterstitials;
  final int minSecondsBetweenInterstitials;
  final int maxInterstitialsPerSession;
}

class AdFrequencyTracker {
  AdFrequencyTracker({this.cap = const AdFrequencyCap()});

  final AdFrequencyCap cap;

  int finishedTransitions = 0;
  int finishedTransitionsSinceLastInterstitial = 0;
  int interstitialsShown = 0;
  DateTime? lastInterstitialAt;

  void recordLevelEnd() {
    finishedTransitions += 1;
    finishedTransitionsSinceLastInterstitial += 1;
  }

  void recordInterstitialShown(DateTime now) {
    interstitialsShown += 1;
    finishedTransitionsSinceLastInterstitial = 0;
    lastInterstitialAt = now;
  }

  String? skipReason(DateTime now) {
    if (finishedTransitions < cap.minFinishedLevelsBeforeFirstInterstitial) {
      return 'early_session';
    }
    if (finishedTransitionsSinceLastInterstitial <
        cap.minFinishedLevelsBetweenInterstitials) {
      return 'level_frequency_cap';
    }
    if (interstitialsShown >= cap.maxInterstitialsPerSession) {
      return 'session_cap';
    }

    final lastShown = lastInterstitialAt;
    if (lastShown != null &&
        now.difference(lastShown).inSeconds <
            cap.minSecondsBetweenInterstitials) {
      return 'time_frequency_cap';
    }

    return null;
  }
}

abstract class GameAdService {
  Future<void> initialize();

  Future<void> preloadInterstitial();

  Future<void> showLevelEndInterstitial({
    required GameSnapshot snapshot,
    required FutureOr<void> Function() afterAd,
  });

  Future<void> dispose();
}

class NoopGameAdService implements GameAdService {
  const NoopGameAdService();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> preloadInterstitial() async {}

  @override
  Future<void> showLevelEndInterstitial({
    required GameSnapshot snapshot,
    required FutureOr<void> Function() afterAd,
  }) async {
    await afterAd();
  }

  @override
  Future<void> dispose() async {}
}

class GoogleMobileAdsGameAdService implements GameAdService {
  GoogleMobileAdsGameAdService({
    required this.analytics,
    GameAdConfig? config,
    AdFrequencyTracker? frequencyTracker,
  }) : config = config ?? GameAdConfig.fromEnvironment(),
       frequencyTracker = frequencyTracker ?? AdFrequencyTracker();

  final GameAnalytics analytics;
  final GameAdConfig config;
  final AdFrequencyTracker frequencyTracker;

  InterstitialAd? _interstitialAd;
  bool _initialized = false;
  bool _isLoadingInterstitial = false;
  bool _isShowingInterstitial = false;

  @override
  Future<void> initialize() async {
    if (!config.canRequestInterstitial) {
      await analytics.logEvent('ads_disabled', {
        'reason': config.isSupportedPlatform
            ? 'missing_ad_unit_id'
            : 'unsupported_platform',
        'ad_mode': config.modeName,
      });
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      await analytics.logEvent('ads_initialized', {'ad_mode': config.modeName});
      await preloadInterstitial();
    } on Object catch (error) {
      await analytics.logEvent('ads_initialize_failed', {
        'error': '$error',
        'ad_mode': config.modeName,
      });
    }
  }

  @override
  Future<void> preloadInterstitial() async {
    if (!_initialized ||
        !config.canRequestInterstitial ||
        _isLoadingInterstitial ||
        _interstitialAd != null) {
      return;
    }

    _isLoadingInterstitial = true;
    await analytics.logEvent('ad_interstitial_request', {
      'ad_mode': config.modeName,
    });

    try {
      await InterstitialAd.load(
        adUnitId: config.interstitialId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _isLoadingInterstitial = false;
            _interstitialAd = ad;
            unawaited(
              analytics.logEvent('ad_interstitial_loaded', {
                'ad_mode': config.modeName,
              }),
            );
          },
          onAdFailedToLoad: (error) {
            _isLoadingInterstitial = false;
            unawaited(
              analytics.logEvent('ad_interstitial_load_failed', {
                'ad_mode': config.modeName,
                'code': error.code,
                'domain': error.domain,
                'message': error.message,
              }),
            );
          },
        ),
      );
    } on Object catch (error) {
      _isLoadingInterstitial = false;
      await analytics.logEvent('ad_interstitial_load_failed', {
        'ad_mode': config.modeName,
        'error': '$error',
      });
    }
  }

  @override
  Future<void> showLevelEndInterstitial({
    required GameSnapshot snapshot,
    required FutureOr<void> Function() afterAd,
  }) async {
    frequencyTracker.recordLevelEnd();
    final now = DateTime.now();
    final skipReason = _skipReason(snapshot, now);
    if (skipReason != null) {
      await analytics.logEvent('ad_interstitial_skipped', {
        'reason': skipReason,
        'level_number': snapshot.levelNumber,
        'level_result': snapshot.phase.name,
        'ad_mode': config.modeName,
      });
      unawaited(preloadInterstitial());
      await afterAd();
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      await analytics.logEvent('ad_interstitial_skipped', {
        'reason': 'not_loaded',
        'level_number': snapshot.levelNumber,
        'level_result': snapshot.phase.name,
        'ad_mode': config.modeName,
      });
      unawaited(preloadInterstitial());
      await afterAd();
      return;
    }

    _interstitialAd = null;
    _isShowingInterstitial = true;
    frequencyTracker.recordInterstitialShown(now);
    await analytics.logEvent('ad_interstitial_show', {
      'level_number': snapshot.levelNumber,
      'level_result': snapshot.phase.name,
      'ad_mode': config.modeName,
    });

    final dismissed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (shownAd) {
        shownAd.dispose();
        _isShowingInterstitial = false;
        unawaited(
          analytics.logEvent('ad_interstitial_dismissed', {
            'level_number': snapshot.levelNumber,
            'level_result': snapshot.phase.name,
            'ad_mode': config.modeName,
          }),
        );
        unawaited(preloadInterstitial());
        if (!dismissed.isCompleted) {
          dismissed.complete();
        }
      },
      onAdFailedToShowFullScreenContent: (shownAd, error) {
        shownAd.dispose();
        _isShowingInterstitial = false;
        unawaited(
          analytics.logEvent('ad_interstitial_show_failed', {
            'level_number': snapshot.levelNumber,
            'level_result': snapshot.phase.name,
            'code': error.code,
            'domain': error.domain,
            'message': error.message,
            'ad_mode': config.modeName,
          }),
        );
        unawaited(preloadInterstitial());
        if (!dismissed.isCompleted) {
          dismissed.complete();
        }
      },
    );

    try {
      await ad.show();
      await dismissed.future;
    } on Object catch (error) {
      _isShowingInterstitial = false;
      ad.dispose();
      await analytics.logEvent('ad_interstitial_show_failed', {
        'level_number': snapshot.levelNumber,
        'level_result': snapshot.phase.name,
        'error': '$error',
        'ad_mode': config.modeName,
      });
      unawaited(preloadInterstitial());
    }

    await afterAd();
  }

  String? _skipReason(GameSnapshot snapshot, DateTime now) {
    if (!snapshot.isFinished) {
      return 'active_gameplay';
    }
    if (!_initialized) {
      return 'not_initialized';
    }
    if (!config.canRequestInterstitial) {
      return config.isSupportedPlatform
          ? 'missing_ad_unit_id'
          : 'unsupported_platform';
    }
    if (_isShowingInterstitial) {
      return 'already_showing';
    }
    return frequencyTracker.skipReason(now);
  }

  @override
  Future<void> dispose() async {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
