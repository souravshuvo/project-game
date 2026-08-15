import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/water_progress_store.dart';
import '../domain/level_score.dart';
import '../domain/pour_move.dart';
import '../domain/pour_result.dart';
import '../domain/water_board.dart';
import '../domain/water_lab_goal.dart';
import '../domain/water_level.dart';
import '../domain/water_player_progress.dart';
import '../domain/water_sort_engine.dart';
import '../domain/weather_essence.dart';
import 'game_telemetry.dart';
import 'game_ad_service.dart';

enum WaterSortScreen { home, levelSelect, settings, playing, complete }

enum WaterActionFeedback {
  idle,
  sourceSelected,
  sourceCleared,
  pour,
  invalid,
  undo,
  restart,
  complete,
}

class WaterSortController extends ChangeNotifier {
  WaterSortController({
    required this.engine,
    required this.levels,
    required this.progressStore,
    required WaterPlayerProgress initialProgress,
    this.enableFeedback = true,
    this.telemetry = const NoOpGameTelemetry(),
    this.adService = const NoOpGameAdService(),
    DateTime Function()? now,
  }) : _progress = initialProgress.normalized(levels.length),
       _now = now ?? DateTime.now {
    if (levels.isEmpty) {
      throw ArgumentError.value(
        levels,
        'levels',
        'Weather Lab Sort requires at least one level.',
      );
    }
    telemetry.track(GameTelemetryEvents.appOpen(totalLevels: levels.length));
    _levelIndex = _progress.currentLevelIndex;
    _loadLevel();
    _trackScreenView();
  }

  final WaterSortEngine engine;
  final List<WaterLevel> levels;
  final WaterProgressStore progressStore;
  final bool enableFeedback;
  final GameTelemetry telemetry;
  final GameAdService adService;
  final DateTime Function() _now;

  late WaterBoard _board;
  late DateTime _attemptStartedAt;
  WaterPlayerProgress _progress;
  WaterSortScreen _screen = WaterSortScreen.home;
  late int _levelIndex;
  int _moveCount = 0;
  int _feedbackToken = 0;
  int _moveFeedbackToken = 0;
  int _actionFeedbackToken = 0;
  int _flowStreak = 0;
  int _bestFlowStreak = 0;
  int? _selectedTubeIndex;
  int? _invalidTubeIndex;
  PourMove? _lastValidMove;
  _PendingPour? _pendingPour;
  PourInvalidReason? _lastInvalidReason;
  WaterActionFeedback _lastActionFeedback = WaterActionFeedback.idle;
  bool _isCompletionPending = false;
  bool _isContinuingAfterComplete = false;
  bool _lastCompletionWasFirstClear = false;
  bool _lastCompletionImprovedBestMoves = false;
  bool _lastCompletionImprovedStars = false;
  final _undoStack = <_WaterGameSnapshot>[];

  WaterSortScreen get screen => _screen;

  WaterLevel get currentLevel => levels[_levelIndex];

  WaterBoard get board => _board;

  List<WaterLevel> get allLevels => levels;

  int get currentLevelNumber => _levelIndex + 1;

  int get resumeLevelNumber => _progress.currentLevelIndex + 1;

  int get totalLevels => levels.length;

  int get moveCount => _moveCount;

  int get maxStarCount => totalLevels * 3;

  int get movesLeftForThreeStars => max(currentLevel.parMoves - _moveCount, 0);

  bool get isOnThreeStarPace => _moveCount <= currentLevel.parMoves;

  int get flowStreak => _flowStreak;

  int get bestFlowStreak => _bestFlowStreak;

  int get feedbackToken => _feedbackToken;

  int get moveFeedbackToken => _moveFeedbackToken;

  int get actionFeedbackToken => _actionFeedbackToken;

  int? get selectedTubeIndex => _selectedTubeIndex;

  /// Landing vessels that can accept the currently selected source.
  ///
  /// This stays in the controller so the UI only renders guidance and cannot
  /// drift away from the puzzle engine's move rules.
  Set<int> get validTargetIndexes {
    final sourceIndex = _selectedTubeIndex;
    if (sourceIndex == null) {
      return const <int>{};
    }

    return {
      for (
        var destinationIndex = 0;
        destinationIndex < _board.tubeCount;
        destinationIndex++
      )
        if (destinationIndex != sourceIndex &&
            engine.canPour(
              _board,
              PourMove(
                sourceIndex: sourceIndex,
                destinationIndex: destinationIndex,
              ),
            ))
          destinationIndex,
    };
  }

  int? get invalidTubeIndex => _invalidTubeIndex;

  PourMove? get lastValidMove => _lastValidMove;

  bool get isPourPending => _pendingPour != null;

  WeatherEssence? get pendingPourEssence => _pendingPour?.result.essence;

  int get pendingPourLayerCount => _pendingPour?.result.layersMoved ?? 0;

  PourInvalidReason? get lastInvalidReason => _lastInvalidReason;

  WaterActionFeedback get lastActionFeedback => _lastActionFeedback;

  bool get isContinuingAfterComplete => _isContinuingAfterComplete;

  bool get lastCompletionWasFirstClear => _lastCompletionWasFirstClear;

  bool get lastCompletionImprovedBestMoves => _lastCompletionImprovedBestMoves;

  bool get lastCompletionImprovedStars => _lastCompletionImprovedStars;

  /// The winning board is held briefly so the final pour can land before the
  /// result screen replaces it.
  bool get isCompletionPending => _isCompletionPending;

  bool get canUndo => _undoStack.isNotEmpty;

  bool get soundEnabled => _progress.soundEnabled;

  bool get hapticsEnabled => _progress.hapticsEnabled;

  int get completedLevelCount => _progress.completedLevelIds.length;

  int get earnedStarCount {
    return _progress.bestStarsByLevel.values.fold(
      0,
      (sum, stars) => sum + stars,
    );
  }

  List<WaterLabGoal> get labGoals {
    return WaterLabGoals.evaluate(levels: levels, progress: _progress);
  }

  int get completedLabGoalCount {
    return labGoals.where((goal) => goal.isComplete).length;
  }

  int get unlockedLevelCount => _progress.unlockedLevelIndex + 1;

  bool get isLastLevel => _levelIndex == levels.length - 1;

  int? get currentLevelBestMoves => _progress.bestMovesByLevel[currentLevel.id];

  int? get currentLevelBestStars => _progress.bestStarsByLevel[currentLevel.id];

  int get starsForCurrentAttempt {
    return LevelScore.starsForMoves(
      moves: _moveCount,
      parMoves: currentLevel.parMoves,
    );
  }

  bool isLevelUnlocked(int index) {
    return index >= 0 &&
        index < levels.length &&
        index <= _progress.unlockedLevelIndex;
  }

  bool isLevelComplete(int levelId) {
    return _progress.completedLevelIds.contains(levelId);
  }

  int? bestMovesForLevel(int levelId) {
    return _progress.bestMovesByLevel[levelId];
  }

  int? bestStarsForLevel(int levelId) {
    return _progress.bestStarsByLevel[levelId];
  }

  void play() {
    _levelIndex = _progress.currentLevelIndex;
    _loadLevel();
    _screen = WaterSortScreen.playing;
    _trackLevelStart(source: 'continue');
    _trackScreenView();
    notifyListeners();
  }

  void showLevelSelect() {
    _screen = WaterSortScreen.levelSelect;
    _trackScreenView();
    notifyListeners();
  }

  void showSettings() {
    _screen = WaterSortScreen.settings;
    _trackScreenView();
    notifyListeners();
  }

  void backHome() {
    if (_screen == WaterSortScreen.playing && _moveCount > 0) {
      telemetry.track(
        GameTelemetryEvents.levelExit(
          levelId: currentLevel.id,
          levelNumber: currentLevelNumber,
          moves: _moveCount,
          durationSeconds: _now().difference(_attemptStartedAt).inSeconds,
          reason: 'home',
        ),
      );
    }
    _levelIndex = _progress.currentLevelIndex;
    _loadLevel();
    _screen = WaterSortScreen.home;
    _trackScreenView();
    notifyListeners();
  }

  void selectLevel(int index, {String source = 'level_select'}) {
    if (!isLevelUnlocked(index)) {
      return;
    }

    _levelIndex = index;
    _loadLevel();
    _screen = WaterSortScreen.playing;
    _trackLevelStart(source: source);
    _trackScreenView();
    notifyListeners();
  }

  void nextLevel() {
    if (!isLastLevel) {
      _levelIndex = min(_levelIndex + 1, _progress.unlockedLevelIndex);
    }
    _loadLevel();
    _screen = WaterSortScreen.playing;
    _trackLevelStart(source: 'next_level');
    _trackScreenView();
    notifyListeners();
  }

  void toggleSound(bool value) {
    _progress = _progress.copyWith(soundEnabled: value);
    telemetry.track(
      GameTelemetryEvents.settingsChanged(
        settingName: 'sound_enabled',
        value: value,
      ),
    );
    _saveProgress();
    notifyListeners();
  }

  void toggleHaptics(bool value) {
    _progress = _progress.copyWith(hapticsEnabled: value);
    telemetry.track(
      GameTelemetryEvents.settingsChanged(
        settingName: 'haptics_enabled',
        value: value,
      ),
    );
    _saveProgress();
    notifyListeners();
  }

  void tapTube(int tubeIndex) {
    if (_screen != WaterSortScreen.playing ||
        _pendingPour != null ||
        !board.containsTube(tubeIndex)) {
      return;
    }

    _clearInvalidFeedback();

    final selectedTubeIndex = _selectedTubeIndex;
    if (selectedTubeIndex == null) {
      if (board.tubeAt(tubeIndex).isEmpty) {
        _showInvalidFeedback(
          tubeIndex: tubeIndex,
          reason: PourInvalidReason.sourceEmpty,
        );
        _trackInvalid(PourInvalidReason.sourceEmpty);
        notifyListeners();
        return;
      }

      _selectedTubeIndex = tubeIndex;
      _lastValidMove = null;
      _showActionFeedback(WaterActionFeedback.sourceSelected);
      _playTapFeedback();
      notifyListeners();
      return;
    }

    if (selectedTubeIndex == tubeIndex) {
      _selectedTubeIndex = null;
      _lastValidMove = null;
      _showActionFeedback(WaterActionFeedback.sourceCleared);
      _playTapFeedback();
      notifyListeners();
      return;
    }

    final move = PourMove(
      sourceIndex: selectedTubeIndex,
      destinationIndex: tubeIndex,
    );
    final result = engine.pour(_board, move);

    if (!result.isValid) {
      final reason = result.invalidReason ?? PourInvalidReason.noTransfer;
      // An attempted landing is a complete gesture. Do not leave the source
      // visually or logically latched after a rejected target.
      _selectedTubeIndex = null;
      _lastValidMove = null;
      _showInvalidFeedback(tubeIndex: tubeIndex, reason: reason);
      _trackInvalid(reason);
      notifyListeners();
      return;
    }

    _pendingPour = _PendingPour(
      boardBeforePour: _board,
      move: move,
      result: result,
    );
    _selectedTubeIndex = null;
    _lastValidMove = move;
    _moveFeedbackToken++;
    _showActionFeedback(WaterActionFeedback.pour);
    _playPourFeedback();
    notifyListeners();
  }

  void finishPourAnimation() {
    final pendingPour = _pendingPour;
    if (_screen != WaterSortScreen.playing || pendingPour == null) {
      return;
    }

    _pendingPour = null;
    _undoStack.add(
      _WaterGameSnapshot(
        board: pendingPour.boardBeforePour,
        moveCount: _moveCount,
      ),
    );
    _board = pendingPour.result.board;
    _moveCount++;
    _flowStreak++;
    _bestFlowStreak = max(_bestFlowStreak, _flowStreak);
    telemetry.track(
      GameTelemetryEvents.pourValid(
        levelId: currentLevel.id,
        levelNumber: currentLevelNumber,
        sourceIndex: pendingPour.move.sourceIndex,
        destinationIndex: pendingPour.move.destinationIndex,
        layersMoved: pendingPour.result.layersMoved,
        moveCountAfter: _moveCount,
      ),
    );

    if (engine.isSolved(_board)) {
      _recordCompletion();
      _isCompletionPending = true;
      _showActionFeedback(WaterActionFeedback.complete);
      _playWinFeedback();
      adService.preloadLevelEndInterstitial();
    }

    notifyListeners();
  }

  void undo() {
    if (_screen != WaterSortScreen.playing ||
        _pendingPour != null ||
        _isCompletionPending ||
        !canUndo) {
      _showInvalidFeedback(
        tubeIndex: _selectedTubeIndex,
        reason: PourInvalidReason.noTransfer,
      );
      notifyListeners();
      return;
    }

    final snapshot = _undoStack.removeLast();
    _board = snapshot.board;
    _moveCount = snapshot.moveCount;
    _flowStreak = 0;
    _selectedTubeIndex = null;
    _lastValidMove = null;
    _pendingPour = null;
    _clearInvalidFeedback();
    _screen = WaterSortScreen.playing;
    _showActionFeedback(WaterActionFeedback.undo);
    _playUndoFeedback();
    telemetry.track(
      GameTelemetryEvents.undoUsed(
        levelId: currentLevel.id,
        levelNumber: currentLevelNumber,
        moveCountAfter: _moveCount,
      ),
    );
    notifyListeners();
  }

  void restartLevel() {
    telemetry.track(
      GameTelemetryEvents.levelRestart(
        levelId: currentLevel.id,
        levelNumber: currentLevelNumber,
        movesBeforeRestart: _moveCount,
        durationSeconds: _now().difference(_attemptStartedAt).inSeconds,
      ),
    );
    _loadLevel();
    _screen = WaterSortScreen.playing;
    _showActionFeedback(WaterActionFeedback.restart);
    _playRestartFeedback();
    _trackLevelStart(source: 'restart');
    notifyListeners();
  }

  void finishCompletionAnimation() {
    if (_screen != WaterSortScreen.playing || !_isCompletionPending) {
      return;
    }

    _isCompletionPending = false;
    _screen = WaterSortScreen.complete;
    _trackScreenView();
    notifyListeners();
  }

  Future<void> continueToNextLevel() async {
    if (_screen != WaterSortScreen.complete || _isContinuingAfterComplete) {
      return;
    }
    if (isLastLevel) {
      backHome();
      return;
    }

    _isContinuingAfterComplete = true;
    notifyListeners();
    try {
      await adService.maybeShowLevelEndInterstitial(
        levelId: currentLevel.id,
        levelNumber: currentLevelNumber,
      );
    } on Object {
      // Ad failures must never block the player's level progression.
    } finally {
      _isContinuingAfterComplete = false;
      if (_screen == WaterSortScreen.complete) {
        nextLevel();
      } else {
        notifyListeners();
      }
    }
  }

  void replayLevel() {
    _loadLevel();
    _screen = WaterSortScreen.playing;
    _trackLevelStart(source: 'replay');
    _trackScreenView();
    notifyListeners();
  }

  void _loadLevel() {
    _board = engine.parse(currentLevel);
    _attemptStartedAt = _now();
    _moveCount = 0;
    _flowStreak = 0;
    _bestFlowStreak = 0;
    _selectedTubeIndex = null;
    _invalidTubeIndex = null;
    _lastValidMove = null;
    _lastInvalidReason = null;
    _isCompletionPending = false;
    _isContinuingAfterComplete = false;
    _lastCompletionWasFirstClear = false;
    _lastCompletionImprovedBestMoves = false;
    _lastCompletionImprovedStars = false;
    _undoStack.clear();
  }

  void _recordCompletion() {
    final levelId = currentLevel.id;
    final wasAlreadyComplete = _progress.completedLevelIds.contains(levelId);
    final completedLevelIds = {..._progress.completedLevelIds, levelId};
    final bestMovesByLevel = Map<int, int>.of(_progress.bestMovesByLevel);
    final bestStarsByLevel = Map<int, int>.of(_progress.bestStarsByLevel);
    final stars = starsForCurrentAttempt;
    final previousBestMoves = bestMovesByLevel[levelId];
    final previousBestStars = bestStarsByLevel[levelId] ?? 0;
    final improvedBestMoves =
        previousBestMoves == null || _moveCount < previousBestMoves;
    final improvedStars = stars > previousBestStars;

    _lastCompletionWasFirstClear = !wasAlreadyComplete;
    _lastCompletionImprovedBestMoves = improvedBestMoves;
    _lastCompletionImprovedStars = improvedStars;

    if (improvedBestMoves) {
      bestMovesByLevel[levelId] = _moveCount;
    }
    if (improvedStars) {
      bestStarsByLevel[levelId] = stars;
    }

    final lastLevelIndex = levels.length - 1;
    final nextLevelIndex = min(_levelIndex + 1, lastLevelIndex);
    _progress = _progress.copyWith(
      currentLevelIndex: max(_progress.currentLevelIndex, nextLevelIndex),
      unlockedLevelIndex: max(_progress.unlockedLevelIndex, nextLevelIndex),
      completedLevelIds: completedLevelIds,
      bestMovesByLevel: bestMovesByLevel,
      bestStarsByLevel: bestStarsByLevel,
    );

    _saveProgress();
    telemetry.track(
      GameTelemetryEvents.levelComplete(
        levelId: levelId,
        levelNumber: currentLevelNumber,
        moves: _moveCount,
        stars: stars,
        durationSeconds: _now().difference(_attemptStartedAt).inSeconds,
      ),
    );
  }

  void _showInvalidFeedback({
    required int? tubeIndex,
    required PourInvalidReason reason,
  }) {
    _invalidTubeIndex = tubeIndex;
    _flowStreak = 0;
    _lastValidMove = null;
    _lastInvalidReason = reason;
    _feedbackToken++;
    _showActionFeedback(WaterActionFeedback.invalid);
    _playInvalidFeedback();
  }

  void _clearInvalidFeedback() {
    _invalidTubeIndex = null;
    _lastInvalidReason = null;
  }

  void _trackInvalid(PourInvalidReason reason) {
    telemetry.track(
      GameTelemetryEvents.pourInvalid(
        levelId: currentLevel.id,
        levelNumber: currentLevelNumber,
        reason: reason.name,
      ),
    );
  }

  void _saveProgress() {
    unawaited(
      progressStore.save(_progress).catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        if (kDebugMode) {
          debugPrint('Failed to save water sort progress: $error');
        }
      }),
    );
  }

  void _showActionFeedback(WaterActionFeedback feedback) {
    _lastActionFeedback = feedback;
    _actionFeedbackToken++;
  }

  void _playTapFeedback() {
    if (!enableFeedback) {
      return;
    }

    if (_progress.hapticsEnabled) {
      unawaited(HapticFeedback.selectionClick());
    }
    if (_progress.soundEnabled) {
      unawaited(SystemSound.play(SystemSoundType.click));
    }
  }

  void _playPourFeedback() {
    if (!enableFeedback) {
      return;
    }

    if (_progress.hapticsEnabled) {
      unawaited(HapticFeedback.lightImpact());
    }
    if (_progress.soundEnabled) {
      unawaited(SystemSound.play(SystemSoundType.click));
    }
  }

  void _playInvalidFeedback() {
    if (!enableFeedback) {
      return;
    }

    if (_progress.hapticsEnabled) {
      unawaited(HapticFeedback.mediumImpact());
    }
    if (_progress.soundEnabled) {
      unawaited(SystemSound.play(SystemSoundType.alert));
    }
  }

  void _playUndoFeedback() {
    if (!enableFeedback) {
      return;
    }

    if (_progress.hapticsEnabled) {
      unawaited(HapticFeedback.selectionClick());
    }
    if (_progress.soundEnabled) {
      unawaited(SystemSound.play(SystemSoundType.click));
    }
  }

  void _playRestartFeedback() {
    if (!enableFeedback) {
      return;
    }

    if (_progress.hapticsEnabled) {
      unawaited(HapticFeedback.lightImpact());
    }
    if (_progress.soundEnabled) {
      unawaited(SystemSound.play(SystemSoundType.click));
    }
  }

  void _playWinFeedback() {
    if (!enableFeedback) {
      return;
    }

    if (_progress.hapticsEnabled) {
      unawaited(HapticFeedback.heavyImpact());
    }
    if (_progress.soundEnabled) {
      unawaited(SystemSound.play(SystemSoundType.alert));
    }
  }

  void _trackScreenView() {
    telemetry.track(GameTelemetryEvents.screenView(screen: _screen.name));
  }

  void _trackLevelStart({required String source}) {
    telemetry.track(
      GameTelemetryEvents.levelStart(
        levelId: currentLevel.id,
        levelNumber: currentLevelNumber,
        source: source,
      ),
    );
  }

  @override
  void dispose() {
    adService.dispose();
    super.dispose();
  }
}

class _WaterGameSnapshot {
  const _WaterGameSnapshot({required this.board, required this.moveCount});

  final WaterBoard board;
  final int moveCount;
}

class _PendingPour {
  const _PendingPour({
    required this.boardBeforePour,
    required this.move,
    required this.result,
  });

  final WaterBoard boardBeforePour;
  final PourMove move;
  final PourResult result;
}
