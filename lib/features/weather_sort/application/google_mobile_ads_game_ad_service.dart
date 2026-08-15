import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'ad_frequency_policy.dart';
import 'ad_frequency_store.dart';
import 'game_ad_service.dart';
import 'game_telemetry.dart';

final class GoogleMobileAdsGameAdService implements GameAdService {
  GoogleMobileAdsGameAdService({
    required this.config,
    required this.frequencyStore,
    required this.telemetry,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final WeatherSortAdConfig config;
  final AdFrequencyStore frequencyStore;
  final GameTelemetry telemetry;
  final DateTime Function() _now;

  InterstitialAd? _levelEndInterstitial;
  bool _initialized = false;
  bool _isLoadingInterstitial = false;
  int _sessionInterstitialShowCount = 0;

  @override
  Future<void> initialize() async {
    if (!config.adsEnabled) {
      telemetry.track(
        GameTelemetryEvents.adInitSkipped(reason: 'ads_disabled'),
      );
      return;
    }
    if (!config.canRequestAds) {
      telemetry.track(
        GameTelemetryEvents.adInitSkipped(reason: 'unsupported_or_missing_id'),
      );
      return;
    }

    try {
      await MobileAds.instance.initialize().timeout(const Duration(seconds: 8));
      _initialized = true;
      telemetry.track(
        GameTelemetryEvents.adInitComplete(
          environment: config.environment.name,
          usesTestAds: config.usesTestAds,
        ),
      );
      preloadLevelEndInterstitial();
    } on Object catch (error) {
      telemetry.track(
        GameTelemetryEvents.adInitFailed(error: error.runtimeType.toString()),
      );
    }
  }

  @override
  void preloadLevelEndInterstitial() {
    final adUnitId = config.levelEndInterstitialAdUnitId;
    if (!_initialized ||
        adUnitId == null ||
        _isLoadingInterstitial ||
        _levelEndInterstitial != null) {
      return;
    }

    _isLoadingInterstitial = true;
    telemetry.track(
      GameTelemetryEvents.adLoadStart(
        placement: 'level_end',
        format: 'interstitial',
        environment: config.environment.name,
      ),
    );
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(nonPersonalizedAds: true),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingInterstitial = false;
          _levelEndInterstitial = ad;
          telemetry.track(
            GameTelemetryEvents.adLoadComplete(
              placement: 'level_end',
              format: 'interstitial',
            ),
          );
        },
        onAdFailedToLoad: (error) {
          _isLoadingInterstitial = false;
          telemetry.track(
            GameTelemetryEvents.adLoadFailed(
              placement: 'level_end',
              format: 'interstitial',
              code: error.code,
            ),
          );
        },
      ),
    );
  }

  @override
  Future<bool> maybeShowLevelEndInterstitial({
    required int levelId,
    required int levelNumber,
  }) async {
    telemetry.track(
      GameTelemetryEvents.adOpportunity(
        placement: 'level_end',
        format: 'interstitial',
        levelId: levelId,
        levelNumber: levelNumber,
      ),
    );

    if (!_initialized || !config.canRequestAds) {
      telemetry.track(
        GameTelemetryEvents.adSkipped(
          placement: 'level_end',
          format: 'interstitial',
          reason: 'not_initialized',
        ),
      );
      return false;
    }

    final storedState = await frequencyStore.load();
    final candidateState = storedState
        .copyWith(sessionInterstitialShowCount: _sessionInterstitialShowCount)
        .recordLevelTransition();
    await frequencyStore.save(candidateState);

    final decision = config.frequencyPolicy.evaluate(
      state: candidateState,
      now: _now(),
    );
    if (!decision.canShow) {
      telemetry.track(
        GameTelemetryEvents.adFrequencyCapped(
          placement: 'level_end',
          format: 'interstitial',
          reason: decision.reason,
          completedTransitions:
              candidateState.completedLevelTransitionsSinceInterstitial,
        ),
      );
      preloadLevelEndInterstitial();
      return false;
    }

    final ad = _levelEndInterstitial;
    if (ad == null) {
      telemetry.track(
        GameTelemetryEvents.adSkipped(
          placement: 'level_end',
          format: 'interstitial',
          reason: 'not_loaded',
        ),
      );
      preloadLevelEndInterstitial();
      return false;
    }

    _levelEndInterstitial = null;
    final result = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        telemetry.track(
          GameTelemetryEvents.adShow(
            placement: 'level_end',
            format: 'interstitial',
          ),
        );
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _sessionInterstitialShowCount++;
        unawaited(_recordInterstitialShown(candidateState));
        preloadLevelEndInterstitial();
        if (!result.isCompleted) {
          result.complete(true);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        telemetry.track(
          GameTelemetryEvents.adShowFailed(
            placement: 'level_end',
            format: 'interstitial',
            error: error.runtimeType.toString(),
          ),
        );
        preloadLevelEndInterstitial();
        if (!result.isCompleted) {
          result.complete(false);
        }
      },
    );

    try {
      ad.show();
    } on Object catch (error) {
      ad.dispose();
      telemetry.track(
        GameTelemetryEvents.adShowFailed(
          placement: 'level_end',
          format: 'interstitial',
          error: error.runtimeType.toString(),
        ),
      );
      preloadLevelEndInterstitial();
      return false;
    }

    return result.future.timeout(
      const Duration(seconds: 45),
      onTimeout: () {
        telemetry.track(
          GameTelemetryEvents.adShowTimeout(
            placement: 'level_end',
            format: 'interstitial',
          ),
        );
        return true;
      },
    );
  }

  @override
  void dispose() {
    _levelEndInterstitial?.dispose();
    _levelEndInterstitial = null;
  }

  Future<void> _recordInterstitialShown(
    InterstitialFrequencyState candidateState,
  ) async {
    await frequencyStore.save(candidateState.recordInterstitialShown(_now()));
    telemetry.track(
      GameTelemetryEvents.adDismissed(
        placement: 'level_end',
        format: 'interstitial',
      ),
    );
  }
}
