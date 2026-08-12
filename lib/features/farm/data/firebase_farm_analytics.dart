import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import '../application/analytics_events.dart';

class FirebaseFarmAnalytics implements FarmAnalytics {
  FirebaseFarmAnalytics._(this._analytics);

  final FirebaseAnalytics _analytics;

  static Future<FarmAnalytics> create() async {
    try {
      await Firebase.initializeApp();
      final analytics = FirebaseAnalytics.instance;
      await analytics.setAnalyticsCollectionEnabled(true);
      return FirebaseFarmAnalytics._(analytics);
    } on Object {
      return const NoOpFarmAnalytics();
    }
  }

  @override
  void log(String eventName, [Map<String, Object?> properties = const {}]) {
    unawaited(
      _analytics.logEvent(
        name: eventName,
        parameters: _sanitizeProperties(properties),
      ),
    );
  }

  static Map<String, Object> _sanitizeProperties(
    Map<String, Object?> properties,
  ) {
    final sanitized = <String, Object>{};
    for (final entry in properties.entries) {
      final key = _sanitizeKey(entry.key);
      final value = entry.value;
      if (value == null) {
        continue;
      }
      if (value is String || value is int || value is double) {
        sanitized[key] = value;
      } else if (value is num) {
        sanitized[key] = value.toDouble();
      } else if (value is bool) {
        sanitized[key] = value ? 'true' : 'false';
      } else {
        sanitized[key] = value.toString();
      }
    }
    return sanitized;
  }

  static String _sanitizeKey(String key) {
    final sanitized = key
        .replaceAll(RegExp('[^a-zA-Z0-9_]'), '_')
        .replaceAll(RegExp('_+'), '_');
    if (sanitized.isEmpty) {
      return 'value';
    }
    return sanitized.length > 40 ? sanitized.substring(0, 40) : sanitized;
  }
}
