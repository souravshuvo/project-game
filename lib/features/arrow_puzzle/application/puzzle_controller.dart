import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/puzzle_progress_store.dart';
import '../domain/board_position.dart';
import '../domain/player_progress.dart';
import '../domain/puzzle_board.dart';
import '../domain/puzzle_cell.dart';
import '../domain/puzzle_engine.dart';
import '../domain/puzzle_level.dart';
import 'game_telemetry.dart';

enum PuzzleScreen { home, levelSelect, settings, playing, complete }

class PuzzleController extends ChangeNotifier {
  PuzzleController({
    required this.engine,
    required this.levels,
    required this.progressStore,
    required PlayerProgress initialProgress,
    this.enableFeedback = true,
    this.telemetry = const NoOpGameTelemetry(),
    DateTime Function()? now,
  }) : _progress = initialProgress.normalized(levels.length),
       _now = now ?? DateTime.now {
    _currentLevelIndex = _progress.currentLevelIndex;
    _loadCurrentLevel();
    telemetry.track(
      GameTelemetryEvents.appOpen(
        totalLevels: levels.length,
        unlockedLevelCount: unlockedLevelCount,
      ),
    );
    _trackScreenView();
  }

  final PuzzleEngine engine;
  final List<PuzzleLevel> levels;
  final PuzzleProgressStore progressStore;
  final bool enableFeedback;
  final GameTelemetry telemetry;
  final DateTime Function() _now;

  late PuzzleBoard _board;
  late PlayerProgress _progress;
  late int _currentLevelIndex;
  var _screen = PuzzleScreen.home;
  BoardPosition? _lastInvalidTap;
  BoardPosition? _lastRemovedPosition;
  BoardPosition? _hintedPosition;
  PuzzleCell? _lastRemovedCell;
  var _moveCount = 0;

  PuzzleScreen get screen => _screen;

  PuzzleLevel get currentLevel => levels[_currentLevelIndex];

  PuzzleBoard get board => _board;

  int get currentLevelNumber => _currentLevelIndex + 1;

  int get resumeLevelNumber => _progress.currentLevelIndex + 1;

  int get totalLevels => levels.length;

  int get moveCount => _moveCount;

  int get completedLevelCount => _progress.completedLevelIds.length;

  int get unlockedLevelCount => _progress.unlockedLevelIndex + 1;

  int get streakDays => _progress.streakDays;

  int get hintCount => _progress.hintCount;

  bool get soundEnabled => _progress.soundEnabled;

  bool get hapticsEnabled => _progress.hapticsEnabled;

  bool get canClaimDailyHint => _progress.lastHintClaimDate != _todayKey();

  bool get canUseHint => hintCount > 0 && validMoves.isNotEmpty;

  int? get currentLevelBestMoves => bestMovesForLevel(currentLevel.id);

  int get dailyChallengeLevelIndex {
    final unlockedCount = max(1, unlockedLevelCount);
    final today = DateTime(_now().year, _now().month, _now().day);
    final seedDay = DateTime(2026);

    return today.difference(seedDay).inDays % unlockedCount;
  }

  int get dailyChallengeLevelNumber => dailyChallengeLevelIndex + 1;

  PuzzleLevel get dailyChallengeLevel => levels[dailyChallengeLevelIndex];

  bool get isDailyGoalComplete => _progress.lastCompletionDate == _todayKey();

  BoardPosition? get lastInvalidTap => _lastInvalidTap;

  BoardPosition? get lastRemovedPosition => _lastRemovedPosition;

  BoardPosition? get hintedPosition => _hintedPosition;

  PuzzleCell? get lastRemovedCell => _lastRemovedCell;

  List<BoardPosition> get validMoves => engine.validMoves(_board);

  bool get isLastLevel => _currentLevelIndex == levels.length - 1;

  bool isLevelUnlocked(int index) => index <= _progress.unlockedLevelIndex;

  bool isLevelComplete(int levelId) =>
      _progress.completedLevelIds.contains(levelId);

  int? bestMovesForLevel(int levelId) => _progress.bestMovesByLevel[levelId];

  void play() {
    _currentLevelIndex = _progress.currentLevelIndex;
    _loadCurrentLevel();
    _screen = PuzzleScreen.playing;
    _trackLevelStart(source: 'continue');
    _trackScreenView();
    notifyListeners();
  }

  void backHome() {
    _currentLevelIndex = _progress.currentLevelIndex;
    _loadCurrentLevel();
    _screen = PuzzleScreen.home;
    _trackScreenView();
    notifyListeners();
  }

  void showLevelSelect() {
    _screen = PuzzleScreen.levelSelect;
    _trackScreenView();
    notifyListeners();
  }

  void showSettings() {
    _screen = PuzzleScreen.settings;
    _trackScreenView();
    notifyListeners();
  }

  void selectLevel(int index, {String source = 'level_select'}) {
    if (!isLevelUnlocked(index)) {
      return;
    }

    _currentLevelIndex = index;
    _loadCurrentLevel();
    _screen = PuzzleScreen.playing;
    _trackLevelStart(source: source);
    _trackScreenView();
    notifyListeners();
  }

  void startDailyChallenge() {
    selectLevel(dailyChallengeLevelIndex, source: 'daily_level');
  }

  void toggleSound(bool value) {
    _progress = _progress.copyWith(soundEnabled: value);
    telemetry.track(GameTelemetryEvents.settingsSoundToggle(enabled: value));
    _saveProgress();
    notifyListeners();
  }

  void toggleHaptics(bool value) {
    _progress = _progress.copyWith(hapticsEnabled: value);
    telemetry.track(GameTelemetryEvents.settingsHapticsToggle(enabled: value));
    _saveProgress();
    notifyListeners();
  }

  void claimDailyHint() {
    if (!canClaimDailyHint) {
      return;
    }

    _progress = _progress.copyWith(
      hintCount: min(_progress.hintCount + 1, 99),
      lastHintClaimDate: _todayKey(),
    );
    _playValidFeedback();
    telemetry.track(
      GameTelemetryEvents.hintClaim(hintBalance: _progress.hintCount),
    );
    _saveProgress();
    notifyListeners();
  }

  void useHint() {
    if (!canUseHint) {
      _playInvalidFeedback();
      return;
    }

    _hintedPosition = validMoves.first;
    _progress = _progress.copyWith(hintCount: _progress.hintCount - 1);
    _playValidFeedback();
    telemetry.track(
      GameTelemetryEvents.hintUse(
        levelId: currentLevel.id,
        levelNumber: currentLevelNumber,
        hintBalance: _progress.hintCount,
      ),
    );
    _saveProgress();
    notifyListeners();
  }

  void retryLevel() {
    telemetry.track(
      GameTelemetryEvents.levelRetry(
        levelId: currentLevel.id,
        levelNumber: currentLevelNumber,
        moveCount: _moveCount,
      ),
    );
    _loadCurrentLevel();
    _screen = PuzzleScreen.playing;
    _trackLevelStart(source: 'retry');
    _trackScreenView();
    notifyListeners();
  }

  void nextLevel() {
    if (!isLastLevel) {
      _currentLevelIndex = min(
        _currentLevelIndex + 1,
        _progress.unlockedLevelIndex,
      );
    }
    _loadCurrentLevel();
    _screen = PuzzleScreen.playing;
    _trackLevelStart(source: 'next_level');
    _trackScreenView();
    notifyListeners();
  }

  void tap(BoardPosition position) {
    _lastInvalidTap = null;
    _lastRemovedPosition = null;
    _lastRemovedCell = null;

    if (!engine.canRemove(_board, position)) {
      _lastInvalidTap = position;
      _playInvalidFeedback();
      notifyListeners();
      return;
    }

    _playValidFeedback();
    _lastRemovedPosition = position;
    _lastRemovedCell = _board.cellAt(position);
    _hintedPosition = null;
    _board = engine.remove(_board, position);
    _moveCount++;

    if (_board.isCleared) {
      _recordCompletion();
      _screen = PuzzleScreen.complete;
      _trackScreenView();
    }

    notifyListeners();
  }

  void _loadCurrentLevel() {
    _board = engine.parse(currentLevel);
    _lastInvalidTap = null;
    _lastRemovedPosition = null;
    _hintedPosition = null;
    _lastRemovedCell = null;
    _moveCount = 0;
  }

  void _recordCompletion() {
    final levelId = currentLevel.id;
    final completedLevelIds = {..._progress.completedLevelIds, levelId};
    final bestMovesByLevel = Map<int, int>.of(_progress.bestMovesByLevel);
    final bestMoves = bestMovesByLevel[levelId];
    if (bestMoves == null || _moveCount < bestMoves) {
      bestMovesByLevel[levelId] = _moveCount;
    }

    final lastIndex = levels.length - 1;
    final nextIndex = min(_currentLevelIndex + 1, lastIndex);
    final today = _todayKey();

    _progress = _progress.copyWith(
      currentLevelIndex: max(_progress.currentLevelIndex, nextIndex),
      unlockedLevelIndex: max(_progress.unlockedLevelIndex, nextIndex),
      completedLevelIds: completedLevelIds,
      bestMovesByLevel: bestMovesByLevel,
      streakDays: _updatedStreak(today),
      lastCompletionDate: today,
    );

    _saveProgress();
    telemetry.track(
      GameTelemetryEvents.levelComplete(
        levelId: levelId,
        levelNumber: currentLevelNumber,
        moveCount: _moveCount,
        isDailyLevel: _currentLevelIndex == dailyChallengeLevelIndex,
        unlockedLevelCount: unlockedLevelCount,
      ),
    );
  }

  int _updatedStreak(String today) {
    final lastCompletionDate = _progress.lastCompletionDate;
    if (lastCompletionDate == today) {
      return max(1, _progress.streakDays);
    }

    if (lastCompletionDate ==
        _dateKey(_now().subtract(const Duration(days: 1)))) {
      return _progress.streakDays + 1;
    }

    return 1;
  }

  String _todayKey() => _dateKey(_now());

  String _dateKey(DateTime date) {
    final localDate = DateTime(date.year, date.month, date.day);
    final month = localDate.month.toString().padLeft(2, '0');
    final day = localDate.day.toString().padLeft(2, '0');

    return '${localDate.year}-$month-$day';
  }

  void _saveProgress() {
    unawaited(
      progressStore.save(_progress).catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        if (kDebugMode) {
          debugPrint('Failed to save progress: $error');
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

  void _trackLevelStart({required String source}) {
    telemetry.track(
      GameTelemetryEvents.levelStart(
        levelId: currentLevel.id,
        levelNumber: currentLevelNumber,
        source: source,
      ),
    );
  }
}
