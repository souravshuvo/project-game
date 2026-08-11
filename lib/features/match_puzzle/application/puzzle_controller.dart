import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/local_progress_store.dart';
import '../domain/board_position.dart';
import '../domain/player_progress.dart';
import '../domain/puzzle_engine.dart';
import '../domain/puzzle_level.dart';
import '../domain/puzzle_state.dart';

class PuzzleController extends ChangeNotifier {
  PuzzleController({
    required this.engine,
    required this.levels,
    required this.progressStore,
    required PlayerProgress initialProgress,
  }) : _progress = initialProgress.normalized(levels.length) {
    _currentLevelIndex = _progress.currentLevelIndex;
    _state = engine.start(currentLevel);
  }

  final PuzzleEngine engine;
  final List<PuzzleLevel> levels;
  final MatchProgressStore progressStore;

  late PuzzleState _state;
  late int _currentLevelIndex;
  late PlayerProgress _progress;
  BoardPosition? _selectedPosition;
  BoardPosition? _lastInvalidPosition;
  String _message = 'Collect the signal tiles before moves run out.';

  PuzzleState get state => _state;

  PuzzleLevel get currentLevel => levels[_currentLevelIndex];

  int get currentLevelIndex => _currentLevelIndex;

  int get currentLevelNumber => _currentLevelIndex + 1;

  int get totalLevels => levels.length;

  int get unlockedLevelCount => _progress.unlockedLevelIndex + 1;

  bool get isLastLevel => _currentLevelIndex == levels.length - 1;

  bool get canGoNext => state.status == PuzzleStatus.won && !isLastLevel;

  BoardPosition? get selectedPosition => _selectedPosition;

  BoardPosition? get lastInvalidPosition => _lastInvalidPosition;

  String get message => _message;

  bool isLevelUnlocked(int index) => index <= _progress.unlockedLevelIndex;

  bool isLevelComplete(int levelId) =>
      _progress.completedLevelIds.contains(levelId);

  int? bestMovesLeftForLevel(int levelId) =>
      _progress.bestMovesLeftByLevel[levelId];

  void select(BoardPosition position) {
    if (_state.status != PuzzleStatus.playing) {
      return;
    }

    _lastInvalidPosition = null;
    final selected = _selectedPosition;
    if (selected == null || selected == position) {
      _selectedPosition = selected == position ? null : position;
      notifyListeners();
      return;
    }

    if (!selected.isAdjacentTo(position)) {
      _selectedPosition = position;
      notifyListeners();
      return;
    }

    final result = engine.makeMove(_state, selected, position);
    if (!result.accepted) {
      _lastInvalidPosition = position;
      _message = 'That swap needs to make a match.';
      notifyListeners();
      return;
    }

    _state = result.state;
    _selectedPosition = null;
    if (_state.status == PuzzleStatus.won) {
      _recordCompletion();
    }
    _message = switch (_state.status) {
      PuzzleStatus.won => 'Signal complete.',
      PuzzleStatus.lost => 'No moves left.',
      PuzzleStatus.playing =>
        result.shuffled
            ? 'Board reshuffled. Keep going.'
            : '${result.clearedTiles} tiles cleared.',
    };
    notifyListeners();
  }

  void nextLevel() {
    if (!canGoNext) {
      return;
    }

    _loadLevel(_currentLevelIndex + 1);
  }

  void selectLevel(int index) {
    if (index < 0 || index >= levels.length || !isLevelUnlocked(index)) {
      return;
    }

    _loadLevel(index);
  }

  void restart() {
    _state = engine.start(currentLevel);
    _selectedPosition = null;
    _lastInvalidPosition = null;
    _message = 'Collect the signal tiles before moves run out.';
    notifyListeners();
  }

  void _loadLevel(int index) {
    _currentLevelIndex = index;
    _progress = _progress.copyWith(currentLevelIndex: index);
    _state = engine.start(currentLevel);
    _selectedPosition = null;
    _lastInvalidPosition = null;
    _message = 'Collect the signal tiles before moves run out.';
    _saveProgress();
    notifyListeners();
  }

  void _recordCompletion() {
    _progress = _progress.recordCompletion(
      levelId: currentLevel.id,
      levelIndex: _currentLevelIndex,
      levelCount: levels.length,
      movesLeft: _state.movesLeft,
    );
    _saveProgress();
  }

  void _saveProgress() {
    unawaited(progressStore.save(_progress));
  }
}
