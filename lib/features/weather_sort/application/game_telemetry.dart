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
    required int sourceIndex,
    required int destinationIndex,
    required int layersMoved,
  }) {
    return GameTelemetryEvent('pour_valid', {
      'level_id': levelId,
      'source_index': sourceIndex,
      'destination_index': destinationIndex,
      'layers_moved': layersMoved,
    });
  }

  static GameTelemetryEvent pourInvalid({
    required int levelId,
    required String reason,
  }) {
    return GameTelemetryEvent('pour_invalid', {
      'level_id': levelId,
      'reason': reason,
    });
  }

  static GameTelemetryEvent undoUsed({
    required int levelId,
    required int moveCountAfter,
  }) {
    return GameTelemetryEvent('undo_used', {
      'level_id': levelId,
      'move_count_after': moveCountAfter,
    });
  }

  static GameTelemetryEvent levelRestart({
    required int levelId,
    required int movesBeforeRestart,
  }) {
    return GameTelemetryEvent('level_restart', {
      'level_id': levelId,
      'moves_before_restart': movesBeforeRestart,
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
}
