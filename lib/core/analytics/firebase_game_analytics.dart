import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import 'game_analytics.dart';

class FirebaseGameAnalytics implements GameAnalytics {
  FirebaseGameAnalytics._(this._analytics);

  final FirebaseAnalytics _analytics;

  static Future<GameAnalytics> create({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    try {
      await Firebase.initializeApp().timeout(timeout);
      final analytics = FirebaseAnalytics.instance;
      await analytics.setAnalyticsCollectionEnabled(true);
      await analytics.setConsent(
        adStorageConsentGranted: false,
        adPersonalizationSignalsConsentGranted: false,
        adUserDataConsentGranted: false,
        analyticsStorageConsentGranted: true,
      );
      await analytics.setDefaultEventParameters(<String, Object>{
        'app_family': 'kidsland',
        'package_name': 'com.childhood.kidsland',
      });
      return FirebaseGameAnalytics._(analytics);
    } on Object {
      return const NoopGameAnalytics();
    }
  }

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  }) async {
    try {
      await _analytics.logEvent(
        name: normalizeAnalyticsName(name),
        parameters: normalizeAnalyticsParameters(parameters),
      );
    } on Object {
      // Analytics must never affect a child's ability to play.
    }
  }
}
