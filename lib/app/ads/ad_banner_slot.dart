import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_controller.dart';

class AdBannerSlot extends StatelessWidget {
  const AdBannerSlot({super.key, required this.ads});

  final AdController ads;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ads,
      builder: (context, _) {
        final banner = ads.bannerAd;
        if (banner == null) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          top: false,
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Color(0xFFF6F0E7)),
            child: SizedBox(
              width: banner.size.width.toDouble(),
              height: banner.size.height.toDouble(),
              child: Center(child: AdWidget(ad: banner)),
            ),
          ),
        );
      },
    );
  }
}
