import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../data/local_save_store.dart';
import '../domain/run_stats.dart';
import 'analytics_sink.dart';

enum AdPlacement { menuBanner, gameOverBanner, gameOverTransition }

extension AdPlacementName on AdPlacement {
  String get analyticsName => switch (this) {
    AdPlacement.menuBanner => 'menu_banner',
    AdPlacement.gameOverBanner => 'game_over_banner',
    AdPlacement.gameOverTransition => 'game_over_transition',
  };
}

class AdMobConfig {
  const AdMobConfig._();

  static const useProductionAds = bool.fromEnvironment('TRAIL_ARENA_PROD_ADS');

  static const _androidTestBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const _iosTestBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const _iosTestInterstitial = 'ca-app-pub-3940256099942544/4411468910';

  static const _androidProdBanner = String.fromEnvironment(
    'TRAIL_ARENA_ANDROID_BANNER_AD_UNIT_ID',
  );
  static const _androidProdInterstitial = String.fromEnvironment(
    'TRAIL_ARENA_ANDROID_INTERSTITIAL_AD_UNIT_ID',
  );
  static const _iosProdBanner = String.fromEnvironment(
    'TRAIL_ARENA_IOS_BANNER_AD_UNIT_ID',
  );
  static const _iosProdInterstitial = String.fromEnvironment(
    'TRAIL_ARENA_IOS_INTERSTITIAL_AD_UNIT_ID',
  );

  static final request = AdRequest(nonPersonalizedAds: true);

  static String get modeName => useProductionAds ? 'production' : 'test';

  static bool get isSupportedPlatform {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
  }

  static String? bannerUnitId() {
    if (!isSupportedPlatform) {
      return null;
    }
    if (!useProductionAds) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? _iosTestBanner
          : _androidTestBanner;
    }
    final id = defaultTargetPlatform == TargetPlatform.iOS
        ? _iosProdBanner
        : _androidProdBanner;
    return id.isEmpty ? null : id;
  }

  static String? interstitialUnitId() {
    if (!isSupportedPlatform) {
      return null;
    }
    if (!useProductionAds) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? _iosTestInterstitial
          : _androidTestInterstitial;
    }
    final id = defaultTargetPlatform == TargetPlatform.iOS
        ? _iosProdInterstitial
        : _androidProdInterstitial;
    return id.isEmpty ? null : id;
  }
}

class AdMobService extends ChangeNotifier {
  AdMobService({
    required AnalyticsSink analytics,
    required LocalSaveStore saveStore,
  }) : _analytics = analytics,
       _saveStore = saveStore;

  static const minRunsBeforeInterstitial = 3;
  static const minRunSecondsForInterstitial = 20;
  static const minInterstitialSpacing = Duration(minutes: 2);

  final AnalyticsSink _analytics;
  final LocalSaveStore _saveStore;

  InterstitialAd? _interstitialAd;
  AdFrequencyData _frequency = AdFrequencyData.empty;
  bool _initialized = false;
  bool _initializing = false;
  bool _loadingInterstitial = false;
  bool _showingInterstitial = false;

  bool get canRequestAds => AdMobConfig.isSupportedPlatform;

  Future<void> initialize() async {
    if (_initializing || _initialized || !canRequestAds) {
      return;
    }
    _initializing = true;
    try {
      _frequency = await _saveStore.loadAdFrequency();
      await MobileAds.instance.initialize();
      _initialized = true;
      _analytics.log('ad_sdk_initialized', {'ad_mode': AdMobConfig.modeName});
      _loadInterstitial();
    } catch (error) {
      _analytics.log('ad_sdk_init_failed', {'error': error.toString()});
    } finally {
      _initializing = false;
    }
  }

  void recordCompletedRun(RunStats stats) {
    _frequency = _frequency.copyWith(
      completedRunsSinceInterstitial:
          _frequency.completedRunsSinceInterstitial + 1,
    );
    unawaited(_saveStore.saveAdFrequency(_frequency));
    _analytics.log('game_run_complete_for_ads', {
      'score': stats.score,
      'duration_seconds': stats.survivalSeconds.floor(),
      'runs_since_interstitial': _frequency.completedRunsSinceInterstitial,
    });
    _loadInterstitial();
  }

  Future<void> showInterstitialAtTransition({
    required RunStats runStats,
    required VoidCallback onComplete,
  }) async {
    if (!_isEligible(runStats)) {
      _analytics.log('ad_interstitial_skipped', {
        'placement': AdPlacement.gameOverTransition.analyticsName,
        'reason': _skipReason(runStats),
        'runs_since_interstitial': _frequency.completedRunsSinceInterstitial,
      });
      onComplete();
      _loadInterstitial();
      return;
    }

    final ad = _interstitialAd;
    if (ad == null || _showingInterstitial) {
      _analytics.log('ad_interstitial_unavailable', {
        'placement': AdPlacement.gameOverTransition.analyticsName,
      });
      onComplete();
      _loadInterstitial();
      return;
    }

    _interstitialAd = null;
    _showingInterstitial = true;
    var completed = false;

    void finish({required bool consumedCap}) {
      if (completed) {
        return;
      }
      completed = true;
      _showingInterstitial = false;
      if (consumedCap) {
        _frequency = _frequency.copyWith(
          completedRunsSinceInterstitial: 0,
          lastInterstitialAtMillis: DateTime.now().millisecondsSinceEpoch,
        );
        unawaited(_saveStore.saveAdFrequency(_frequency));
      }
      _loadInterstitial();
      onComplete();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdShowedFullScreenContent: (ad) {
        _analytics.log('ad_interstitial_show', {
          'placement': AdPlacement.gameOverTransition.analyticsName,
          'ad_mode': AdMobConfig.modeName,
        });
      },
      onAdDismissedFullScreenContent: (ad) {
        _analytics.log('ad_interstitial_dismissed', {
          'placement': AdPlacement.gameOverTransition.analyticsName,
        });
        ad.dispose();
        finish(consumedCap: true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _analytics.log('ad_interstitial_show_failed', {
          'placement': AdPlacement.gameOverTransition.analyticsName,
          'error_code': error.code,
          'error_message': error.message,
        });
        ad.dispose();
        finish(consumedCap: false);
      },
      onAdImpression: (ad) {
        _analytics.log('ad_interstitial_impression', {
          'placement': AdPlacement.gameOverTransition.analyticsName,
        });
      },
      onAdClicked: (ad) {
        _analytics.log('ad_interstitial_click', {
          'placement': AdPlacement.gameOverTransition.analyticsName,
        });
      },
    );

    try {
      await ad.show();
    } catch (error) {
      _analytics.log('ad_interstitial_show_failed', {
        'placement': AdPlacement.gameOverTransition.analyticsName,
        'error_message': error.toString(),
      });
      ad.dispose();
      finish(consumedCap: false);
    }
  }

  void _loadInterstitial() {
    if (!_initialized || _loadingInterstitial || _interstitialAd != null) {
      return;
    }
    final unitId = AdMobConfig.interstitialUnitId();
    if (unitId == null) {
      _analytics.log('ad_interstitial_disabled', {
        'reason': 'missing_unit_id_or_platform',
        'ad_mode': AdMobConfig.modeName,
      });
      return;
    }

    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: unitId,
      request: AdMobConfig.request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingInterstitial = false;
          _interstitialAd = ad;
          _analytics.log('ad_interstitial_loaded', {
            'placement': AdPlacement.gameOverTransition.analyticsName,
            'ad_mode': AdMobConfig.modeName,
          });
        },
        onAdFailedToLoad: (error) {
          _loadingInterstitial = false;
          _analytics.log('ad_interstitial_load_failed', {
            'placement': AdPlacement.gameOverTransition.analyticsName,
            'error_code': error.code,
            'error_message': error.message,
          });
        },
      ),
    );
  }

  bool _isEligible(RunStats stats) {
    if (!_initialized || !canRequestAds) {
      return false;
    }
    if (_frequency.completedRunsSinceInterstitial < minRunsBeforeInterstitial) {
      return false;
    }
    if (stats.survivalSeconds < minRunSecondsForInterstitial) {
      return false;
    }
    final lastAt = _frequency.lastInterstitialAtMillis;
    if (lastAt == null) {
      return true;
    }
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastAt;
    return elapsed >= minInterstitialSpacing.inMilliseconds;
  }

  String _skipReason(RunStats stats) {
    if (!_initialized || !canRequestAds) {
      return 'sdk_not_ready';
    }
    if (_frequency.completedRunsSinceInterstitial < minRunsBeforeInterstitial) {
      return 'run_cap';
    }
    if (stats.survivalSeconds < minRunSecondsForInterstitial) {
      return 'short_run';
    }
    final lastAt = _frequency.lastInterstitialAtMillis;
    if (lastAt != null) {
      final elapsed = DateTime.now().millisecondsSinceEpoch - lastAt;
      if (elapsed < minInterstitialSpacing.inMilliseconds) {
        return 'time_cap';
      }
    }
    return 'unknown';
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }
}
