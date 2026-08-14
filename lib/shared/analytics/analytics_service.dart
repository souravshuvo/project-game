import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class AnalyticsConfig {
  const AnalyticsConfig._();

  static const enabled = bool.fromEnvironment(
    'ANALYTICS_ENABLED',
    defaultValue: true,
  );
}

abstract interface class AnalyticsService {
  bool get isEnabled;

  void logEvent(String name, Map<String, Object?> parameters);
}

class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  bool get isEnabled => false;

  @override
  void logEvent(String name, Map<String, Object?> parameters) {}
}

class FirebaseAnalyticsService implements AnalyticsService {
  const FirebaseAnalyticsService._(this._analytics);

  final FirebaseAnalytics _analytics;

  static Future<AnalyticsService> initialize() async {
    if (!AnalyticsConfig.enabled) {
      return const NoopAnalyticsService();
    }

    try {
      await Firebase.initializeApp();
      final analytics = FirebaseAnalytics.instance;
      await analytics.setAnalyticsCollectionEnabled(true);
      return FirebaseAnalyticsService._(analytics);
    } catch (error) {
      debugPrint('Firebase analytics disabled: $error');
      return const NoopAnalyticsService();
    }
  }

  @override
  bool get isEnabled => true;

  @override
  void logEvent(String name, Map<String, Object?> parameters) {
    unawaited(
      _analytics
          .logEvent(name: name, parameters: _sanitizeParameters(parameters))
          .catchError((Object error) {
            debugPrint('Analytics event failed: $name $error');
          }),
    );
  }

  Map<String, Object> _sanitizeParameters(Map<String, Object?> parameters) {
    final sanitized = <String, Object>{};
    for (final entry in parameters.entries) {
      final value = entry.value;
      if (value == null) {
        continue;
      }
      if (value is bool) {
        sanitized[entry.key] = value ? 1 : 0;
      } else if (value is num || value is String) {
        sanitized[entry.key] = value;
      } else {
        sanitized[entry.key] = value.toString();
      }
    }
    return sanitized;
  }
}
