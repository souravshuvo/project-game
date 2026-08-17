import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/puzzle_progress_store.dart';
import '../data/campaign_playbook.dart';
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
        completedLevelCount: completedLevelCount,
        streakDays: streakDays,
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
  var _lastCompletionWasNewRecord = false;
  int? _lastCompletionMoveDelta;
  late DateTime _levelStartedAt;
  var _currentLevelArrowCount = 0;
  var _moveCount = 0;
  var _invalidTapCount = 0;
  var _hintUseCount = 0;
  var _runScore = 0;
  var _comboStreak = 0;
  var _maxComboStreak = 0;
  int? _lastCompletionRunScore;
  int? _lastCompletionMaxCombo;
  bool _lastCompletionWasScoreRecord = false;

  PuzzleScreen get screen => _screen;

  PuzzleLevel get currentLevel => levels[_currentLevelIndex];

  PuzzleBoard get board => _board;

  int get currentLevelNumber => _currentLevelIndex + 1;

  int get resumeLevelNumber => _progress.currentLevelIndex + 1;

  int get totalLevels => levels.length;

  int get moveCount => _moveCount;

  int get completedLevelCount => _progress.completedLevelIds.length;

  bool get hasCompletedAllLevels => completedLevelCount >= totalLevels;

  int get unlockedLevelCount => _progress.unlockedLevelIndex + 1;

  List<CampaignWave> get campaignWaves =>
      buildCampaignWaves(totalLevels: totalLevels);

  CampaignWave? get currentCampaignWave =>
      campaignWaveForLevel(levelNumber: currentLevelNumber, totalLevels: totalLevels);

  CampaignWave? get nextCampaignWave {
    final current = currentCampaignWave;
    if (current == null) {
      return null;
    }
    return campaignWaveForLevel(
      levelNumber: current.endLevel + 1,
      totalLevels: totalLevels,
    );
  }

  int completedLevelsInWaveCount(CampaignWave? wave) {
    if (wave == null) {
      return 0;
    }
    return completedLevelCountInWave(wave, _progress.completedLevelIds);
  }

  bool isWaveComplete(CampaignWave? wave) {
    if (wave == null) {
      return false;
    }
    return completedLevelsInWaveCount(wave) >= wave.levelCount;
  }

  String get campaignMissionTitle {
    return currentCampaignWave?.title ?? 'Campaign';
  }

  String get campaignMissionObjective {
    return currentCampaignWave?.objective ?? 'Keep replaying and improving clear quality.';
  }

  String get campaignMissionReward {
    return currentCampaignWave?.reward ??
        'Replay levels to unlock full wave momentum.';
  }

  int get streakDays => _progress.streakDays;

  int get hintCount => _progress.hintCount;

  bool get soundEnabled => _progress.soundEnabled;

  bool get hapticsEnabled => _progress.hapticsEnabled;

  bool get shouldShowTutorial => !_progress.hasSeenTutorial;

  bool get canClaimDailyHint => _progress.lastHintClaimDate != _todayKey();

  bool get canUseHint => hintCount > 0 && validMoves.isNotEmpty;

  int get runScore => _runScore;

  int get comboStreak => _comboStreak;

  int get maxComboStreak => _maxComboStreak;

  int? get lastCompletionRunScore => _lastCompletionRunScore;

  int? get lastCompletionMaxCombo => _lastCompletionMaxCombo;

  bool get lastCompletionWasScoreRecord => _lastCompletionWasScoreRecord;

  int? get bestRunScoreForCurrentLevel => bestRunScoreForLevel(currentLevel.id);

  int? get currentLevelBestMoves => bestMovesForLevel(currentLevel.id);

  int? bestRunScoreForLevel(int levelId) => _progress.bestScoreByLevel[levelId];

  bool get isBoardStuck => engine.isStuck(_board);

  int get remainingArrows =>
      _board.cells.expand((row) => row).where((cell) => cell.isArrow).length;

  bool get lastCompletionWasNewRecord => _lastCompletionWasNewRecord;

  int? get lastCompletionMoveDelta => _lastCompletionMoveDelta;

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

  void markTutorialSeen() {
    if (_progress.hasSeenTutorial) {
      return;
    }

    _progress = _progress.copyWith(hasSeenTutorial: true);
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
    _playRewardFeedback();
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
    _hintUseCount++;
    _runScore = max(0, _runScore - 45);
    _comboStreak = 0;
    _playRewardFeedback();
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

  void grantRewardedHint({required String placement}) {
    _progress = _progress.copyWith(hintCount: min(_progress.hintCount + 1, 99));
    _playRewardFeedback();
    telemetry.track(
      GameTelemetryEvents.rewardedHintGrant(
        levelNumber: currentLevelNumber,
        hintBalance: _progress.hintCount,
        placement: placement,
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
        invalidTapCount: _invalidTapCount,
        hintUseCount: _hintUseCount,
        durationSeconds: _levelDurationSeconds,
      ),
    );
    _loadCurrentLevel();
    _screen = PuzzleScreen.playing;
    _trackLevelStart(source: 'retry');
    _trackScreenView();
    _playActionFeedback();
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

  void startCampaignWave(int waveIndex) {
    if (campaignWaves.isEmpty) {
      return;
    }
    final targetIndex = waveIndex.clamp(1, campaignWaves.length);
    final wave = campaignWaves[targetIndex - 1];

    for (var levelNumber = wave.startLevel; levelNumber <= wave.endLevel; levelNumber++) {
      final index = levelNumber - 1;
      if (index < 0 || index >= totalLevels) {
        continue;
      }
      if (!isLevelComplete(levels[index].id) && isLevelUnlocked(index)) {
        selectLevel(index, source: 'campaign_wave');
        return;
      }
    }

    final fallbackIndex = (wave.startLevel - 1).clamp(0, totalLevels - 1);
    if (isLevelUnlocked(fallbackIndex)) {
      selectLevel(fallbackIndex, source: 'campaign_wave');
    }
  }

  void startNextCampaignWaveOrCurrent() {
    final nextWave = nextCampaignWave;
    if (nextWave == null || !isWaveComplete(currentCampaignWave)) {
      if (currentCampaignWave != null) {
        startCampaignWave(currentCampaignWave!.index);
        return;
      }
      return;
    }
    startCampaignWave(nextWave.index);
  }

  void tap(BoardPosition position) {
    _lastInvalidTap = null;
    _lastRemovedPosition = null;
    _lastRemovedCell = null;

    if (!engine.canRemove(_board, position)) {
      _lastInvalidTap = position;
      _invalidTapCount++;
      _comboStreak = 0;
      _runScore = max(0, _runScore - 36);
      _playInvalidFeedback();
      telemetry.track(
        GameTelemetryEvents.levelInvalidTap(
          levelId: currentLevel.id,
          levelNumber: currentLevelNumber,
          moveCount: _moveCount,
          invalidTapCount: _invalidTapCount,
          validMoveCount: validMoves.length,
        ),
      );
      notifyListeners();
      return;
    }

    _playValidFeedback();
    _lastRemovedPosition = position;
    _lastRemovedCell = _board.cellAt(position);
    _hintedPosition = null;
    _board = engine.remove(_board, position);
    _moveCount++;
    _comboStreak++;
    if (_comboStreak > _maxComboStreak) {
      _maxComboStreak = _comboStreak;
    }
    _runScore += 72 + (_comboStreak * 10);

    if (_board.isCleared) {
      _recordCompletion();
      _screen = PuzzleScreen.complete;
      _trackScreenView();
      _playWinFeedback();
    } else if (engine.isStuck(_board)) {
      _trackBoardStuck();
      _playFailureFeedback();
    }

    notifyListeners();
  }

  void _loadCurrentLevel() {
    _board = engine.parse(currentLevel);
    _currentLevelArrowCount = _arrowCount(_board);
    _lastInvalidTap = null;
    _lastRemovedPosition = null;
    _hintedPosition = null;
    _lastRemovedCell = null;
    _runScore = _baseRunScore(_currentLevelArrowCount);
    _comboStreak = 0;
    _maxComboStreak = 0;
    _levelStartedAt = _now();
    _moveCount = 0;
    _invalidTapCount = 0;
    _hintUseCount = 0;
    _lastCompletionWasNewRecord = false;
    _lastCompletionMoveDelta = null;
    _lastCompletionRunScore = null;
    _lastCompletionMaxCombo = null;
    _lastCompletionWasScoreRecord = false;
  }

  void _recordCompletion() {
    final levelId = currentLevel.id;
    final completedLevelIds = {..._progress.completedLevelIds, levelId};
    final bestMovesByLevel = Map<int, int>.of(_progress.bestMovesByLevel);
    final bestScoreByLevel = Map<int, int>.of(_progress.bestScoreByLevel);
    final bestMoves = bestMovesByLevel[levelId];
    final bestRunScore = bestScoreByLevel[levelId];
    _lastCompletionRunScore = _runScore;
    _lastCompletionMaxCombo = _maxComboStreak;

    final moveClearBonus = max(0, 120 - _movePenalty());
    final timeBonus = max(0, 90 - (_levelDurationSeconds * 2));
    _runScore += moveClearBonus + timeBonus;
    _lastCompletionRunScore = _runScore;
    _lastCompletionWasScoreRecord = bestRunScore == null || _runScore > bestRunScore;
    if (_lastCompletionWasScoreRecord) {
      bestScoreByLevel[levelId] = _runScore;
    }

    _lastCompletionWasNewRecord = bestMoves == null || _moveCount < bestMoves;
    _lastCompletionMoveDelta = bestMoves == null
        ? null
        : bestMoves - _moveCount;
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
      bestScoreByLevel: bestScoreByLevel,
    );

    _saveProgress();
    telemetry.track(
      GameTelemetryEvents.levelComplete(
        levelId: levelId,
        levelNumber: currentLevelNumber,
        moveCount: _moveCount,
        invalidTapCount: _invalidTapCount,
        hintUseCount: _hintUseCount,
        durationSeconds: _levelDurationSeconds,
        isDailyLevel: _currentLevelIndex == dailyChallengeLevelIndex,
        unlockedLevelCount: unlockedLevelCount,
        boardRows: currentLevel.rows.length,
        boardCols: currentLevel.rows.first.length,
        arrowCount: _currentLevelArrowCount,
      ),
    );
  }

  void _trackBoardStuck() {
    telemetry.track(
      GameTelemetryEvents.levelStuck(
        levelId: currentLevel.id,
        levelNumber: currentLevelNumber,
        boardRows: currentLevel.rows.length,
        boardCols: currentLevel.rows.first.length,
        arrowCount: _currentLevelArrowCount,
        moveCount: _moveCount,
        invalidTapCount: _invalidTapCount,
        hintUseCount: _hintUseCount,
      ),
    );
  }

  int get _levelDurationSeconds {
    return max(0, _now().difference(_levelStartedAt).inSeconds);
  }

  int _arrowCount(PuzzleBoard board) {
    return board.cells
        .expand((row) => row)
        .where((cell) => cell.isArrow)
        .length;
  }

  int _baseRunScore(int arrowCount) => 75 + (arrowCount * 22);

  int _movePenalty() => (_invalidTapCount * 14) + (_hintUseCount * 22);

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

  void _playActionFeedback() {
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
      unawaited(SystemSound.play(SystemSoundType.alert));
    }
  }

  void _playRewardFeedback() {
    if (!enableFeedback) {
      return;
    }

    if (_progress.hapticsEnabled) {
      unawaited(HapticFeedback.selectionClick());
    }
    if (_progress.soundEnabled) {
      unawaited(SystemSound.play(SystemSoundType.alert));
    }
  }

  void _playWinFeedback() {
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

  void _playFailureFeedback() {
    if (!enableFeedback) {
      return;
    }

    if (_progress.hapticsEnabled) {
      unawaited(HapticFeedback.heavyImpact());
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
        boardRows: currentLevel.rows.length,
        boardCols: currentLevel.rows.first.length,
        arrowCount: _currentLevelArrowCount,
        validMoveCount: validMoves.length,
      ),
    );
  }
}
