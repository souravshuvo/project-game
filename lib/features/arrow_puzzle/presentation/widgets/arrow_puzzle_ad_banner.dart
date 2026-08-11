import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../application/game_ads.dart';

class ArrowPuzzleAdBanner extends StatefulWidget {
  const ArrowPuzzleAdBanner({
    super.key,
    required this.ads,
    required this.placement,
  });

  final GameAds ads;
  final String placement;

  @override
  State<ArrowPuzzleAdBanner> createState() => _ArrowPuzzleAdBannerState();
}

class _ArrowPuzzleAdBannerState extends State<ArrowPuzzleAdBanner> {
  BannerAd? _ad;
  var _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ArrowPuzzleAdBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ads != widget.ads ||
        oldWidget.placement != widget.placement) {
      _disposeAd();
      _loaded = false;
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
    final ad = _ad;
    if (!_loaded || ad == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }

  void _load() {
    _ad = widget.ads.createBannerAd(
      placement: widget.placement,
      onLoaded: () {
        if (mounted) {
          setState(() => _loaded = true);
        }
      },
      onFailed: () {
        if (mounted) {
          setState(() => _loaded = false);
        }
      },
    );
  }

  void _disposeAd() {
    final ad = _ad;
    _ad = null;
    if (ad != null) {
      unawaited(ad.dispose());
    }
  }
}
