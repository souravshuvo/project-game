class SignalReefTelemetryEvent {
  const SignalReefTelemetryEvent(
    this.name, [
    this.parameters = const <String, Object>{},
  ]);

  final String name;
  final Map<String, Object> parameters;
}

abstract interface class SignalReefTelemetry {
  void track(SignalReefTelemetryEvent event);
}

final class NoOpSignalReefTelemetry implements SignalReefTelemetry {
  const NoOpSignalReefTelemetry();

  @override
  void track(SignalReefTelemetryEvent event) {}
}

final class SignalReefTelemetryEvents {
  const SignalReefTelemetryEvents._();

  static SignalReefTelemetryEvent gameStart({required String source}) {
    return SignalReefTelemetryEvent('game_start', {'source': source});
  }

  static SignalReefTelemetryEvent waveStart({required int waveNumber}) {
    return SignalReefTelemetryEvent('wave_start', {'wave_number': waveNumber});
  }

  static SignalReefTelemetryEvent waveComplete({
    required int waveNumber,
    required int score,
  }) {
    return SignalReefTelemetryEvent('wave_complete', {
      'wave_number': waveNumber,
      'score': score,
    });
  }

  static SignalReefTelemetryEvent playerDamage({
    required int hullRemaining,
    required int waveNumber,
  }) {
    return SignalReefTelemetryEvent('player_damage', {
      'hull_remaining': hullRemaining,
      'wave_number': waveNumber,
    });
  }

  static SignalReefTelemetryEvent playerDeath({
    required int score,
    required int waveNumber,
  }) {
    return SignalReefTelemetryEvent('player_death', {
      'score': score,
      'wave_number': waveNumber,
    });
  }

  static SignalReefTelemetryEvent gameWin({required int score}) {
    return SignalReefTelemetryEvent('game_win', {'score': score});
  }

  static SignalReefTelemetryEvent gameRestart() {
    return const SignalReefTelemetryEvent('game_restart');
  }

  static SignalReefTelemetryEvent pauseOpen() {
    return const SignalReefTelemetryEvent('pause_open');
  }

  static SignalReefTelemetryEvent pauseResume() {
    return const SignalReefTelemetryEvent('pause_resume');
  }

  static SignalReefTelemetryEvent settingsChanged({
    required String setting,
    required bool enabled,
  }) {
    return SignalReefTelemetryEvent('settings_changed', {
      'setting': setting,
      'enabled': enabled,
    });
  }

  static SignalReefTelemetryEvent bestScoreUpdated({required int bestScore}) {
    return SignalReefTelemetryEvent('best_score_updated', {
      'best_score': bestScore,
    });
  }
}
