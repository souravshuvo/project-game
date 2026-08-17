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
    required int completedLevelCount,
    required int streakDays,
  }) {
    return GameTelemetryEvent('app_open', {
      'total_levels': totalLevels,
      'unlocked_level_count': unlockedLevelCount,
      'completed_level_count': completedLevelCount,
      'streak_days': streakDays,
    });
  }

  static GameTelemetryEvent screenView({required String screen}) {
    return GameTelemetryEvent('screen_view', {'screen': screen});
  }

  static GameTelemetryEvent levelStart({
    required int levelId,
    required int levelNumber,
    required String source,
    required int boardRows,
    required int boardCols,
    required int arrowCount,
    required int validMoveCount,
  }) {
    return GameTelemetryEvent('level_start', {
      'level_id': levelId,
      'level_number': levelNumber,
      'source': source,
      'board_rows': boardRows,
      'board_cols': boardCols,
      'arrow_count': arrowCount,
      'valid_move_count': validMoveCount,
    });
  }

  static GameTelemetryEvent levelComplete({
    required int levelId,
    required int levelNumber,
    required int moveCount,
    required int invalidTapCount,
    required int hintUseCount,
    required int durationSeconds,
    required bool isDailyLevel,
    required int unlockedLevelCount,
    required int boardRows,
    required int boardCols,
    required int arrowCount,
  }) {
    return GameTelemetryEvent('level_complete', {
      'level_id': levelId,
      'level_number': levelNumber,
      'move_count': moveCount,
      'invalid_tap_count': invalidTapCount,
      'hint_use_count': hintUseCount,
      'duration_seconds': durationSeconds,
      'is_daily_level': isDailyLevel,
      'unlocked_level_count': unlockedLevelCount,
      'board_rows': boardRows,
      'board_cols': boardCols,
      'arrow_count': arrowCount,
    });
  }

  static GameTelemetryEvent levelRetry({
    required int levelId,
    required int levelNumber,
    required int moveCount,
    required int invalidTapCount,
    required int hintUseCount,
    required int durationSeconds,
  }) {
    return GameTelemetryEvent('level_retry', {
      'level_id': levelId,
      'level_number': levelNumber,
      'move_count': moveCount,
      'invalid_tap_count': invalidTapCount,
      'hint_use_count': hintUseCount,
      'duration_seconds': durationSeconds,
    });
  }

  static GameTelemetryEvent levelInvalidTap({
    required int levelId,
    required int levelNumber,
    required int moveCount,
    required int invalidTapCount,
    required int validMoveCount,
  }) {
    return GameTelemetryEvent('level_invalid_tap', {
      'level_id': levelId,
      'level_number': levelNumber,
      'move_count': moveCount,
      'invalid_tap_count': invalidTapCount,
      'valid_move_count': validMoveCount,
    });
  }

  static GameTelemetryEvent levelStuck({
    required int levelId,
    required int levelNumber,
    required int boardRows,
    required int boardCols,
    required int arrowCount,
    required int moveCount,
    required int invalidTapCount,
    required int hintUseCount,
  }) {
    return GameTelemetryEvent('level_stuck', {
      'level_id': levelId,
      'level_number': levelNumber,
      'board_rows': boardRows,
      'board_cols': boardCols,
      'arrow_count': arrowCount,
      'move_count': moveCount,
      'invalid_tap_count': invalidTapCount,
      'hint_use_count': hintUseCount,
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

  static GameTelemetryEvent rewardedHintGrant({
    required int levelNumber,
    required int hintBalance,
    required String placement,
  }) {
    return GameTelemetryEvent('rewarded_hint_grant', {
      'level_number': levelNumber,
      'hint_balance': hintBalance,
      'placement': placement,
    });
  }

  static GameTelemetryEvent settingsSoundToggle({required bool enabled}) {
    return GameTelemetryEvent('settings_sound_toggle', {'enabled': enabled});
  }

  static GameTelemetryEvent settingsHapticsToggle({required bool enabled}) {
    return GameTelemetryEvent('settings_haptics_toggle', {'enabled': enabled});
  }

  static GameTelemetryEvent adEvent({
    required String action,
    required String format,
    required String placement,
    required String environment,
    String? reason,
    int? levelNumber,
    int? errorCode,
  }) {
    final parameters = <String, Object>{
      'action': action,
      'format': format,
      'placement': placement,
      'environment': environment,
    };

    if (reason != null) {
      parameters['reason'] = reason;
    }
    if (levelNumber != null) {
      parameters['level_number'] = levelNumber;
    }
    if (errorCode != null) {
      parameters['error_code'] = errorCode;
    }

    return GameTelemetryEvent('ad_event', parameters);
  }
}
