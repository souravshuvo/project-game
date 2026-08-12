import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'game_analytics.dart';

class GameAdConfig {
  const GameAdConfig({
    required this.adsEnabled,
    required this.useTestAds,
    required this.androidBannerId,
    required this.androidInterstitialId,
    required this.iosBannerId,
    required this.iosInterstitialId,
    required this.testDeviceIds,
  });

  factory GameAdConfig.fromEnvironment() {
    return const GameAdConfig(
      adsEnabled: bool.fromEnvironment('ADS_ENABLED', defaultValue: true),
      useTestAds: bool.fromEnvironment(
        'ADMOB_USE_TEST_ADS',
        defaultValue: true,
      ),
      androidBannerId: String.fromEnvironment('ADMOB_ANDROID_BANNER_ID'),
      androidInterstitialId: String.fromEnvironment(
        'ADMOB_ANDROID_INTERSTITIAL_ID',
      ),
      iosBannerId: String.fromEnvironment('ADMOB_IOS_BANNER_ID'),
      iosInterstitialId: String.fromEnvironment('ADMOB_IOS_INTERSTITIAL_ID'),
      testDeviceIds: String.fromEnvironment('ADMOB_TEST_DEVICE_IDS'),
    );
  }

  final bool adsEnabled;
  final bool useTestAds;
  final String androidBannerId;
  final String androidInterstitialId;
  final String iosBannerId;
  final String iosInterstitialId;
  final String testDeviceIds;

  String? get bannerUnitId {
    if (!adsEnabled) {
      return null;
    }
    if (useTestAds) {
      return switch (defaultTargetPlatform) {
        TargetPlatform.android => 'ca-app-pub-3940256099942544/6300978111',
        TargetPlatform.iOS => 'ca-app-pub-3940256099942544/2934735716',
        _ => null,
      };
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _emptyToNull(androidBannerId),
      TargetPlatform.iOS => _emptyToNull(iosBannerId),
      _ => null,
    };
  }

  String? get interstitialUnitId {
    if (!adsEnabled) {
      return null;
    }
    if (useTestAds) {
      return switch (defaultTargetPlatform) {
        TargetPlatform.android => 'ca-app-pub-3940256099942544/1033173712',
        TargetPlatform.iOS => 'ca-app-pub-3940256099942544/4411468910',
        _ => null,
      };
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _emptyToNull(androidInterstitialId),
      TargetPlatform.iOS => _emptyToNull(iosInterstitialId),
      _ => null,
    };
  }

  List<String> get parsedTestDeviceIds {
    return testDeviceIds
        .split(',')
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
  }

  static String? _emptyToNull(String value) {
    return value.trim().isEmpty ? null : value.trim();
  }
}

class GameAdService {
  GameAdService({required GameAnalytics analytics, GameAdConfig? config})
    : _analytics = analytics,
      _config = config ?? GameAdConfig.fromEnvironment();

  GameAdService.disabled({required GameAnalytics analytics})
    : _analytics = analytics,
      _config = const GameAdConfig(
        adsEnabled: false,
        useTestAds: true,
        androidBannerId: '',
        androidInterstitialId: '',
        iosBannerId: '',
        iosInterstitialId: '',
        testDeviceIds: '',
      );

  static const int minCompletedMatchesBeforeInterstitial = 2;
  static const int matchesBetweenInterstitials = 3;
  static const Duration minTimeBetweenInterstitials = Duration(minutes: 4);

  final GameAnalytics _analytics;
  final GameAdConfig _config;

  InterstitialAd? _interstitialAd;
  bool _initialized = false;
  bool _isLoadingInterstitial = false;
  int _completedMatches = 0;
  int _matchesSinceInterstitial = 0;
  DateTime? _lastInterstitialShownAt;

  bool get adsEnabled => _config.adsEnabled;
  bool get useTestAds => _config.useTestAds;
  bool get canRequestBanner => _config.bannerUnitId != null;

  Future<void> initialize() async {
    if (!_config.adsEnabled) {
      await _analytics.logEvent('ads_disabled');
      return;
    }

    try {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          maxAdContentRating: MaxAdContentRating.g,
          ageRestrictedTreatment: AgeRestrictedTreatment.unspecified,
          testDeviceIds: _config.parsedTestDeviceIds,
        ),
      );
      await MobileAds.instance.initialize();
      _initialized = true;
      await _analytics.logEvent(
        'ad_sdk_initialized',
        parameters: <String, Object?>{'use_test_ads': _config.useTestAds},
      );
      unawaited(loadInterstitial());
    } on Object catch (error, stackTrace) {
      developer.log(
        'AdMob initialization failed.',
        name: 'emoji_chor_police.ads',
        error: error,
        stackTrace: stackTrace,
      );
      await _analytics.logEvent(
        'ad_sdk_init_failed',
        parameters: <String, Object?>{'error': '$error'},
      );
    }
  }

  AdRequest buildRequest({required String placement}) {
    return AdRequest(
      nonPersonalizedAds: true,
      keywords: const <String>['family game', 'party game', 'board game'],
      extras: <String, String>{'placement': placement},
    );
  }

  String? bannerUnitId() {
    return _config.bannerUnitId;
  }

  Future<void> loadInterstitial() async {
    final adUnitId = _config.interstitialUnitId;
    if (!_initialized || adUnitId == null || _isLoadingInterstitial) {
      return;
    }
    if (_interstitialAd != null) {
      return;
    }

    _isLoadingInterstitial = true;
    await _analytics.logEvent(
      'ad_interstitial_load_requested',
      parameters: <String, Object?>{'use_test_ads': _config.useTestAds},
    );

    try {
      await InterstitialAd.load(
        adUnitId: adUnitId,
        request: buildRequest(placement: 'interstitial_session_break'),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _isLoadingInterstitial = false;
            _interstitialAd = ad;
            unawaited(_analytics.logEvent('ad_interstitial_loaded'));
          },
          onAdFailedToLoad: (error) {
            _isLoadingInterstitial = false;
            _interstitialAd = null;
            unawaited(
              _analytics.logEvent(
                'ad_interstitial_load_failed',
                parameters: <String, Object?>{
                  'code': error.code,
                  'domain': error.domain,
                  'message': error.message,
                },
              ),
            );
          },
        ),
      );
    } on Object catch (error, stackTrace) {
      _isLoadingInterstitial = false;
      developer.log(
        'Interstitial load failed.',
        name: 'emoji_chor_police.ads',
        error: error,
        stackTrace: stackTrace,
      );
      await _analytics.logEvent(
        'ad_interstitial_load_failed',
        parameters: <String, Object?>{'error': '$error'},
      );
    }
  }

  void registerMatchCompleted() {
    _completedMatches += 1;
    _matchesSinceInterstitial += 1;
    if (_canAttemptInterstitial) {
      unawaited(loadInterstitial());
    }
  }

  Future<bool> maybeShowInterstitialAtSessionBreak({
    required String placement,
  }) async {
    if (!_config.adsEnabled) {
      return false;
    }
    if (!_canAttemptInterstitial) {
      await _analytics.logEvent(
        'ad_interstitial_capped',
        parameters: <String, Object?>{
          'placement': placement,
          'completed_matches': _completedMatches,
          'matches_since_interstitial': _matchesSinceInterstitial,
        },
      );
      unawaited(loadInterstitial());
      return false;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      await _analytics.logEvent(
        'ad_interstitial_unavailable',
        parameters: <String, Object?>{'placement': placement},
      );
      unawaited(loadInterstitial());
      return false;
    }

    _interstitialAd = null;
    _lastInterstitialShownAt = DateTime.now();
    _matchesSinceInterstitial = 0;
    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdShowedFullScreenContent: (shownAd) {
        unawaited(
          _analytics.logEvent(
            'ad_interstitial_show',
            parameters: <String, Object?>{'placement': placement},
          ),
        );
      },
      onAdImpression: (shownAd) {
        unawaited(
          _analytics.logEvent(
            'ad_interstitial_impression',
            parameters: <String, Object?>{'placement': placement},
          ),
        );
      },
      onAdClicked: (shownAd) {
        unawaited(
          _analytics.logEvent(
            'ad_interstitial_clicked',
            parameters: <String, Object?>{'placement': placement},
          ),
        );
      },
      onAdDismissedFullScreenContent: (dismissedAd) {
        dismissedAd.dispose();
        unawaited(
          _analytics.logEvent(
            'ad_interstitial_dismissed',
            parameters: <String, Object?>{'placement': placement},
          ),
        );
        unawaited(loadInterstitial());
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        failedAd.dispose();
        unawaited(
          _analytics.logEvent(
            'ad_interstitial_show_failed',
            parameters: <String, Object?>{
              'placement': placement,
              'code': error.code,
              'domain': error.domain,
              'message': error.message,
            },
          ),
        );
        unawaited(loadInterstitial());
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    try {
      await ad.show();
    } on Object catch (error, stackTrace) {
      ad.dispose();
      developer.log(
        'Interstitial show failed.',
        name: 'emoji_chor_police.ads',
        error: error,
        stackTrace: stackTrace,
      );
      await _analytics.logEvent(
        'ad_interstitial_show_failed',
        parameters: <String, Object?>{
          'placement': placement,
          'error': '$error',
        },
      );
      unawaited(loadInterstitial());
      return false;
    }

    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () => true,
    );
  }

  bool get _canAttemptInterstitial {
    if (!_initialized || _config.interstitialUnitId == null) {
      return false;
    }
    if (_completedMatches < minCompletedMatchesBeforeInterstitial) {
      return false;
    }
    if (_matchesSinceInterstitial < matchesBetweenInterstitials) {
      return false;
    }
    final lastShown = _lastInterstitialShownAt;
    if (lastShown == null) {
      return true;
    }
    return DateTime.now().difference(lastShown) >= minTimeBetweenInterstitials;
  }
}

class GameBannerAdSlot extends StatefulWidget {
  const GameBannerAdSlot({
    super.key,
    required this.adService,
    required this.analytics,
    required this.placement,
  });

  final GameAdService adService;
  final GameAnalytics analytics;
  final String placement;

  @override
  State<GameBannerAdSlot> createState() => _GameBannerAdSlotState();
}

class _GameBannerAdSlotState extends State<GameBannerAdSlot> {
  BannerAd? _bannerAd;
  bool _loaded = false;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant GameBannerAdSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placement != widget.placement ||
        oldWidget.adService != widget.adService) {
      _disposeAd();
      _load();
    }
  }

  @override
  void dispose() {
    _disposeAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _bannerAd;
    if (!_loaded || ad == null) {
      return const SizedBox.shrink();
    }

    return ColoredBox(
      color: const Color(0xFFF4F7F6),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: Center(
            child: SizedBox(
              width: ad.size.width.toDouble(),
              height: ad.size.height.toDouble(),
              child: AdWidget(ad: ad),
            ),
          ),
        ),
      ),
    );
  }

  void _load() {
    final adUnitId = widget.adService.bannerUnitId();
    if (adUnitId == null) {
      return;
    }
    final requestId = ++_requestId;

    unawaited(
      widget.analytics.logEvent(
        'ad_banner_load_requested',
        parameters: <String, Object?>{'placement': widget.placement},
      ),
    );

    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      request: widget.adService.buildRequest(placement: widget.placement),
      listener: BannerAdListener(
        onAdLoaded: (loadedAd) {
          if (!mounted || requestId != _requestId) {
            loadedAd.dispose();
            return;
          }
          setState(() {
            _bannerAd = loadedAd as BannerAd;
            _loaded = true;
          });
          unawaited(
            widget.analytics.logEvent(
              'ad_banner_loaded',
              parameters: <String, Object?>{'placement': widget.placement},
            ),
          );
        },
        onAdFailedToLoad: (failedAd, error) {
          failedAd.dispose();
          if (mounted && requestId == _requestId) {
            setState(() {
              _bannerAd = null;
              _loaded = false;
            });
          }
          unawaited(
            widget.analytics.logEvent(
              'ad_banner_load_failed',
              parameters: <String, Object?>{
                'placement': widget.placement,
                'code': error.code,
                'domain': error.domain,
                'message': error.message,
              },
            ),
          );
        },
        onAdImpression: (ad) {
          unawaited(
            widget.analytics.logEvent(
              'ad_banner_impression',
              parameters: <String, Object?>{'placement': widget.placement},
            ),
          );
        },
        onAdClicked: (ad) {
          unawaited(
            widget.analytics.logEvent(
              'ad_banner_clicked',
              parameters: <String, Object?>{'placement': widget.placement},
            ),
          );
        },
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          unawaited(
            widget.analytics.logEvent(
              'ad_paid_event',
              parameters: <String, Object?>{
                'placement': widget.placement,
                'value_micros': valueMicros,
                'currency': currencyCode,
                'precision': precision.name,
              },
            ),
          );
        },
      ),
    );
    _bannerAd = ad;
    unawaited(ad.load());
  }

  void _disposeAd() {
    _requestId += 1;
    _bannerAd?.dispose();
    _bannerAd = null;
    _loaded = false;
  }
}
