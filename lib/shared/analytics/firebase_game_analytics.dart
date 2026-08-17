import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'game_analytics.dart';

class FirebaseGameAnalytics implements GameAnalytics {
  const FirebaseGameAnalytics._(this._analytics);

  static const enabled = bool.fromEnvironment(
    'ANALYTICS_ENABLED',
    defaultValue: true,
  );

  final FirebaseAnalytics _analytics;

  static Future<GameAnalytics> create() async {
    if (!enabled) {
      return const NoopGameAnalytics();
    }

    try {
      await Firebase.initializeApp();
      final analytics = FirebaseAnalytics.instance;
      await analytics.setAnalyticsCollectionEnabled(true);
      return FirebaseGameAnalytics._(analytics);
    } on Object catch (error) {
      debugPrint('Firebase analytics disabled: $error');
      return const NoopGameAnalytics();
    }
  }

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) {
    return _analytics.logEvent(
      name: sanitizeGameAnalyticsName(name),
      parameters: sanitizeGameAnalyticsParameters(parameters),
    );
  }
}
