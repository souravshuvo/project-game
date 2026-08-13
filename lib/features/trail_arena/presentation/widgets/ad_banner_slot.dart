import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../services/ad_mob_service.dart';
import '../../services/analytics_sink.dart';

class AdBannerSlot extends StatefulWidget {
  const AdBannerSlot({
    super.key,
    required this.analytics,
    required this.placement,
  });

  final AnalyticsSink analytics;
  final AdPlacement placement;

  @override
  State<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends State<AdBannerSlot> {
  BannerAd? _bannerAd;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBanner() {
    final unitId = AdMobConfig.bannerUnitId();
    if (unitId == null) {
      widget.analytics.log('ad_banner_disabled', {
        'placement': widget.placement.analyticsName,
        'reason': 'missing_unit_id_or_platform',
        'ad_mode': AdMobConfig.modeName,
      });
      return;
    }

    MobileAds.instance
        .initialize()
        .then((_) {
          if (!mounted) {
            return;
          }
          _createBanner(unitId);
        })
        .catchError((Object error) {
          widget.analytics.log('ad_banner_sdk_init_failed', {
            'placement': widget.placement.analyticsName,
            'error': error.toString(),
          });
        });
  }

  void _createBanner(String unitId) {
    final ad = BannerAd(
      adUnitId: unitId,
      size: AdSize.banner,
      request: AdMobConfig.request,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _loaded = true;
          });
          widget.analytics.log('ad_banner_loaded', {
            'placement': widget.placement.analyticsName,
            'ad_mode': AdMobConfig.modeName,
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          widget.analytics.log('ad_banner_load_failed', {
            'placement': widget.placement.analyticsName,
            'error_code': error.code,
            'error_message': error.message,
          });
        },
        onAdImpression: (ad) {
          widget.analytics.log('ad_banner_impression', {
            'placement': widget.placement.analyticsName,
          });
        },
        onAdClicked: (ad) {
          widget.analytics.log('ad_banner_click', {
            'placement': widget.placement.analyticsName,
          });
        },
      ),
    );

    _bannerAd = ad;
    ad.load();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _bannerAd;
    if (!_loaded || ad == null) {
      return const SizedBox.shrink();
    }
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
