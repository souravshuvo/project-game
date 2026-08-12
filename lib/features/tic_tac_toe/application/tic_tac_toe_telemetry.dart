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

  static TicTacToeTelemetryEvent appSessionStarted({
    required int openCount,
    required int daysSinceFirstOpen,
    required int daysSincePreviousOpen,
    required bool usesTestAds,
  }) {
    return TicTacToeTelemetryEvent('app_session_started', {
      'open_count': openCount,
      'days_since_first_open': daysSinceFirstOpen,
      'days_since_previous_open': daysSincePreviousOpen,
      'uses_test_ads': usesTestAds,
    });
  }

  static TicTacToeTelemetryEvent modeSelected({required String mode}) {
    return TicTacToeTelemetryEvent('mode_selected', {'mode': mode});
  }

  static TicTacToeTelemetryEvent matchFormatSelected({
    required String matchFormat,
  }) {
    return TicTacToeTelemetryEvent('match_format_selected', {
      'match_format': matchFormat,
    });
  }

  static TicTacToeTelemetryEvent roundStarted({
    required String mode,
    required String matchFormat,
    required int roundNumber,
    required String startingPlayer,
    required String aiDifficulty,
  }) {
    return TicTacToeTelemetryEvent('round_started', {
      'mode': mode,
      'match_format': matchFormat,
      'round_number': roundNumber,
      'starting_player': startingPlayer,
      'ai_difficulty': aiDifficulty,
    });
  }

  static TicTacToeTelemetryEvent moveMade({
    required String mode,
    required String matchFormat,
    required int moveIndex,
    required int cellIndex,
    required String playerType,
    required String mark,
  }) {
    return TicTacToeTelemetryEvent('move_made', {
      'mode': mode,
      'match_format': matchFormat,
      'move_index': moveIndex,
      'cell_index': cellIndex,
      'player_type': playerType,
      'mark': mark,
    });
  }

  static TicTacToeTelemetryEvent invalidCellTapped({
    required String mode,
    required String matchFormat,
    required int cellIndex,
  }) {
    return TicTacToeTelemetryEvent('invalid_cell_tapped', {
      'mode': mode,
      'match_format': matchFormat,
      'cell_index': cellIndex,
    });
  }

  static TicTacToeTelemetryEvent roundEnded({
    required String mode,
    required String matchFormat,
    required int roundNumber,
    required String result,
    required String winnerType,
    required int moveCount,
    required String aiDifficulty,
  }) {
    return TicTacToeTelemetryEvent('round_ended', {
      'mode': mode,
      'match_format': matchFormat,
      'round_number': roundNumber,
      'result': result,
      'winner_type': winnerType,
      'move_count': moveCount,
      'ai_difficulty': aiDifficulty,
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

  static TicTacToeTelemetryEvent matchCompleted({
    required String mode,
    required String matchFormat,
    required String result,
    required String winnerType,
    required int roundsPlayed,
    required int xWins,
    required int oWins,
    required int draws,
    required int completedMatchesThisSession,
    required String aiDifficulty,
  }) {
    return TicTacToeTelemetryEvent('match_completed', {
      'mode': mode,
      'match_format': matchFormat,
      'result': result,
      'winner_type': winnerType,
      'rounds_played': roundsPlayed,
      'x_wins': xWins,
      'o_wins': oWins,
      'draws': draws,
      'completed_matches_session': completedMatchesThisSession,
      'ai_difficulty': aiDifficulty,
    });
  }

  static TicTacToeTelemetryEvent adSdkInitialized({required bool usesTestAds}) {
    return TicTacToeTelemetryEvent('ad_sdk_initialized', {
      'uses_test_ads': usesTestAds,
    });
  }

  static TicTacToeTelemetryEvent adSdkInitializationFailed({
    required String errorCode,
    required bool usesTestAds,
  }) {
    return TicTacToeTelemetryEvent('ad_sdk_initialization_failed', {
      'error_code': errorCode,
      'uses_test_ads': usesTestAds,
    });
  }

  static TicTacToeTelemetryEvent adLoadStarted({
    required String placement,
    required String adFormat,
    required bool usesTestAds,
  }) {
    return TicTacToeTelemetryEvent('ad_load_started', {
      'placement': placement,
      'ad_format': adFormat,
      'uses_test_ads': usesTestAds,
    });
  }

  static TicTacToeTelemetryEvent adLoaded({
    required String placement,
    required String adFormat,
    required bool usesTestAds,
  }) {
    return TicTacToeTelemetryEvent('ad_loaded', {
      'placement': placement,
      'ad_format': adFormat,
      'uses_test_ads': usesTestAds,
    });
  }

  static TicTacToeTelemetryEvent adLoadFailed({
    required String placement,
    required String adFormat,
    required int errorCode,
    required bool usesTestAds,
  }) {
    return TicTacToeTelemetryEvent('ad_load_failed', {
      'placement': placement,
      'ad_format': adFormat,
      'error_code': errorCode,
      'uses_test_ads': usesTestAds,
    });
  }

  static TicTacToeTelemetryEvent adSkipped({
    required String placement,
    required String adFormat,
    required String reason,
    required bool usesTestAds,
  }) {
    return TicTacToeTelemetryEvent('ad_skipped', {
      'placement': placement,
      'ad_format': adFormat,
      'reason': reason,
      'uses_test_ads': usesTestAds,
    });
  }

  static TicTacToeTelemetryEvent adShowAttempted({
    required String placement,
    required String adFormat,
    required bool usesTestAds,
  }) {
    return TicTacToeTelemetryEvent('ad_show_attempted', {
      'placement': placement,
      'ad_format': adFormat,
      'uses_test_ads': usesTestAds,
    });
  }

  static TicTacToeTelemetryEvent adShown({
    required String placement,
    required String adFormat,
    required bool usesTestAds,
  }) {
    return TicTacToeTelemetryEvent('ad_shown', {
      'placement': placement,
      'ad_format': adFormat,
      'uses_test_ads': usesTestAds,
    });
  }

  static TicTacToeTelemetryEvent adDismissed({
    required String placement,
    required String adFormat,
    required bool usesTestAds,
  }) {
    return TicTacToeTelemetryEvent('ad_dismissed', {
      'placement': placement,
      'ad_format': adFormat,
      'uses_test_ads': usesTestAds,
    });
  }

  static TicTacToeTelemetryEvent adShowFailed({
    required String placement,
    required String adFormat,
    required String errorCode,
    required bool usesTestAds,
  }) {
    return TicTacToeTelemetryEvent('ad_show_failed', {
      'placement': placement,
      'ad_format': adFormat,
      'error_code': errorCode,
      'uses_test_ads': usesTestAds,
    });
  }
}
