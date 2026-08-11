import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'game_telemetry.dart';

final class FirebaseGameTelemetry implements GameTelemetry {
  const FirebaseGameTelemetry(this.analytics);

  final FirebaseAnalytics analytics;

  @override
  void track(GameTelemetryEvent event) {
    unawaited(
      analytics
          .logEvent(name: event.name, parameters: _clean(event.parameters))
          .catchError((Object error, StackTrace stackTrace) {
            if (kDebugMode) {
              debugPrint('Failed to log analytics event ${event.name}: $error');
            }
          }),
    );
  }

  Map<String, Object> _clean(Map<String, Object> parameters) {
    return parameters.map((key, value) {
      final cleanKey = key.replaceAll(RegExp('[^A-Za-z0-9_]'), '_');
      return MapEntry(cleanKey, _cleanValue(value));
    });
  }

  Object _cleanValue(Object value) {
    return switch (value) {
      bool() => value ? 1 : 0,
      int() || double() || String() => value,
      _ => value.toString(),
    };
  }
}

final class CompositeGameTelemetry implements GameTelemetry {
  const CompositeGameTelemetry(this.delegates);

  final List<GameTelemetry> delegates;

  @override
  void track(GameTelemetryEvent event) {
    for (final delegate in delegates) {
      delegate.track(event);
    }
  }
}
