class GameTelemetryEvent {
  const GameTelemetryEvent(
    this.name, [
    this.parameters = const <String, Object>{},
  ]);

  final String name;
  final Map<String, Object> parameters;
}

abstract interface class GameTelemetry {
  void track(GameTelemetryEvent event);
}

final class NoOpGameTelemetry implements GameTelemetry {
  const NoOpGameTelemetry();

  @override
  void track(GameTelemetryEvent event) {}
}

final class GameTelemetryEvents {
  const GameTelemetryEvents._();

  static GameTelemetryEvent appOpen({
    required int totalLevels,
    required int unlockedLevelCount,
  }) {
    return GameTelemetryEvent('app_open', {
      'total_levels': totalLevels,
      'unlocked_level_count': unlockedLevelCount,
    });
  }

  static GameTelemetryEvent screenView({required String screen}) {
    return GameTelemetryEvent('screen_view', {'screen': screen});
  }

  static GameTelemetryEvent levelStart({
    required int levelId,
    required int levelNumber,
    required String source,
  }) {
    return GameTelemetryEvent('level_start', {
      'level_id': levelId,
      'level_number': levelNumber,
      'source': source,
    });
  }

  static GameTelemetryEvent levelComplete({
    required int levelId,
    required int levelNumber,
    required int moveCount,
    required bool isDailyLevel,
    required int unlockedLevelCount,
  }) {
    return GameTelemetryEvent('level_complete', {
      'level_id': levelId,
      'level_number': levelNumber,
      'move_count': moveCount,
      'is_daily_level': isDailyLevel,
      'unlocked_level_count': unlockedLevelCount,
    });
  }

  static GameTelemetryEvent levelRetry({
    required int levelId,
    required int levelNumber,
    required int moveCount,
  }) {
    return GameTelemetryEvent('level_retry', {
      'level_id': levelId,
      'level_number': levelNumber,
      'move_count': moveCount,
    });
  }

  static GameTelemetryEvent hintClaim({required int hintBalance}) {
    return GameTelemetryEvent('hint_claim', {'hint_balance': hintBalance});
  }

  static GameTelemetryEvent hintUse({
    required int levelId,
    required int levelNumber,
    required int hintBalance,
  }) {
    return GameTelemetryEvent('hint_use', {
      'level_id': levelId,
      'level_number': levelNumber,
      'hint_balance': hintBalance,
    });
  }

  static GameTelemetryEvent settingsSoundToggle({required bool enabled}) {
    return GameTelemetryEvent('settings_sound_toggle', {'enabled': enabled});
  }

  static GameTelemetryEvent settingsHapticsToggle({required bool enabled}) {
    return GameTelemetryEvent('settings_haptics_toggle', {'enabled': enabled});
  }
}
