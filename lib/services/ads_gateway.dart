import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'ad_frequency_cap.dart';

enum InterstitialAdResult {
  disabled,
  capped,
  notLoaded,
  shown,
  failed,
  skipped,
}

enum RewardedAdResult { disabled, notLoaded, earned, dismissed, failed }

class AdsGateway {
  AdsGateway({
    this.config = const AdConfig(),
    this.frequencyCap = const AdFrequencyCap(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AdConfig config;
  final AdFrequencyCap frequencyCap;
  final DateTime Function() _clock;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _interstitialLoading = false;
  bool _rewardedLoading = false;
  int _completedRuns = 0;
  DateTime? _lastInterstitialShownAt;

  static Future<void>? _initializeFuture;

  static Future<void> initialize({AdConfig config = const AdConfig()}) {
    return _initializeFuture ??= _initialize(config);
  }

  static Future<void> _initialize(AdConfig config) async {
    if (!config.adsEnabled) {
      return;
    }

    try {
      await MobileAds.instance.initialize().timeout(const Duration(seconds: 3));
    } catch (_) {
      return;
    }
  }

  bool get hasRewardedRevive => config.adsEnabled && _rewardedAd != null;
  int get completedRuns => _completedRuns;

  void recordRunEnded() {
    _completedRuns += 1;
  }

  Future<void> preload() async {
    if (!config.adsEnabled) {
      return;
    }

    await initialize(config: config);
    await Future.wait(<Future<void>>[_loadInterstitial(), _loadRewarded()]);
  }

  Future<InterstitialAdResult> maybeShowGameOverInterstitial({
    required bool routeCompleted,
    bool Function()? canShowNow,
  }) async {
    if (!config.adsEnabled) {
      return InterstitialAdResult.disabled;
    }

    await initialize(config: config);
    if (canShowNow != null && !canShowNow()) {
      unawaited(_loadInterstitial());
      return InterstitialAdResult.skipped;
    }

    final now = _clock();
    final canShow = frequencyCap.canShowInterstitial(
      completedRuns: _completedRuns,
      routeCompleted: routeCompleted,
      now: now,
      lastShownAt: _lastInterstitialShownAt,
    );
    if (!canShow) {
      unawaited(_loadInterstitial());
      return InterstitialAdResult.capped;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      unawaited(_loadInterstitial());
      return InterstitialAdResult.notLoaded;
    }

    if (canShowNow != null && !canShowNow()) {
      unawaited(_loadInterstitial());
      return InterstitialAdResult.skipped;
    }

    _interstitialAd = null;
    final completer = Completer<InterstitialAdResult>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (shownAd) {
        shownAd.dispose();
        unawaited(_loadInterstitial());
        if (!completer.isCompleted) {
          completer.complete(InterstitialAdResult.shown);
        }
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        failedAd.dispose();
        unawaited(_loadInterstitial());
        if (!completer.isCompleted) {
          completer.complete(InterstitialAdResult.failed);
        }
      },
    );

    try {
      await ad.show();
      _lastInterstitialShownAt = now;
    } catch (_) {
      ad.dispose();
      unawaited(_loadInterstitial());
      return InterstitialAdResult.failed;
    }

    return completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () => InterstitialAdResult.shown,
    );
  }

  Future<RewardedAdResult> showRewardedRevive() async {
    if (!config.adsEnabled) {
      return RewardedAdResult.disabled;
    }

    await initialize(config: config);

    final ad = _rewardedAd;
    if (ad == null) {
      unawaited(_loadRewarded());
      return RewardedAdResult.notLoaded;
    }

    _rewardedAd = null;
    var earnedReward = false;
    final completer = Completer<RewardedAdResult>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (shownAd) {
        shownAd.dispose();
        unawaited(_loadRewarded());
        if (!completer.isCompleted) {
          completer.complete(
            earnedReward ? RewardedAdResult.earned : RewardedAdResult.dismissed,
          );
        }
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        failedAd.dispose();
        unawaited(_loadRewarded());
        if (!completer.isCompleted) {
          completer.complete(RewardedAdResult.failed);
        }
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (shownAd, reward) {
          earnedReward = true;
        },
      );
    } catch (_) {
      ad.dispose();
      unawaited(_loadRewarded());
      return RewardedAdResult.failed;
    }

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () =>
          earnedReward ? RewardedAdResult.earned : RewardedAdResult.dismissed,
    );
  }

  Future<void> _loadInterstitial() async {
    if (!config.adsEnabled || _interstitialAd != null || _interstitialLoading) {
      return;
    }

    _interstitialLoading = true;
    try {
      await InterstitialAd.load(
        adUnitId: config.interstitialAdUnitId(defaultTargetPlatform),
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _interstitialLoading = false;
          },
          onAdFailedToLoad: (error) {
            _interstitialAd = null;
            _interstitialLoading = false;
          },
        ),
      );
    } catch (_) {
      _interstitialLoading = false;
    }
  }

  Future<void> _loadRewarded() async {
    if (!config.adsEnabled || _rewardedAd != null || _rewardedLoading) {
      return;
    }

    _rewardedLoading = true;
    try {
      await RewardedAd.load(
        adUnitId: config.rewardedAdUnitId(defaultTargetPlatform),
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _rewardedLoading = false;
          },
          onAdFailedToLoad: (error) {
            _rewardedAd = null;
            _rewardedLoading = false;
          },
        ),
      );
    } catch (_) {
      _rewardedLoading = false;
    }
  }
}
