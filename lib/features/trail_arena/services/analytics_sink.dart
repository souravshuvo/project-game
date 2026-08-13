import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';

abstract class AnalyticsSink {
  void log(String name, [Map<String, Object?> parameters = const {}]);
}

class NoOpAnalyticsSink implements AnalyticsSink {
  const NoOpAnalyticsSink();

  @override
  void log(String name, [Map<String, Object?> parameters = const {}]) {}
}

class FirebaseAnalyticsSink implements AnalyticsSink {
  const FirebaseAnalyticsSink(this.analytics);

  final FirebaseAnalytics analytics;

  @override
  void log(String name, [Map<String, Object?> parameters = const {}]) {
    unawaited(
      analytics.logEvent(
        name: name,
        parameters: _sanitizeParameters(parameters),
      ),
    );
  }

  Map<String, Object> _sanitizeParameters(Map<String, Object?> parameters) {
    final sanitized = <String, Object>{};
    for (final entry in parameters.entries) {
      final value = entry.value;
      if (value == null) {
        continue;
      }
      sanitized[entry.key] = switch (value) {
        String() => value,
        int() => value,
        double() => value,
        bool() => value ? 1 : 0,
        Enum() => value.name,
        DateTime() => value.millisecondsSinceEpoch,
        Duration() => value.inMilliseconds,
        _ => value.toString(),
      };
    }
    return sanitized;
  }
}
