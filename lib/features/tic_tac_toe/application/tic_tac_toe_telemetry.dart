class TicTacToeTelemetryEvent {
  const TicTacToeTelemetryEvent(
    this.name, [
    this.parameters = const <String, Object>{},
  ]);

  final String name;
  final Map<String, Object> parameters;
}

abstract interface class TicTacToeTelemetry {
  void track(TicTacToeTelemetryEvent event);
}

final class NoOpTicTacToeTelemetry implements TicTacToeTelemetry {
  const NoOpTicTacToeTelemetry();

  @override
  void track(TicTacToeTelemetryEvent event) {}
}

final class TicTacToeTelemetryEvents {
  const TicTacToeTelemetryEvents._();

  static TicTacToeTelemetryEvent appOpened() {
    return const TicTacToeTelemetryEvent('app_opened');
  }

  static TicTacToeTelemetryEvent modeSelected({required String mode}) {
    return TicTacToeTelemetryEvent('mode_selected', {'mode': mode});
  }

  static TicTacToeTelemetryEvent roundStarted({
    required String mode,
    required String startingPlayer,
  }) {
    return TicTacToeTelemetryEvent('round_started', {
      'mode': mode,
      'starting_player': startingPlayer,
    });
  }

  static TicTacToeTelemetryEvent moveMade({
    required String mode,
    required int moveIndex,
    required int cellIndex,
    required String playerType,
    required String mark,
  }) {
    return TicTacToeTelemetryEvent('move_made', {
      'mode': mode,
      'move_index': moveIndex,
      'cell_index': cellIndex,
      'player_type': playerType,
      'mark': mark,
    });
  }

  static TicTacToeTelemetryEvent invalidCellTapped({
    required String mode,
    required int cellIndex,
  }) {
    return TicTacToeTelemetryEvent('invalid_cell_tapped', {
      'mode': mode,
      'cell_index': cellIndex,
    });
  }

  static TicTacToeTelemetryEvent roundEnded({
    required String mode,
    required String result,
    required String winnerType,
    required int moveCount,
  }) {
    return TicTacToeTelemetryEvent('round_ended', {
      'mode': mode,
      'result': result,
      'winner_type': winnerType,
      'move_count': moveCount,
    });
  }

  static TicTacToeTelemetryEvent rematchTapped({required String mode}) {
    return TicTacToeTelemetryEvent('rematch_tapped', {'mode': mode});
  }

  static TicTacToeTelemetryEvent scoreReset({required String mode}) {
    return TicTacToeTelemetryEvent('score_reset', {'mode': mode});
  }

  static TicTacToeTelemetryEvent settingsChanged({
    required String settingName,
    required bool enabled,
  }) {
    return TicTacToeTelemetryEvent('settings_changed', {
      'setting_name': settingName,
      'enabled': enabled,
    });
  }
}
