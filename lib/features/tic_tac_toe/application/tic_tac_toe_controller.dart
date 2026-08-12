import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../ai/tic_tac_toe_ai_strategy.dart';
import '../data/tic_tac_toe_match_history_store.dart';
import '../data/tic_tac_toe_settings_store.dart';
import '../domain/game_score.dart';
import '../domain/match_format.dart';
import '../domain/match_record.dart';
import '../domain/round_outcome.dart';
import '../domain/tic_tac_toe_engine.dart';
import '../domain/tic_tac_toe_mark.dart';
import '../domain/tic_tac_toe_round.dart';
import 'game_mode.dart';
import 'tic_tac_toe_ad_service.dart';
import 'tic_tac_toe_settings.dart';
import 'tic_tac_toe_telemetry.dart';

enum TicTacToeScreen { setup, playing, settings, help }

class TicTacToeController extends ChangeNotifier {
  TicTacToeController({
    required this.engine,
    required this.aiStrategy,
    required this.settingsStore,
    required this.matchHistoryStore,
    required TicTacToeSettings initialSettings,
    List<MatchRecord> initialRecentMatches = const [],
    this.telemetry = const NoOpTicTacToeTelemetry(),
    this.adService = const NoOpTicTacToeAdService(),
    this.enableFeedback = true,
    this.aiDelay = const Duration(milliseconds: 520),
  }) : _settings = initialSettings,
       _recentMatches = _trimHistory(initialRecentMatches) {
    telemetry.track(TicTacToeTelemetryEvents.appOpened());
  }

  static const maxRecentMatches = 10;
  static const humanMark = TicTacToeMark.x;
  static const aiMark = TicTacToeMark.o;

  final TicTacToeEngine engine;
  final TicTacToeAiStrategy aiStrategy;
  final TicTacToeSettingsStore settingsStore;
  final TicTacToeMatchHistoryStore matchHistoryStore;
  final TicTacToeTelemetry telemetry;
  final TicTacToeAdService adService;
  final bool enableFeedback;
  final Duration aiDelay;

  TicTacToeScreen _screen = TicTacToeScreen.setup;
  TicTacToeScreen _settingsReturnScreen = TicTacToeScreen.setup;
  TicTacToeScreen _helpReturnScreen = TicTacToeScreen.setup;
  TicTacToeSettings _settings;
  GameMode _mode = GameMode.localTwoPlayer;
  MatchFormat _matchFormat = MatchFormat.singleRound;
  GameScore _score = const GameScore.zero();
  List<MatchRecord> _recentMatches;
  TicTacToeMark _startingMark = TicTacToeMark.x;
  TicTacToeRound _round = TicTacToeRound.fresh();
  bool _isAiThinking = false;
  bool _isDisposed = false;
  bool _isMatchComplete = false;
  int? _lastMoveIndex;
  int? _lastInvalidIndex;
  var _invalidTapSequence = 0;
  var _completedMatchesThisSession = 0;
  Timer? _aiTimer;

  TicTacToeScreen get screen => _screen;

  TicTacToeSettings get settings => _settings;

  bool get soundEnabled => _settings.soundEnabled;

  bool get hapticsEnabled => _settings.hapticsEnabled;

  GameMode get mode => _mode;

  MatchFormat get matchFormat => _matchFormat;

  GameScore get score => _score;

  bool get isMatchComplete => _isMatchComplete;

  TicTacToeMark? get matchWinner {
    if (!_isMatchComplete) {
      return null;
    }
    if (_score.xWins >= _matchFormat.targetWins) {
      return TicTacToeMark.x;
    }
    if (_score.oWins >= _matchFormat.targetWins) {
      return TicTacToeMark.o;
    }

    return null;
  }

  List<MatchRecord> get recentMatches => List.unmodifiable(_recentMatches);

  TicTacToeRound get round => _round;

  bool get isAiThinking => _isAiThinking;

  int? get lastMoveIndex => _lastMoveIndex;

  int? get lastInvalidIndex => _lastInvalidIndex;

  int get invalidTapSequence => _invalidTapSequence;

  bool get isHumanTurn {
    return _mode == GameMode.localTwoPlayer || _round.currentMark == humanMark;
  }

  void selectMode(GameMode mode) {
    if (_mode == mode) {
      return;
    }

    _mode = mode;
    _resetCurrentMatch();
    telemetry.track(
      TicTacToeTelemetryEvents.modeSelected(mode: _mode.analyticsName),
    );
    notifyListeners();
  }

  void selectMatchFormat(MatchFormat format) {
    if (_matchFormat == format) {
      return;
    }

    _matchFormat = format;
    _resetCurrentMatch();
    telemetry.track(
      TicTacToeTelemetryEvents.matchFormatSelected(
        matchFormat: _matchFormat.analyticsName,
      ),
    );
    notifyListeners();
  }

  void startGame() {
    _screen = TicTacToeScreen.playing;
    _trackRoundStarted();
    notifyListeners();
    _queueAiMoveIfNeeded();
  }

  void changeMode() {
    _screen = TicTacToeScreen.setup;
    _resetCurrentMatch();
    notifyListeners();
  }

  void showSettings() {
    _settingsReturnScreen = _screen;
    _screen = TicTacToeScreen.settings;
    notifyListeners();
  }

  void closeSettings() {
    _screen = _settingsReturnScreen;
    notifyListeners();
  }

  void showHelp() {
    _helpReturnScreen = _screen;
    _screen = TicTacToeScreen.help;
    notifyListeners();
  }

  void closeHelp() {
    _screen = _helpReturnScreen;
    notifyListeners();
  }

  bool canTapCell(int cellIndex) {
    return _screen == TicTacToeScreen.playing &&
        !_isAiThinking &&
        isHumanTurn &&
        engine.canPlay(_round, cellIndex);
  }

  void tapCell(int cellIndex) {
    _lastInvalidIndex = null;

    if (_screen != TicTacToeScreen.playing ||
        _isAiThinking ||
        !isHumanTurn ||
        _round.isOver) {
      return;
    }

    if (!engine.canPlay(_round, cellIndex)) {
      _lastInvalidIndex = cellIndex;
      _invalidTapSequence++;
      _playInvalidFeedback();
      telemetry.track(
        TicTacToeTelemetryEvents.invalidCellTapped(
          mode: _mode.analyticsName,
          matchFormat: _matchFormat.analyticsName,
          cellIndex: cellIndex,
        ),
      );
      notifyListeners();
      return;
    }

    _applyMove(cellIndex, playerType: 'human');
    _queueAiMoveIfNeeded();
  }

  void restartRound() {
    _cancelAiMove();
    final completedMatch = _isMatchComplete;
    telemetry.track(
      TicTacToeTelemetryEvents.rematchTapped(mode: _mode.analyticsName),
    );

    if (_round.isOver) {
      _startingMark = _startingMark.opponent;
    }

    if (completedMatch) {
      _score = const GameScore.zero();
      _isMatchComplete = false;
    }

    _round = TicTacToeRound.fresh(startingMark: _startingMark);
    _clearTransientState();
    _trackRoundStarted();
    notifyListeners();
    _queueAiMoveIfNeeded();
  }

  void resetScore() {
    _score = const GameScore.zero();
    _isMatchComplete = false;
    telemetry.track(
      TicTacToeTelemetryEvents.scoreReset(mode: _mode.analyticsName),
    );
    notifyListeners();
  }

  void toggleSound(bool enabled) {
    _settings = _settings.copyWith(soundEnabled: enabled);
    _saveSettings();
    telemetry.track(
      TicTacToeTelemetryEvents.settingsChanged(
        settingName: 'sound',
        enabled: enabled,
      ),
    );
    notifyListeners();
  }

  void toggleHaptics(bool enabled) {
    _settings = _settings.copyWith(hapticsEnabled: enabled);
    _saveSettings();
    telemetry.track(
      TicTacToeTelemetryEvents.settingsChanged(
        settingName: 'haptics',
        enabled: enabled,
      ),
    );
    notifyListeners();
  }

  void _queueAiMoveIfNeeded() {
    if (_mode != GameMode.vsAi ||
        _round.isOver ||
        _round.currentMark != aiMark ||
        _screen != TicTacToeScreen.playing) {
      return;
    }

    _isAiThinking = true;
    notifyListeners();

    if (aiDelay == Duration.zero) {
      _performAiMove();
      return;
    }

    _aiTimer = Timer(aiDelay, _performAiMove);
  }

  void _performAiMove() {
    if (_isDisposed) {
      return;
    }

    if (_mode != GameMode.vsAi ||
        _round.isOver ||
        _round.currentMark != aiMark ||
        _screen != TicTacToeScreen.playing) {
      _isAiThinking = false;
      notifyListeners();
      return;
    }

    final move = aiStrategy.chooseMove(_round.board, aiMark);
    if (move == null) {
      _isAiThinking = false;
      notifyListeners();
      return;
    }

    _isAiThinking = false;
    _applyMove(move, playerType: 'ai');
  }

  void _applyMove(int cellIndex, {required String playerType}) {
    final mark = _round.currentMark;
    final nextRound = engine.playMove(_round, cellIndex);
    if (nextRound.board == _round.board) {
      return;
    }

    _round = nextRound;
    _lastMoveIndex = cellIndex;
    _lastInvalidIndex = null;
    _playMoveFeedback(includeHaptics: playerType == 'human');
    telemetry.track(
      TicTacToeTelemetryEvents.moveMade(
        mode: _mode.analyticsName,
        matchFormat: _matchFormat.analyticsName,
        moveIndex: _round.moveCount,
        cellIndex: cellIndex,
        playerType: playerType,
        mark: mark.symbol,
      ),
    );

    if (_round.outcome.isOver) {
      _score = _score.record(_round.outcome);
      _isMatchComplete = _didCompleteMatch(_round.outcome);
      if (_isMatchComplete) {
        _completedMatchesThisSession++;
        _recordCompletedMatch(_round.outcome);
        telemetry.track(
          TicTacToeTelemetryEvents.matchCompleted(
            mode: _mode.analyticsName,
            matchFormat: _matchFormat.analyticsName,
            result: _round.outcome.status.name,
            winnerType: _winnerType(_round.outcome),
            roundsPlayed: _score.totalRounds,
            xWins: _score.xWins,
            oWins: _score.oWins,
            draws: _score.draws,
            completedMatchesThisSession: _completedMatchesThisSession,
            aiDifficulty: _aiDifficultyName,
          ),
        );
      }
      telemetry.track(
        TicTacToeTelemetryEvents.roundEnded(
          mode: _mode.analyticsName,
          matchFormat: _matchFormat.analyticsName,
          roundNumber: _score.totalRounds,
          result: _round.outcome.status.name,
          winnerType: _winnerType(_round.outcome),
          moveCount: _round.moveCount,
          aiDifficulty: _aiDifficultyName,
        ),
      );
    }

    notifyListeners();

    if (_isMatchComplete) {
      _queuePostMatchAd();
    }
  }

  String _winnerType(RoundOutcome outcome) {
    if (outcome.status == RoundStatus.draw) {
      return 'none';
    }
    if (_mode == GameMode.vsAi && outcome.winner == aiMark) {
      return 'ai';
    }
    if (_mode == GameMode.vsAi && outcome.winner == humanMark) {
      return 'human';
    }

    return outcome.winner?.symbol ?? 'none';
  }

  void _trackRoundStarted() {
    telemetry.track(
      TicTacToeTelemetryEvents.roundStarted(
        mode: _mode.analyticsName,
        matchFormat: _matchFormat.analyticsName,
        roundNumber: _score.totalRounds + 1,
        startingPlayer: _startingMark.symbol,
        aiDifficulty: _aiDifficultyName,
      ),
    );
  }

  String get _aiDifficultyName {
    return _mode == GameMode.vsAi ? 'balanced' : 'none';
  }

  void _queuePostMatchAd() {
    unawaited(
      adService
          .onMatchCompleted(
            completedMatchesThisSession: _completedMatchesThisSession,
            canShowNow: _canShowPostMatchAdNow,
          )
          .catchError((Object error, StackTrace stackTrace) {
            if (kDebugMode) {
              debugPrint('Failed to handle post-match ad: $error');
            }
          }),
    );
  }

  bool _canShowPostMatchAdNow() {
    return !_isDisposed &&
        _screen == TicTacToeScreen.playing &&
        _round.isOver &&
        _isMatchComplete &&
        !_isAiThinking;
  }

  bool _didCompleteMatch(RoundOutcome outcome) {
    if (!outcome.isOver) {
      return false;
    }
    if (_matchFormat == MatchFormat.singleRound) {
      return true;
    }
    final winner = outcome.winner;
    if (winner == null) {
      return false;
    }

    return _score.winsFor(winner) >= _matchFormat.targetWins;
  }

  void _recordCompletedMatch(RoundOutcome outcome) {
    final record = MatchRecord(
      completedAt: DateTime.now(),
      modeName: _mode.analyticsName,
      modeLabel: _mode.label,
      format: _matchFormat,
      score: _score,
      winner: outcome.winner,
    );
    _recentMatches = _trimHistory([record, ..._recentMatches]);
    unawaited(
      matchHistoryStore.saveRecentMatches(_recentMatches).catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        if (kDebugMode) {
          debugPrint('Failed to save tic tac toe match history: $error');
        }
      }),
    );
  }

  void _resetCurrentMatch() {
    _cancelAiMove();
    _score = const GameScore.zero();
    _startingMark = TicTacToeMark.x;
    _round = TicTacToeRound.fresh(startingMark: _startingMark);
    _isMatchComplete = false;
    _clearTransientState();
  }

  static List<MatchRecord> _trimHistory(List<MatchRecord> records) {
    return records.take(maxRecentMatches).toList(growable: false);
  }

  void _clearTransientState() {
    _isAiThinking = false;
    _lastMoveIndex = null;
    _lastInvalidIndex = null;
  }

  void _cancelAiMove() {
    _aiTimer?.cancel();
    _aiTimer = null;
    _isAiThinking = false;
  }

  void _saveSettings() {
    unawaited(
      settingsStore.save(_settings).catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        if (kDebugMode) {
          debugPrint('Failed to save tic tac toe settings: $error');
        }
      }),
    );
  }

  void _playMoveFeedback({required bool includeHaptics}) {
    if (!enableFeedback) {
      return;
    }

    if (includeHaptics && _settings.hapticsEnabled) {
      unawaited(HapticFeedback.selectionClick());
    }
    if (_settings.soundEnabled) {
      unawaited(SystemSound.play(SystemSoundType.click));
    }
  }

  void _playInvalidFeedback() {
    if (!enableFeedback) {
      return;
    }

    if (_settings.hapticsEnabled) {
      unawaited(HapticFeedback.mediumImpact());
    }
    if (_settings.soundEnabled) {
      unawaited(SystemSound.play(SystemSoundType.click));
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cancelAiMove();
    adService.dispose();
    super.dispose();
  }
}
