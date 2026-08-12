import 'package:flutter/foundation.dart';

final class TicTacToeAdUnits {
  const TicTacToeAdUnits._();

  static const androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const iosTestInterstitial = 'ca-app-pub-3940256099942544/4411468910';

  static const _androidProductionInterstitial = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL_ID',
  );
  static const _iosProductionInterstitial = String.fromEnvironment(
    'ADMOB_IOS_INTERSTITIAL_ID',
  );

  static bool get isSupportedPlatform {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static String get interstitial {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        _androidProductionInterstitial.isNotEmpty
            ? _androidProductionInterstitial
            : androidTestInterstitial,
      TargetPlatform.iOS =>
        _iosProductionInterstitial.isNotEmpty
            ? _iosProductionInterstitial
            : iosTestInterstitial,
      _ => '',
    };
  }

  static bool get usesTestInterstitial {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _androidProductionInterstitial.isEmpty,
      TargetPlatform.iOS => _iosProductionInterstitial.isEmpty,
      _ => true,
    };
  }
}
