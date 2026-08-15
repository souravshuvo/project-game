import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../firebase_options.dart';
import 'game_telemetry.dart';

final class FirebaseGameTelemetry implements GameTelemetry {
  FirebaseGameTelemetry({this._analytics});

  static const _analyticsEnabled = bool.fromEnvironment(
    'WEATHER_SORT_ANALYTICS_ENABLED',
    defaultValue: true,
  );

  FirebaseAnalytics? _analytics;
  final _pendingEvents = <GameTelemetryEvent>[];
  bool _isReady = false;
  bool _isDisabled = !_analyticsEnabled;

  Future<void> initialize() async {
    if (_isDisabled) {
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ).timeout(const Duration(seconds: 8));
      }
      _analytics ??= FirebaseAnalytics.instance;
      await _analytics!.setAnalyticsCollectionEnabled(true);
      _isReady = true;
      final pending = List<GameTelemetryEvent>.of(_pendingEvents);
      _pendingEvents.clear();
      for (final event in pending) {
        unawaited(_logEvent(event));
      }
    } on Object {
      _pendingEvents.clear();
      _isDisabled = true;
    }
  }

  @override
  void track(GameTelemetryEvent event) {
    if (_isDisabled) {
      return;
    }
    if (!_isReady) {
      if (_pendingEvents.length < 80) {
        _pendingEvents.add(event);
      }
      return;
    }

    unawaited(_logEvent(event));
  }

  Future<void> _logEvent(GameTelemetryEvent event) async {
    final analytics = _analytics;
    if (analytics == null) {
      return;
    }

    try {
      await analytics.logEvent(
        name: _firebaseEventName(event.name),
        parameters: _firebaseParameters(event.parameters),
      );
    } on Object {
      return;
    }
  }

  String _firebaseEventName(String name) {
    return switch (name) {
      'app_open' => 'game_app_open',
      'screen_view' => 'game_screen_view',
      _ => name,
    };
  }

  Map<String, Object> _firebaseParameters(Map<String, Object> parameters) {
    return parameters.map((key, value) {
      return MapEntry(
        _firebaseParameterName(key),
        _firebaseParameterValue(value),
      );
    });
  }

  String _firebaseParameterName(String key) {
    return key
        .replaceAll(RegExp('[^a-zA-Z0-9_]'), '_')
        .toLowerCase()
        .replaceFirst(RegExp('^[0-9]+'), '');
  }

  Object _firebaseParameterValue(Object value) {
    if (value is bool) {
      return value ? 1 : 0;
    }
    if (value is num || value is String) {
      return value;
    }

    return value.toString();
  }
}
