import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'ad_service.dart';

class AdBannerSlot extends StatefulWidget {
  const AdBannerSlot({super.key, required this.ads, required this.placement});

  final AdService ads;
  final String placement;

  @override
  State<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends State<AdBannerSlot> {
  BannerAd? _bannerAd;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    widget.ads.addListener(_handleAdsChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    widget.ads.removeListener(_handleAdsChanged);
    _bannerAd?.dispose();
    super.dispose();
  }

  void _handleAdsChanged() {
    if (!_loaded && _bannerAd == null) {
      _load();
    }
  }

  void _load() {
    final adUnitId = widget.ads.bannerAdUnitId;
    if (!mounted || !widget.ads.canRequestBanner || adUnitId == null) {
      return;
    }

    widget.ads.logBannerRequest(widget.placement);
    final bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      request: AdConfig.request,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _loaded = true;
          });
          widget.ads.logBannerLoaded(widget.placement);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          widget.ads.logBannerFailed(widget.placement, error);
        },
        onAdImpression: (ad) {
          widget.ads.logBannerImpression(widget.placement);
        },
        onAdClicked: (ad) {
          widget.ads.logBannerClick(widget.placement);
        },
      ),
    );

    _bannerAd = bannerAd;
    bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    final bannerAd = _bannerAd;
    if (!_loaded || bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: SizedBox(
        width: bannerAd.size.width.toDouble(),
        height: bannerAd.size.height.toDouble(),
        child: AdWidget(ad: bannerAd),
      ),
    );
  }
}
