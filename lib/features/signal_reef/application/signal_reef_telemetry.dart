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

  static SignalReefTelemetryEvent appOpen({
    required int runsPlayed,
    required int bestScore,
    required int bestWaveReached,
    required int totalWaves,
  }) {
    return SignalReefTelemetryEvent('app_open', {
      'runs_played': runsPlayed,
      'best_score': bestScore,
      'best_wave_reached': bestWaveReached,
      'total_waves': totalWaves,
    });
  }

  static SignalReefTelemetryEvent gameStart({
    required String source,
    required int totalWaves,
    required int runsPlayed,
  }) {
    return SignalReefTelemetryEvent('game_start', {
      'source': source,
      'total_waves': totalWaves,
      'runs_played': runsPlayed,
    });
  }

  static SignalReefTelemetryEvent waveStart({
    required int waveNumber,
    required int totalEnemies,
    required int pulseSeeds,
    required int maxActiveEnemies,
    required int spawnIntervalMillis,
  }) {
    return SignalReefTelemetryEvent('wave_start', {
      'wave_number': waveNumber,
      'total_enemies': totalEnemies,
      'pulse_seeds': pulseSeeds,
      'max_active_enemies': maxActiveEnemies,
      'spawn_interval_ms': spawnIntervalMillis,
    });
  }

  static SignalReefTelemetryEvent waveComplete({
    required int waveNumber,
    required int score,
    required int hullRemaining,
    required int durationSeconds,
  }) {
    return SignalReefTelemetryEvent('wave_complete', {
      'wave_number': waveNumber,
      'score': score,
      'hull_remaining': hullRemaining,
      'duration_seconds': durationSeconds,
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
    required int durationSeconds,
  }) {
    return SignalReefTelemetryEvent('player_death', {
      'score': score,
      'wave_number': waveNumber,
      'duration_seconds': durationSeconds,
    });
  }

  static SignalReefTelemetryEvent gameWin({
    required int score,
    required int durationSeconds,
  }) {
    return SignalReefTelemetryEvent('game_win', {
      'score': score,
      'duration_seconds': durationSeconds,
    });
  }

  static SignalReefTelemetryEvent gameResult({
    required int score,
    required int waveReached,
    required int wavesCleared,
    required int durationSeconds,
    required int hullRemaining,
    required bool won,
  }) {
    return SignalReefTelemetryEvent('game_result', {
      'score': score,
      'wave_reached': waveReached,
      'waves_cleared': wavesCleared,
      'duration_seconds': durationSeconds,
      'hull_remaining': hullRemaining,
      'won': won,
    });
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

  static SignalReefTelemetryEvent adEvent({
    required String action,
    required String placement,
    required String environment,
    String? reason,
  }) {
    return SignalReefTelemetryEvent('ad_$action', {
      'placement': placement,
      'environment': environment,
      if (reason != null) 'reason': reason,
    });
  }
}
