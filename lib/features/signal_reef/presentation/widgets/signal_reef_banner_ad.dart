import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../application/signal_reef_ads.dart';

class SignalReefBannerAd extends StatefulWidget {
  const SignalReefBannerAd({
    super.key,
    required this.ads,
    required this.placement,
  });

  final SignalReefAdService ads;
  final SignalReefAdPlacement placement;

  @override
  State<SignalReefBannerAd> createState() => _SignalReefBannerAdState();
}

class _SignalReefBannerAdState extends State<SignalReefBannerAd> {
  BannerAd? _bannerAd;
  var _loadAttempted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_loadAd());
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerAd = _bannerAd;
    if (bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Center(
        child: SizedBox(
          width: bannerAd.size.width.toDouble(),
          height: bannerAd.size.height.toDouble(),
          child: AdWidget(ad: bannerAd),
        ),
      ),
    );
  }

  Future<void> _loadAd() async {
    if (_loadAttempted || !widget.ads.supportsAds) {
      return;
    }

    _loadAttempted = true;
    await widget.ads.initialize();
    if (!mounted || !widget.ads.isInitialized) {
      return;
    }

    final adUnitId = widget.ads.config.bannerAdUnitId();
    if (adUnitId == null) {
      return;
    }

    widget.ads.trackBannerLoadStart(widget.placement);

    final bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }

          setState(() {
            _bannerAd = ad as BannerAd;
          });
          widget.ads.trackBannerLoaded(widget.placement);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          widget.ads.trackBannerLoadFailed(widget.placement, error);
        },
      ),
    );

    unawaited(
      bannerAd.load().catchError((Object error) {
        bannerAd.dispose();
        widget.ads.trackBannerLoadException(widget.placement, error);
      }),
    );
  }
}
