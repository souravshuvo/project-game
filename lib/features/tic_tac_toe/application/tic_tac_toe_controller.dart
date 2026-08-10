import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../ai/tic_tac_toe_ai_strategy.dart';
import '../data/tic_tac_toe_settings_store.dart';
import '../domain/game_score.dart';
import '../domain/round_outcome.dart';
import '../domain/tic_tac_toe_engine.dart';
import '../domain/tic_tac_toe_mark.dart';
import '../domain/tic_tac_toe_round.dart';
import 'game_mode.dart';
import 'tic_tac_toe_settings.dart';
import 'tic_tac_toe_telemetry.dart';

enum TicTacToeScreen { setup, playing, settings }

class TicTacToeController extends ChangeNotifier {
  TicTacToeController({
    required this.engine,
    required this.aiStrategy,
    required this.settingsStore,
    required TicTacToeSettings initialSettings,
    this.telemetry = const NoOpTicTacToeTelemetry(),
    this.enableFeedback = true,
    this.aiDelay = const Duration(milliseconds: 520),
  }) : _settings = initialSettings {
    telemetry.track(TicTacToeTelemetryEvents.appOpened());
  }

  static const humanMark = TicTacToeMark.x;
  static const aiMark = TicTacToeMark.o;

  final TicTacToeEngine engine;
  final TicTacToeAiStrategy aiStrategy;
  final TicTacToeSettingsStore settingsStore;
  final TicTacToeTelemetry telemetry;
  final bool enableFeedback;
  final Duration aiDelay;

  TicTacToeScreen _screen = TicTacToeScreen.setup;
  TicTacToeScreen _returnScreen = TicTacToeScreen.setup;
  TicTacToeSettings _settings;
  GameMode _mode = GameMode.localTwoPlayer;
  GameScore _score = const GameScore.zero();
  TicTacToeMark _startingMark = TicTacToeMark.x;
  TicTacToeRound _round = TicTacToeRound.fresh();
  bool _isAiThinking = false;
  bool _isDisposed = false;
  int? _lastMoveIndex;
  int? _lastInvalidIndex;
  var _invalidTapSequence = 0;
  Timer? _aiTimer;

  TicTacToeScreen get screen => _screen;

  TicTacToeSettings get settings => _settings;

  bool get soundEnabled => _settings.soundEnabled;

  bool get hapticsEnabled => _settings.hapticsEnabled;

  GameMode get mode => _mode;

  GameScore get score => _score;

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
    _score = const GameScore.zero();
    _startingMark = TicTacToeMark.x;
    _round = TicTacToeRound.fresh(startingMark: _startingMark);
    _clearTransientState();
    telemetry.track(
      TicTacToeTelemetryEvents.modeSelected(mode: _mode.analyticsName),
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
    _cancelAiMove();
    _screen = TicTacToeScreen.setup;
    _startingMark = TicTacToeMark.x;
    _round = TicTacToeRound.fresh(startingMark: _startingMark);
    _clearTransientState();
    notifyListeners();
  }

  void showSettings() {
    _returnScreen = _screen;
    _screen = TicTacToeScreen.settings;
    notifyListeners();
  }

  void closeSettings() {
    _screen = _returnScreen;
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
    telemetry.track(
      TicTacToeTelemetryEvents.rematchTapped(mode: _mode.analyticsName),
    );

    if (_round.isOver) {
      _startingMark = _startingMark.opponent;
    }

    _round = TicTacToeRound.fresh(startingMark: _startingMark);
    _clearTransientState();
    _trackRoundStarted();
    notifyListeners();
    _queueAiMoveIfNeeded();
  }

  void resetScore() {
    _score = const GameScore.zero();
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
        moveIndex: _round.moveCount,
        cellIndex: cellIndex,
        playerType: playerType,
        mark: mark.symbol,
      ),
    );

    if (_round.outcome.isOver) {
      _score = _score.record(_round.outcome);
      telemetry.track(
        TicTacToeTelemetryEvents.roundEnded(
          mode: _mode.analyticsName,
          result: _round.outcome.status.name,
          winnerType: _winnerType(_round.outcome),
          moveCount: _round.moveCount,
        ),
      );
    }

    notifyListeners();
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
        startingPlayer: _startingMark.symbol,
      ),
    );
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
    super.dispose();
  }
}
