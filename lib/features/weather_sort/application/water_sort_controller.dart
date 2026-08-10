import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/water_progress_store.dart';
import '../domain/level_score.dart';
import '../domain/pour_move.dart';
import '../domain/pour_result.dart';
import '../domain/water_board.dart';
import '../domain/water_level.dart';
import '../domain/water_player_progress.dart';
import '../domain/water_sort_engine.dart';
import 'game_telemetry.dart';

enum WaterSortScreen { playing, complete }

class WaterSortController extends ChangeNotifier {
  WaterSortController({
    required this.engine,
    required this.levels,
    required this.progressStore,
    required WaterPlayerProgress initialProgress,
    this.enableFeedback = true,
    this.telemetry = const NoOpGameTelemetry(),
    DateTime Function()? now,
  }) : _progress = initialProgress,
       _now = now ?? DateTime.now {
    telemetry.track(GameTelemetryEvents.appOpen(totalLevels: levels.length));
    _loadLevel(source: 'launch');
    _trackScreenView();
  }

  final WaterSortEngine engine;
  final List<WaterLevel> levels;
  final WaterProgressStore progressStore;
  final bool enableFeedback;
  final GameTelemetry telemetry;
  final DateTime Function() _now;

  late WaterBoard _board;
  late DateTime _attemptStartedAt;
  WaterPlayerProgress _progress;
  WaterSortScreen _screen = WaterSortScreen.playing;
  final int _levelIndex = 0;
  int _moveCount = 0;
  int _feedbackToken = 0;
  int? _selectedTubeIndex;
  int? _invalidTubeIndex;
  PourInvalidReason? _lastInvalidReason;
  final _undoStack = <_WaterGameSnapshot>[];

  WaterSortScreen get screen => _screen;

  WaterLevel get currentLevel => levels[_levelIndex];

  WaterBoard get board => _board;

  int get currentLevelNumber => _levelIndex + 1;

  int get moveCount => _moveCount;

  int get feedbackToken => _feedbackToken;

  int? get selectedTubeIndex => _selectedTubeIndex;

  int? get invalidTubeIndex => _invalidTubeIndex;

  PourInvalidReason? get lastInvalidReason => _lastInvalidReason;

  bool get canUndo => _undoStack.isNotEmpty;

  bool get soundEnabled => _progress.soundEnabled;

  bool get hapticsEnabled => _progress.hapticsEnabled;

  int? get currentLevelBestMoves => _progress.bestMovesByLevel[currentLevel.id];

  int get starsForCurrentAttempt {
    return LevelScore.starsForMoves(
      moves: _moveCount,
      parMoves: currentLevel.parMoves,
    );
  }

  void tapTube(int tubeIndex) {
    if (_screen != WaterSortScreen.playing || !board.containsTube(tubeIndex)) {
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
      _playValidFeedback();
      notifyListeners();
      return;
    }

    if (selectedTubeIndex == tubeIndex) {
      _selectedTubeIndex = null;
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
      _showInvalidFeedback(tubeIndex: tubeIndex, reason: reason);
      _trackInvalid(reason);
      notifyListeners();
      return;
    }

    _undoStack.add(_WaterGameSnapshot(board: _board, moveCount: _moveCount));
    _board = result.board;
    _moveCount++;
    _selectedTubeIndex = null;
    _playValidFeedback();
    telemetry.track(
      GameTelemetryEvents.pourValid(
        levelId: currentLevel.id,
        sourceIndex: move.sourceIndex,
        destinationIndex: move.destinationIndex,
        layersMoved: result.layersMoved,
      ),
    );

    if (engine.isSolved(_board)) {
      _recordCompletion();
      _screen = WaterSortScreen.complete;
      _trackScreenView();
    }

    notifyListeners();
  }

  void undo() {
    if (!canUndo) {
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
    _selectedTubeIndex = null;
    _clearInvalidFeedback();
    _screen = WaterSortScreen.playing;
    _playValidFeedback();
    telemetry.track(
      GameTelemetryEvents.undoUsed(
        levelId: currentLevel.id,
        moveCountAfter: _moveCount,
      ),
    );
    notifyListeners();
  }

  void restartLevel() {
    telemetry.track(
      GameTelemetryEvents.levelRestart(
        levelId: currentLevel.id,
        movesBeforeRestart: _moveCount,
      ),
    );
    _loadLevel(source: 'restart');
    notifyListeners();
  }

  void replayLevel() {
    _loadLevel(source: 'replay');
    notifyListeners();
  }

  void _loadLevel({required String source}) {
    _board = engine.parse(currentLevel);
    _attemptStartedAt = _now();
    _moveCount = 0;
    _selectedTubeIndex = null;
    _invalidTubeIndex = null;
    _lastInvalidReason = null;
    _undoStack.clear();
    _screen = WaterSortScreen.playing;
    telemetry.track(
      GameTelemetryEvents.levelStart(
        levelId: currentLevel.id,
        levelNumber: currentLevelNumber,
        source: source,
      ),
    );
  }

  void _recordCompletion() {
    final levelId = currentLevel.id;
    final completedLevelIds = {..._progress.completedLevelIds, levelId};
    final bestMovesByLevel = Map<int, int>.of(_progress.bestMovesByLevel);
    final bestStarsByLevel = Map<int, int>.of(_progress.bestStarsByLevel);
    final stars = starsForCurrentAttempt;
    final previousBestMoves = bestMovesByLevel[levelId];
    final previousBestStars = bestStarsByLevel[levelId] ?? 0;

    if (previousBestMoves == null || _moveCount < previousBestMoves) {
      bestMovesByLevel[levelId] = _moveCount;
    }
    if (stars > previousBestStars) {
      bestStarsByLevel[levelId] = stars;
    }

    _progress = _progress.copyWith(
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
    _lastInvalidReason = reason;
    _feedbackToken++;
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

  void _playValidFeedback() {
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

  void _playInvalidFeedback() {
    if (!enableFeedback) {
      return;
    }

    if (_progress.hapticsEnabled) {
      unawaited(HapticFeedback.mediumImpact());
    }
    if (_progress.soundEnabled) {
      unawaited(SystemSound.play(SystemSoundType.click));
    }
  }

  void _trackScreenView() {
    telemetry.track(GameTelemetryEvents.screenView(screen: _screen.name));
  }
}

class _WaterGameSnapshot {
  const _WaterGameSnapshot({required this.board, required this.moveCount});

  final WaterBoard board;
  final int moveCount;
}
