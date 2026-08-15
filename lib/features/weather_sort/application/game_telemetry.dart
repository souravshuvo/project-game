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

  static GameTelemetryEvent appOpen({required int totalLevels}) {
    return GameTelemetryEvent('app_open', {'total_levels': totalLevels});
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

  static GameTelemetryEvent levelExit({
    required int levelId,
    required int levelNumber,
    required int moves,
    required int durationSeconds,
    required String reason,
  }) {
    return GameTelemetryEvent('level_exit', {
      'level_id': levelId,
      'level_number': levelNumber,
      'moves': moves,
      'duration_seconds': durationSeconds,
      'reason': reason,
    });
  }

  static GameTelemetryEvent settingsChanged({
    required String settingName,
    required bool value,
  }) {
    return GameTelemetryEvent('settings_changed', {
      'setting_name': settingName,
      'value': value,
    });
  }

  static GameTelemetryEvent pourValid({
    required int levelId,
    required int levelNumber,
    required int sourceIndex,
    required int destinationIndex,
    required int layersMoved,
    required int moveCountAfter,
  }) {
    return GameTelemetryEvent('pour_valid', {
      'level_id': levelId,
      'level_number': levelNumber,
      'source_index': sourceIndex,
      'destination_index': destinationIndex,
      'layers_moved': layersMoved,
      'move_count_after': moveCountAfter,
    });
  }

  static GameTelemetryEvent pourInvalid({
    required int levelId,
    required int levelNumber,
    required String reason,
  }) {
    return GameTelemetryEvent('pour_invalid', {
      'level_id': levelId,
      'level_number': levelNumber,
      'reason': reason,
    });
  }

  static GameTelemetryEvent undoUsed({
    required int levelId,
    required int levelNumber,
    required int moveCountAfter,
  }) {
    return GameTelemetryEvent('undo_used', {
      'level_id': levelId,
      'level_number': levelNumber,
      'move_count_after': moveCountAfter,
    });
  }

  static GameTelemetryEvent levelRestart({
    required int levelId,
    required int levelNumber,
    required int movesBeforeRestart,
    required int durationSeconds,
  }) {
    return GameTelemetryEvent('level_restart', {
      'level_id': levelId,
      'level_number': levelNumber,
      'moves_before_restart': movesBeforeRestart,
      'duration_seconds': durationSeconds,
    });
  }

  static GameTelemetryEvent levelComplete({
    required int levelId,
    required int levelNumber,
    required int moves,
    required int stars,
    required int durationSeconds,
  }) {
    return GameTelemetryEvent('level_complete', {
      'level_id': levelId,
      'level_number': levelNumber,
      'moves': moves,
      'stars': stars,
      'duration_seconds': durationSeconds,
    });
  }

  static GameTelemetryEvent adInitComplete({
    required String environment,
    required bool usesTestAds,
  }) {
    return GameTelemetryEvent('ad_init_complete', {
      'environment': environment,
      'uses_test_ads': usesTestAds,
    });
  }

  static GameTelemetryEvent adInitSkipped({required String reason}) {
    return GameTelemetryEvent('ad_init_skipped', {'reason': reason});
  }

  static GameTelemetryEvent adInitFailed({required String error}) {
    return GameTelemetryEvent('ad_init_failed', {'error': error});
  }

  static GameTelemetryEvent adLoadStart({
    required String placement,
    required String format,
    required String environment,
  }) {
    return GameTelemetryEvent('ad_load_start', {
      'placement': placement,
      'format': format,
      'environment': environment,
    });
  }

  static GameTelemetryEvent adLoadComplete({
    required String placement,
    required String format,
  }) {
    return GameTelemetryEvent('ad_load_complete', {
      'placement': placement,
      'format': format,
    });
  }

  static GameTelemetryEvent adLoadFailed({
    required String placement,
    required String format,
    required int code,
  }) {
    return GameTelemetryEvent('ad_load_failed', {
      'placement': placement,
      'format': format,
      'code': code,
    });
  }

  static GameTelemetryEvent adOpportunity({
    required String placement,
    required String format,
    required int levelId,
    required int levelNumber,
  }) {
    return GameTelemetryEvent('ad_opportunity', {
      'placement': placement,
      'format': format,
      'level_id': levelId,
      'level_number': levelNumber,
    });
  }

  static GameTelemetryEvent adFrequencyCapped({
    required String placement,
    required String format,
    required String reason,
    required int completedTransitions,
  }) {
    return GameTelemetryEvent('ad_frequency_capped', {
      'placement': placement,
      'format': format,
      'reason': reason,
      'completed_transitions': completedTransitions,
    });
  }

  static GameTelemetryEvent adSkipped({
    required String placement,
    required String format,
    required String reason,
  }) {
    return GameTelemetryEvent('ad_skipped', {
      'placement': placement,
      'format': format,
      'reason': reason,
    });
  }

  static GameTelemetryEvent adShow({
    required String placement,
    required String format,
  }) {
    return GameTelemetryEvent('ad_show', {
      'placement': placement,
      'format': format,
    });
  }

  static GameTelemetryEvent adDismissed({
    required String placement,
    required String format,
  }) {
    return GameTelemetryEvent('ad_dismissed', {
      'placement': placement,
      'format': format,
    });
  }

  static GameTelemetryEvent adShowFailed({
    required String placement,
    required String format,
    required String error,
  }) {
    return GameTelemetryEvent('ad_show_failed', {
      'placement': placement,
      'format': format,
      'error': error,
    });
  }

  static GameTelemetryEvent adShowTimeout({
    required String placement,
    required String format,
  }) {
    return GameTelemetryEvent('ad_show_timeout', {
      'placement': placement,
      'format': format,
    });
  }
}
