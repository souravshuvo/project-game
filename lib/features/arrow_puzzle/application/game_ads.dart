import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app_runtime_config.dart';
import 'game_telemetry.dart';

abstract class GameAds extends ChangeNotifier {
  Future<void> initialize();

  bool get enabled;

  bool get rewardedHintReady;

  BannerAd? createBannerAd({
    required String placement,
    required VoidCallback onLoaded,
    required void Function() onFailed,
  });

  Future<bool> maybeShowInterstitial({
    required String placement,
    required int levelNumber,
  });

  Future<bool> showRewardedHint({required String placement});
}

class NoOpGameAds extends GameAds {
  NoOpGameAds._();

  static final instance = NoOpGameAds._();

  @override
  bool get enabled => false;

  @override
  bool get rewardedHintReady => false;

  @override
  Future<void> initialize() async {}

  @override
  BannerAd? createBannerAd({
    required String placement,
    required VoidCallback onLoaded,
    required void Function() onFailed,
  }) {
    return null;
  }

  @override
  Future<bool> maybeShowInterstitial({
    required String placement,
    required int levelNumber,
  }) async {
    return false;
  }

  @override
  Future<bool> showRewardedHint({required String placement}) async {
    return false;
  }
}

class MobileGameAds extends GameAds {
  MobileGameAds({required this.telemetry, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static const _interstitialLevelInterval = 4;
  static const _interstitialSessionCap = 5;
  static const _interstitialCooldown = Duration(minutes: 2);
  static const _adShowTimeout = Duration(seconds: 45);

  final GameTelemetry telemetry;
  final DateTime Function() _now;

  var _initialized = false;
  var _initializing = false;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  DateTime? _lastInterstitialShownAt;
  final _shownInterstitialLevels = <int>{};
  var _interstitialsShownThisSession = 0;
  var _disposed = false;

  @override
  bool get enabled {
    return _initialized &&
        AppRuntimeConfig.adsEnabled &&
        AppRuntimeConfig.isSupportedMobilePlatform &&
        AppRuntimeConfig.hasUsableAdUnitIds;
  }

  @override
  bool get rewardedHintReady => enabled && _rewardedAd != null;

  @override
  Future<void> initialize() async {
    if (_initialized || _initializing) {
      return;
    }

    if (!AppRuntimeConfig.adsEnabled ||
        !AppRuntimeConfig.isSupportedMobilePlatform ||
        !AppRuntimeConfig.hasUsableAdUnitIds) {
      _trackAd(
        action: 'disabled',
        format: 'sdk',
        placement: 'startup',
        reason: 'config',
      );
      return;
    }

    _initializing = true;
    try {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          maxAdContentRating: MaxAdContentRating.g,
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
          tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
        ),
      );
      await MobileAds.instance.initialize();
      _initialized = true;
      _trackAd(action: 'initialized', format: 'sdk', placement: 'startup');
      _loadInterstitial();
      _loadRewarded();
    } on Object catch (error) {
      _trackAd(
        action: 'failed',
        format: 'sdk',
        placement: 'startup',
        reason: error.runtimeType.toString(),
      );
      if (kDebugMode) {
        debugPrint('AdMob disabled: $error');
      }
    } finally {
      _initializing = false;
      _notify();
    }
  }

  @override
  BannerAd? createBannerAd({
    required String placement,
    required VoidCallback onLoaded,
    required void Function() onFailed,
  }) {
    if (!enabled) {
      return null;
    }

    _trackAd(action: 'request', format: 'banner', placement: placement);
    return BannerAd(
      size: AdSize.banner,
      adUnitId: AppRuntimeConfig.bannerAdUnitId,
      request: _adRequest,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _trackAd(action: 'loaded', format: 'banner', placement: placement);
          onLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          _trackAd(
            action: 'failed_to_load',
            format: 'banner',
            placement: placement,
            reason: error.domain,
            errorCode: error.code,
          );
          unawaited(ad.dispose());
          onFailed();
        },
        onAdImpression: (_) {
          _trackAd(
            action: 'impression',
            format: 'banner',
            placement: placement,
          );
        },
        onAdClicked: (_) {
          _trackAd(action: 'click', format: 'banner', placement: placement);
        },
      ),
    )..load();
  }

  @override
  Future<bool> maybeShowInterstitial({
    required String placement,
    required int levelNumber,
  }) async {
    if (!_canShowInterstitial(levelNumber)) {
      _trackAd(
        action: 'skipped',
        format: 'interstitial',
        placement: placement,
        levelNumber: levelNumber,
        reason: 'frequency_cap',
      );
      _loadInterstitial();
      return false;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      _trackAd(
        action: 'skipped',
        format: 'interstitial',
        placement: placement,
        levelNumber: levelNumber,
        reason: 'not_ready',
      );
      _loadInterstitial();
      return false;
    }

    _interstitialAd = null;
    _notify();

    final dismissed = Completer<void>();
    var showed = false;
    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdShowedFullScreenContent: (shownAd) {
        showed = true;
        _lastInterstitialShownAt = _now();
        _shownInterstitialLevels.add(levelNumber);
        _interstitialsShownThisSession++;
        _trackAd(
          action: 'show',
          format: 'interstitial',
          placement: placement,
          levelNumber: levelNumber,
        );
      },
      onAdImpression: (_) {
        _trackAd(
          action: 'impression',
          format: 'interstitial',
          placement: placement,
          levelNumber: levelNumber,
        );
      },
      onAdDismissedFullScreenContent: (dismissedAd) {
        _trackAd(
          action: 'dismissed',
          format: 'interstitial',
          placement: placement,
          levelNumber: levelNumber,
        );
        unawaited(dismissedAd.dispose());
        if (!dismissed.isCompleted) {
          dismissed.complete();
        }
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        _trackAd(
          action: 'failed_to_show',
          format: 'interstitial',
          placement: placement,
          levelNumber: levelNumber,
          reason: error.domain,
          errorCode: error.code,
        );
        unawaited(failedAd.dispose());
        if (!dismissed.isCompleted) {
          dismissed.complete();
        }
        _loadInterstitial();
      },
      onAdClicked: (_) {
        _trackAd(
          action: 'click',
          format: 'interstitial',
          placement: placement,
          levelNumber: levelNumber,
        );
      },
    );

    try {
      await ad.show();
      await dismissed.future.timeout(_adShowTimeout, onTimeout: () {});
    } on Object catch (error) {
      _trackAd(
        action: 'failed_to_show',
        format: 'interstitial',
        placement: placement,
        levelNumber: levelNumber,
        reason: error.runtimeType.toString(),
      );
      unawaited(ad.dispose());
      _loadInterstitial();
      return false;
    }

    return showed;
  }

  @override
  Future<bool> showRewardedHint({required String placement}) async {
    final ad = _rewardedAd;
    if (!enabled || ad == null) {
      _trackAd(
        action: 'skipped',
        format: 'rewarded',
        placement: placement,
        reason: 'not_ready',
      );
      _loadRewarded();
      return false;
    }

    _rewardedAd = null;
    _notify();

    final dismissed = Completer<void>();
    var earnedReward = false;
    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdShowedFullScreenContent: (_) {
        _trackAd(action: 'show', format: 'rewarded', placement: placement);
      },
      onAdImpression: (_) {
        _trackAd(
          action: 'impression',
          format: 'rewarded',
          placement: placement,
        );
      },
      onAdDismissedFullScreenContent: (dismissedAd) {
        _trackAd(action: 'dismissed', format: 'rewarded', placement: placement);
        unawaited(dismissedAd.dispose());
        if (!dismissed.isCompleted) {
          dismissed.complete();
        }
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        _trackAd(
          action: 'failed_to_show',
          format: 'rewarded',
          placement: placement,
          reason: error.domain,
          errorCode: error.code,
        );
        unawaited(failedAd.dispose());
        if (!dismissed.isCompleted) {
          dismissed.complete();
        }
        _loadRewarded();
      },
      onAdClicked: (_) {
        _trackAd(action: 'click', format: 'rewarded', placement: placement);
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (_, reward) {
          earnedReward = true;
          _trackAd(action: 'reward', format: 'rewarded', placement: placement);
        },
      );
      await dismissed.future.timeout(_adShowTimeout, onTimeout: () {});
    } on Object catch (error) {
      _trackAd(
        action: 'failed_to_show',
        format: 'rewarded',
        placement: placement,
        reason: error.runtimeType.toString(),
      );
      unawaited(ad.dispose());
      _loadRewarded();
      return false;
    }

    return earnedReward;
  }

  AdRequest get _adRequest {
    return const AdRequest(
      keywords: ['logic puzzle', 'arrow puzzle', 'casual game'],
      nonPersonalizedAds: true,
    );
  }

  bool _canShowInterstitial(int levelNumber) {
    if (!enabled) {
      return false;
    }
    if (levelNumber % _interstitialLevelInterval != 0) {
      return false;
    }
    if (_shownInterstitialLevels.contains(levelNumber)) {
      return false;
    }
    if (_interstitialsShownThisSession >= _interstitialSessionCap) {
      return false;
    }

    final lastShownAt = _lastInterstitialShownAt;
    if (lastShownAt != null &&
        _now().difference(lastShownAt) < _interstitialCooldown) {
      return false;
    }

    return true;
  }

  void _loadInterstitial() {
    if (!enabled || _interstitialAd != null) {
      return;
    }

    _trackAd(action: 'request', format: 'interstitial', placement: 'preload');
    unawaited(
      InterstitialAd.load(
        adUnitId: AppRuntimeConfig.interstitialAdUnitId,
        request: _adRequest,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _trackAd(
              action: 'loaded',
              format: 'interstitial',
              placement: 'preload',
            );
            _notify();
          },
          onAdFailedToLoad: (error) {
            _trackAd(
              action: 'failed_to_load',
              format: 'interstitial',
              placement: 'preload',
              reason: error.domain,
              errorCode: error.code,
            );
          },
        ),
      ).catchError((Object error, StackTrace stackTrace) {
        _trackAd(
          action: 'failed_to_load',
          format: 'interstitial',
          placement: 'preload',
          reason: error.runtimeType.toString(),
        );
      }),
    );
  }

  void _loadRewarded() {
    if (!enabled || _rewardedAd != null) {
      return;
    }

    _trackAd(action: 'request', format: 'rewarded', placement: 'preload');
    unawaited(
      RewardedAd.load(
        adUnitId: AppRuntimeConfig.rewardedAdUnitId,
        request: _adRequest,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _trackAd(
              action: 'loaded',
              format: 'rewarded',
              placement: 'preload',
            );
            _notify();
          },
          onAdFailedToLoad: (error) {
            _trackAd(
              action: 'failed_to_load',
              format: 'rewarded',
              placement: 'preload',
              reason: error.domain,
              errorCode: error.code,
            );
            _notify();
          },
        ),
      ).catchError((Object error, StackTrace stackTrace) {
        _trackAd(
          action: 'failed_to_load',
          format: 'rewarded',
          placement: 'preload',
          reason: error.runtimeType.toString(),
        );
      }),
    );
  }

  void _trackAd({
    required String action,
    required String format,
    required String placement,
    String? reason,
    int? levelNumber,
    int? errorCode,
  }) {
    telemetry.track(
      GameTelemetryEvents.adEvent(
        action: action,
        format: format,
        placement: placement,
        environment: AppRuntimeConfig.usesTestAds ? 'test' : 'production',
        reason: reason,
        levelNumber: levelNumber,
        errorCode: errorCode,
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    final interstitialAd = _interstitialAd;
    final rewardedAd = _rewardedAd;
    _interstitialAd = null;
    _rewardedAd = null;
    if (interstitialAd != null) {
      unawaited(interstitialAd.dispose());
    }
    if (rewardedAd != null) {
      unawaited(rewardedAd.dispose());
    }
    super.dispose();
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}
