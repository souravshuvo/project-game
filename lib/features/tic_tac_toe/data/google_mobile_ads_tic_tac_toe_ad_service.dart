import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../application/interstitial_ad_frequency_cap.dart';
import '../application/tic_tac_toe_ad_service.dart';
import '../application/tic_tac_toe_telemetry.dart';
import 'tic_tac_toe_ad_units.dart';

final class GoogleMobileAdsTicTacToeAdService implements TicTacToeAdService {
  GoogleMobileAdsTicTacToeAdService({
    required this.telemetry,
    this.frequencyCap = const InterstitialAdFrequencyCap(),
    this.postMatchDelay = const Duration(milliseconds: 900),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  static const _placement = 'post_match';
  static const _adFormat = 'interstitial';

  final TicTacToeTelemetry telemetry;
  final InterstitialAdFrequencyCap frequencyCap;
  final Duration postMatchDelay;
  final DateTime Function() _now;

  Future<void>? _initializeFuture;
  InterstitialAd? _interstitialAd;
  DateTime? _lastShownAt;
  var _isInitialized = false;
  var _isLoading = false;
  var _isShowing = false;
  var _isDisposed = false;
  var _adsShownThisSession = 0;

  @override
  bool get usesTestAds => TicTacToeAdUnits.usesTestInterstitial;

  @override
  Future<void> initialize() {
    if (_isDisposed) {
      return Future.value();
    }

    return _initializeFuture ??= _initialize();
  }

  @override
  Future<void> preloadInterstitial() async {
    if (_isDisposed || _isLoading || _interstitialAd != null) {
      return;
    }

    if (!TicTacToeAdUnits.isSupportedPlatform) {
      _trackSkipped('unsupported_platform');
      return;
    }

    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized || _isDisposed) {
        return;
      }
    }

    final adUnitId = TicTacToeAdUnits.interstitial;
    if (adUnitId.isEmpty) {
      _trackSkipped('missing_ad_unit');
      return;
    }

    _isLoading = true;
    telemetry.track(
      TicTacToeTelemetryEvents.adLoadStarted(
        placement: _placement,
        adFormat: _adFormat,
        usesTestAds: usesTestAds,
      ),
    );

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (_isDisposed) {
            ad.dispose();
            return;
          }

          _isLoading = false;
          _interstitialAd = ad;
          _attachCallbacks(ad);
          telemetry.track(
            TicTacToeTelemetryEvents.adLoaded(
              placement: _placement,
              adFormat: _adFormat,
              usesTestAds: usesTestAds,
            ),
          );
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          telemetry.track(
            TicTacToeTelemetryEvents.adLoadFailed(
              placement: _placement,
              adFormat: _adFormat,
              errorCode: error.code,
              usesTestAds: usesTestAds,
            ),
          );
        },
      ),
    );
  }

  @override
  Future<void> onMatchCompleted({
    required int completedMatchesThisSession,
    required AdSafetyCheck canShowNow,
  }) async {
    if (_isDisposed) {
      return;
    }

    unawaited(preloadInterstitial());
    var decision = _currentDecision(
      completedMatchesThisSession: completedMatchesThisSession,
      canShowNow: canShowNow,
    );
    if (!decision.canShow) {
      _trackSkipped(decision.reason);
      return;
    }

    await Future<void>.delayed(postMatchDelay);
    if (_isDisposed) {
      return;
    }

    decision = _currentDecision(
      completedMatchesThisSession: completedMatchesThisSession,
      canShowNow: canShowNow,
    );
    if (!decision.canShow) {
      _trackSkipped(decision.reason);
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      _trackSkipped('not_loaded');
      unawaited(preloadInterstitial());
      return;
    }

    _interstitialAd = null;
    telemetry.track(
      TicTacToeTelemetryEvents.adShowAttempted(
        placement: _placement,
        adFormat: _adFormat,
        usesTestAds: usesTestAds,
      ),
    );

    try {
      await ad.show();
    } on Object catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to show tic tac toe interstitial: $error');
      }
      ad.dispose();
      _isShowing = false;
      telemetry.track(
        TicTacToeTelemetryEvents.adShowFailed(
          placement: _placement,
          adFormat: _adFormat,
          errorCode: 'show_exception',
          usesTestAds: usesTestAds,
        ),
      );
      unawaited(preloadInterstitial());
    }
  }

  InterstitialAdDecision _currentDecision({
    required int completedMatchesThisSession,
    required AdSafetyCheck canShowNow,
  }) {
    return frequencyCap.evaluate(
      completedMatchesThisSession: completedMatchesThisSession,
      adsShownThisSession: _adsShownThisSession,
      now: _now(),
      lastShownAt: _lastShownAt,
      isActiveGameplay: !canShowNow(),
      isAdLoaded: _interstitialAd != null,
      isAdShowing: _isShowing,
    );
  }

  Future<void> _initialize() async {
    if (!TicTacToeAdUnits.isSupportedPlatform) {
      _trackSkipped('unsupported_platform');
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      telemetry.track(
        TicTacToeTelemetryEvents.adSdkInitialized(usesTestAds: usesTestAds),
      );
      unawaited(preloadInterstitial());
    } on Object catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to initialize Google Mobile Ads: $error');
      }
      telemetry.track(
        TicTacToeTelemetryEvents.adSdkInitializationFailed(
          errorCode: 'initialize_exception',
          usesTestAds: usesTestAds,
        ),
      );
    }
  }

  void _attachCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdShowedFullScreenContent: (shownAd) {
        _isShowing = true;
        _adsShownThisSession++;
        _lastShownAt = _now();
        telemetry.track(
          TicTacToeTelemetryEvents.adShown(
            placement: _placement,
            adFormat: _adFormat,
            usesTestAds: usesTestAds,
          ),
        );
      },
      onAdDismissedFullScreenContent: (dismissedAd) {
        _isShowing = false;
        dismissedAd.dispose();
        telemetry.track(
          TicTacToeTelemetryEvents.adDismissed(
            placement: _placement,
            adFormat: _adFormat,
            usesTestAds: usesTestAds,
          ),
        );
        unawaited(preloadInterstitial());
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        _isShowing = false;
        failedAd.dispose();
        telemetry.track(
          TicTacToeTelemetryEvents.adShowFailed(
            placement: _placement,
            adFormat: _adFormat,
            errorCode: error.code.toString(),
            usesTestAds: usesTestAds,
          ),
        );
        unawaited(preloadInterstitial());
      },
    );
  }

  void _trackSkipped(String reason) {
    telemetry.track(
      TicTacToeTelemetryEvents.adSkipped(
        placement: _placement,
        adFormat: _adFormat,
        reason: reason,
        usesTestAds: usesTestAds,
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
