import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'app_runtime_config.dart';
import 'firebase_game_telemetry.dart';
import 'game_ads.dart';
import 'game_telemetry.dart';

class AppRuntimeServices {
  AppRuntimeServices({required this.telemetry, required this.ads});

  final GameTelemetry telemetry;
  final GameAds ads;

  static Future<AppRuntimeServices> initialize() async {
    final telemetry = await _initializeTelemetry();
    final ads = MobileGameAds(telemetry: telemetry);
    await ads.initialize();

    return AppRuntimeServices(telemetry: telemetry, ads: ads);
  }

  static Future<GameTelemetry> _initializeTelemetry() async {
    if (!AppRuntimeConfig.firebaseEnabled ||
        !AppRuntimeConfig.isSupportedMobilePlatform) {
      return const NoOpGameTelemetry();
    }

    try {
      await Firebase.initializeApp();

      final analytics = FirebaseAnalytics.instance;
      await analytics.setAnalyticsCollectionEnabled(true);

      if (AppRuntimeConfig.crashlyticsEnabled) {
        await _installCrashlyticsHandlers();
      }

      return FirebaseGameTelemetry(analytics);
    } on Object catch (error) {
      if (kDebugMode) {
        debugPrint('Firebase disabled: $error');
      }
      return const NoOpGameTelemetry();
    }
  }

  static Future<void> _installCrashlyticsHandlers() async {
    final crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      crashlytics.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      crashlytics.recordError(error, stackTrace, fatal: true);
      return true;
    };
  }
}
