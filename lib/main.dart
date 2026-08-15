import 'package:flutter/material.dart';

import 'app/kids_land_app.dart';
import 'core/ads/ad_config.dart';
import 'core/ads/app_ads_controller.dart';
import 'core/ads/google_mobile_ads_controller.dart';
import 'core/analytics/firebase_game_analytics.dart';
import 'core/analytics/game_analytics.dart';
import 'core/audio/letter_audio_cue.dart';
import 'features/tracing/data/hive_progress_repository.dart';
import 'features/tracing/data/progress_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final progressRepository = await _openProgressRepository();
  final analytics = await FirebaseGameAnalytics.create();
  final adConfig = AdMobConfig.fromEnvironment();
  final adsController = _openAdsController(
    config: adConfig,
    analytics: analytics,
  );

  analytics.appSessionStart(
    analyticsMode: analytics is NoopGameAnalytics ? 'disabled' : 'firebase',
    adMode: adConfig.modeName,
    packageName: 'com.childhood.kidsland',
  );

  runApp(
    KidsLandApp(
      progressRepository: progressRepository,
      audioCue: SystemLetterAudioCue(
        isSoundEnabled: () => progressRepository.soundEnabled,
        isHapticsEnabled: () => progressRepository.hapticsEnabled,
      ),
      analytics: analytics,
      adsController: adsController,
    ),
  );
}

Future<ProgressRepository> _openProgressRepository() async {
  try {
    return await HiveProgressRepository.open();
  } on Object {
    // Local-storage failure must not lock a young child out of the activity.
    // This process-only fallback intentionally collects and transmits nothing.
    return MemoryProgressRepository();
  }
}

AppAdsController _openAdsController({
  required AdMobConfig config,
  required GameAnalytics analytics,
}) {
  if (!config.servesAds) {
    return NoopAppAdsController(
      reason: config.disabledReason ?? 'disabled',
      adMode: config.modeName,
      analytics: analytics,
    );
  }
  return GoogleMobileAdsController(config: config, analytics: analytics);
}
