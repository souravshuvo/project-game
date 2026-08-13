import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';
import '../services/app_services.dart';

class AdBannerSlot extends StatefulWidget {
  const AdBannerSlot({
    super.key,
    required this.placement,
    this.visible = true,
  });

  final String placement;
  final bool visible;

  @override
  State<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends State<AdBannerSlot> {
  BannerAd? _ad;
  bool _loaded = false;
  int _loadAttempts = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.visible) {
        _load();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AdBannerSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.visible && widget.visible) {
      _load();
    }
    if (oldWidget.visible && !widget.visible) {
      _disposeAd();
    }
  }

  @override
  void dispose() {
    _disposeAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!widget.visible || !_loaded || ad == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(
        child: SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }

  void _load() {
    if (_ad != null) {
      return;
    }

    final ads = AppServices.instance.ads;
    if (!ads.canRequestAds) {
      if (_loadAttempts < 5) {
        _loadAttempts++;
        unawaited(
          Future<void>.delayed(const Duration(milliseconds: 600), () {
            if (mounted && widget.visible) {
              _load();
            }
          }),
        );
      }
      return;
    }

    unawaited(
      AppServices.instance.analytics.logAdEvent(
        'ad_request',
        format: AdFormats.banner,
        placement: widget.placement,
        testAds: ads.useTestAds,
      ),
    );

    final banner = BannerAd(
      adUnitId: ads.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            unawaited(ad.dispose());
            return;
          }
          setState(() {
            _ad = ad as BannerAd;
            _loaded = true;
          });
          unawaited(
            AppServices.instance.analytics.logAdEvent(
              'ad_loaded',
              format: AdFormats.banner,
              placement: widget.placement,
              testAds: ads.useTestAds,
            ),
          );
        },
        onAdFailedToLoad: (ad, error) {
          unawaited(ad.dispose());
          if (mounted) {
            setState(() {
              _ad = null;
              _loaded = false;
            });
          }
          unawaited(
            AppServices.instance.analytics.logAdEvent(
              'ad_load_failed',
              format: AdFormats.banner,
              placement: widget.placement,
              reason: error.code.toString(),
              testAds: ads.useTestAds,
            ),
          );
        },
        onAdImpression: (ad) {
          unawaited(
            AppServices.instance.analytics.logAdEvent(
              'ad_impression',
              format: AdFormats.banner,
              placement: widget.placement,
              testAds: ads.useTestAds,
            ),
          );
        },
        onAdClicked: (ad) {
          unawaited(
            AppServices.instance.analytics.logAdEvent(
              'ad_clicked',
              format: AdFormats.banner,
              placement: widget.placement,
              testAds: ads.useTestAds,
            ),
          );
        },
      ),
    );

    _ad = banner;
    unawaited(banner.load());
  }

  void _disposeAd() {
    final ad = _ad;
    if (ad != null) {
      unawaited(ad.dispose());
    }
    _ad = null;
    _loaded = false;
  }
}
