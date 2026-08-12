import 'dart:developer' as developer;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

class GameAnalytics {
  GameAnalytics._({required FirebaseAnalytics? firebaseAnalytics})
    : _firebaseAnalytics = firebaseAnalytics;

  final FirebaseAnalytics? _firebaseAnalytics;
  final List<AnalyticsEvent> _sessionEvents = <AnalyticsEvent>[];

  static Future<GameAnalytics> initialize() async {
    try {
      await Firebase.initializeApp();
      return GameAnalytics._(firebaseAnalytics: FirebaseAnalytics.instance);
    } on Object catch (error, stackTrace) {
      developer.log(
        'Firebase Analytics unavailable; using local analytics fallback.',
        name: 'emoji_chor_police.analytics',
        error: error,
        stackTrace: stackTrace,
      );
      return GameAnalytics._(firebaseAnalytics: null);
    }
  }

  static GameAnalytics localOnly() {
    return GameAnalytics._(firebaseAnalytics: null);
  }

  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  }) async {
    final safeName = _safeEventName(name);
    final safeParameters = _safeParameters(parameters);
    _sessionEvents.add(
      AnalyticsEvent(
        name: safeName,
        parameters: safeParameters,
        loggedAt: DateTime.now(),
      ),
    );

    try {
      await _firebaseAnalytics?.logEvent(
        name: safeName,
        parameters: safeParameters,
      );
    } on Object catch (error, stackTrace) {
      developer.log(
        'Analytics event failed: $safeName',
        name: 'emoji_chor_police.analytics',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  List<AnalyticsEvent> get sessionEvents {
    return List<AnalyticsEvent>.unmodifiable(_sessionEvents);
  }

  String _safeEventName(String name) {
    final sanitized = name
        .replaceAll(RegExp('[^a-zA-Z0-9_]'), '_')
        .replaceAll(RegExp('_+'), '_')
        .toLowerCase();
    if (sanitized.isEmpty) {
      return 'game_event';
    }
    if (sanitized.length <= 40) {
      return sanitized;
    }
    return sanitized.substring(0, 40);
  }

  Map<String, Object> _safeParameters(Map<String, Object?> parameters) {
    final safe = <String, Object>{};
    for (final entry in parameters.entries) {
      final key = _safeParameterName(entry.key);
      final value = entry.value;
      if (value == null) {
        continue;
      }
      if (value is bool) {
        safe[key] = value ? 1 : 0;
      } else if (value is num || value is String) {
        safe[key] = value;
      } else if (value is Enum) {
        safe[key] = value.name;
      } else {
        safe[key] = '$value';
      }
    }
    return safe;
  }

  String _safeParameterName(String name) {
    final sanitized = name
        .replaceAll(RegExp('[^a-zA-Z0-9_]'), '_')
        .replaceAll(RegExp('_+'), '_')
        .toLowerCase();
    if (sanitized.isEmpty) {
      return 'value';
    }
    if (sanitized.length <= 40) {
      return sanitized;
    }
    return sanitized.substring(0, 40);
  }
}

class AnalyticsEvent {
  const AnalyticsEvent({
    required this.name,
    required this.parameters,
    required this.loggedAt,
  });

  final String name;
  final Map<String, Object> parameters;
  final DateTime loggedAt;
}
