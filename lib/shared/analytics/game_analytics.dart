abstract interface class GameAnalytics {
  Future<void> logEvent(String name, Map<String, Object> parameters);
}

class NoopGameAnalytics implements GameAnalytics {
  const NoopGameAnalytics();

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) async {}
}

class GameAnalyticsEvents {
  const GameAnalyticsEvents._();

  static const appSessionStarted = 'app_session_started';
  static const progressSnapshot = 'progress_snapshot';
  static const homeViewed = 'home_viewed';
  static const gameOpened = 'game_opened';
  static const levelSelectViewed = 'level_select_viewed';
  static const levelStart = 'level_start';
  static const shotFired = 'shot_fired';
  static const invalidAim = 'invalid_aim';
  static const shotMissed = 'shot_missed';
  static const bubbleAttached = 'bubble_attached';
  static const matchPopped = 'match_popped';
  static const floatingDropped = 'floating_dropped';
  static const levelEnd = 'level_end';
  static const resultAction = 'result_action';
  static const settingsChanged = 'settings_changed';
  static const adLoadStart = 'ad_load_start';
  static const adLoadSuccess = 'ad_load_success';
  static const adLoadFailed = 'ad_load_failed';
  static const adShowAttempt = 'ad_show_attempt';
  static const adShow = 'ad_show';
  static const adShowFailed = 'ad_show_failed';
  static const adDismissed = 'ad_dismissed';
  static const adSkipped = 'ad_skipped';
  static const adGateState = 'ad_gate_state';
}

String sanitizeGameAnalyticsName(String name) {
  return _safeAnalyticsIdentifier(name, fallback: 'game_event');
}

Map<String, Object> sanitizeGameAnalyticsParameters(
  Map<String, Object> parameters, {
  int maxParameters = 25,
}) {
  final sanitized = <String, Object>{};
  for (final entry in parameters.entries) {
    if (sanitized.length >= maxParameters) {
      break;
    }
    final key = _uniqueAnalyticsKey(
      sanitized,
      _safeAnalyticsIdentifier(entry.key, fallback: 'param'),
    );
    sanitized[key] = _safeAnalyticsValue(entry.value);
  }
  return sanitized;
}

String _uniqueAnalyticsKey(Map<String, Object> parameters, String key) {
  if (!parameters.containsKey(key)) {
    return key;
  }

  var suffix = 2;
  while (true) {
    final suffixText = '_$suffix';
    final prefixLength = 40 - suffixText.length;
    final prefix = key.length <= prefixLength
        ? key
        : key.substring(0, prefixLength);
    final candidate = '$prefix$suffixText';
    if (!parameters.containsKey(candidate)) {
      return candidate;
    }
    suffix++;
  }
}

Object _safeAnalyticsValue(Object value) {
  return switch (value) {
    bool() => value ? 1 : 0,
    int() => value,
    double() => value.isFinite ? value : 0,
    num() => value.toDouble().isFinite ? value.toDouble() : 0,
    String() => _truncateAnalyticsString(value),
    _ => _truncateAnalyticsString(value.toString()),
  };
}

String _truncateAnalyticsString(String value) {
  const maxLength = 100;
  if (value.length <= maxLength) {
    return value;
  }
  return value.substring(0, maxLength);
}

String _safeAnalyticsIdentifier(String input, {required String fallback}) {
  final buffer = StringBuffer();
  for (final codeUnit in input.codeUnits) {
    final isLetter =
        (codeUnit >= 65 && codeUnit <= 90) ||
        (codeUnit >= 97 && codeUnit <= 122);
    final isDigit = codeUnit >= 48 && codeUnit <= 57;
    final isUnderscore = codeUnit == 95;
    buffer.write(
      isLetter || isDigit || isUnderscore ? String.fromCharCode(codeUnit) : '_',
    );
  }

  var sanitized = buffer.toString();
  if (sanitized.isEmpty) {
    sanitized = fallback;
  }

  final firstCode = sanitized.codeUnitAt(0);
  final startsWithLetter =
      (firstCode >= 65 && firstCode <= 90) ||
      (firstCode >= 97 && firstCode <= 122);
  if (!startsWithLetter) {
    sanitized = '${fallback}_$sanitized';
  }

  if (sanitized.length > 40) {
    sanitized = sanitized.substring(0, 40);
  }
  return sanitized;
}
