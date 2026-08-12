import 'package:flutter/widgets.dart';

abstract interface class AppAdsController {
  bool get isEnabled;

  Widget buildHomeBanner();

  void preloadInterstitial();

  Future<void> recordCompletedGameBreak({
    required String gameId,
    required String gameTitle,
  });

  void dispose();
}

class NoopAppAdsController implements AppAdsController {
  const NoopAppAdsController({this.reason = 'disabled'});

  final String reason;

  @override
  bool get isEnabled => false;

  @override
  Widget buildHomeBanner() => const SizedBox.shrink();

  @override
  void preloadInterstitial() {}

  @override
  Future<void> recordCompletedGameBreak({
    required String gameId,
    required String gameTitle,
  }) async {}

  @override
  void dispose() {}
}
