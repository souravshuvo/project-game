import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/application/game_telemetry.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/application/game_ad_service.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/application/water_sort_controller.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/data/local_water_level_pack.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/data/water_progress_store.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/domain/pour_result.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/domain/water_player_progress.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/domain/water_sort_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tap flow makes a valid pour and undo restores the previous state', () {
    final controller = _buildController(_MemoryWaterProgressStore());

    controller.play();
    controller.tapTube(0);

    expect(controller.selectedTubeIndex, 0);
    expect(controller.validTargetIndexes, {2});
    expect(controller.lastActionFeedback, WaterActionFeedback.sourceSelected);
    expect(controller.actionFeedbackToken, 1);

    controller.tapTube(2);
    expect(controller.isPourPending, isTrue);
    expect(controller.moveCount, 0);
    controller.finishPourAnimation();

    expect(controller.moveCount, 1);
    expect(controller.flowStreak, 1);
    expect(controller.bestFlowStreak, 1);
    expect(controller.board.toSymbolRows(), ['RRR', 'SSSR', 'S']);
    expect(controller.canUndo, isTrue);
    expect(controller.lastValidMove?.sourceIndex, 0);
    expect(controller.lastValidMove?.destinationIndex, 2);
    expect(controller.validTargetIndexes, isEmpty);
    expect(controller.moveFeedbackToken, 1);
    expect(controller.lastActionFeedback, WaterActionFeedback.pour);

    controller.undo();

    expect(controller.moveCount, 0);
    expect(controller.board.toSymbolRows(), ['RRRS', 'SSSR', '']);
    expect(controller.canUndo, isFalse);
    expect(controller.flowStreak, 0);
    expect(controller.lastValidMove, isNull);
    expect(controller.lastActionFeedback, WaterActionFeedback.undo);
  });

  test('empty source tap gives invalid feedback without changing moves', () {
    final controller = _buildController(_MemoryWaterProgressStore());

    controller.play();
    controller.tapTube(2);

    expect(controller.moveCount, 0);
    expect(controller.lastInvalidReason, PourInvalidReason.sourceEmpty);
    expect(controller.invalidTubeIndex, 2);
    expect(controller.lastActionFeedback, WaterActionFeedback.invalid);
    expect(controller.flowStreak, 0);
  });

  test(
    'invalid target clears the source after rejecting the attempted pour',
    () {
      final controller = _buildController(_MemoryWaterProgressStore());

      controller.play();
      controller.tapTube(0);
      controller.tapTube(1);

      expect(controller.moveCount, 0);
      expect(controller.selectedTubeIndex, isNull);
      expect(controller.lastInvalidReason, PourInvalidReason.destinationFull);
      expect(controller.invalidTubeIndex, 1);
      expect(controller.lastActionFeedback, WaterActionFeedback.invalid);
      expect(controller.validTargetIndexes, isEmpty);
      expect(controller.flowStreak, 0);
    },
  );

  test('restart restores the starting board and clears undo', () {
    final controller = _buildController(_MemoryWaterProgressStore());

    controller.play();
    controller.tapTube(0);
    controller.tapTube(2);
    controller.finishPourAnimation();
    controller.restartLevel();

    expect(controller.moveCount, 0);
    expect(controller.board.toSymbolRows(), ['RRRS', 'SSSR', '']);
    expect(controller.canUndo, isFalse);
    expect(controller.screen, WaterSortScreen.playing);
    expect(controller.lastValidMove, isNull);
    expect(controller.lastActionFeedback, WaterActionFeedback.restart);
  });

  test('winning sequence holds the final pour before completing', () async {
    final store = _MemoryWaterProgressStore();
    final telemetry = _RecordingGameTelemetry();
    final controller = _buildController(store, telemetry: telemetry);

    controller.play();
    _tapMoves(controller, const [(0, 2), (1, 0), (1, 2)]);
    await Future<void>.delayed(Duration.zero);

    expect(controller.screen, WaterSortScreen.playing);
    expect(controller.isCompletionPending, isTrue);
    expect(controller.moveCount, 3);
    expect(controller.flowStreak, 3);
    expect(controller.bestFlowStreak, 3);
    expect(controller.starsForCurrentAttempt, 3);
    expect(controller.moveFeedbackToken, 3);
    expect(controller.lastActionFeedback, WaterActionFeedback.complete);
    expect(controller.lastCompletionWasFirstClear, isTrue);
    expect(controller.lastCompletionImprovedBestMoves, isTrue);
    expect(controller.lastCompletionImprovedStars, isTrue);
    expect(store.saved?.completedLevelIds, {1});
    expect(store.saved?.bestMovesByLevel[1], 3);
    expect(
      controller.labGoals
          .singleWhere((goal) => goal.id == 'first_clear')
          .isComplete,
      isTrue,
    );
    expect(controller.completedLabGoalCount, 1);
    expect(controller.unlockedLevelCount, 2);
    expect(
      telemetry.events.map((event) => event.name),
      containsAllInOrder(['level_start', 'pour_valid', 'level_complete']),
    );

    controller.finishCompletionAnimation();

    expect(controller.screen, WaterSortScreen.complete);
    expect(controller.isCompletionPending, isFalse);
  });

  test('locked levels cannot be selected before completion', () {
    final controller = _buildController(_MemoryWaterProgressStore());

    controller.selectLevel(1);
    controller.selectLevel(-1);

    expect(controller.currentLevelNumber, 1);
    expect(controller.screen, WaterSortScreen.home);
  });

  test('completion unlocks next level and nextLevel opens it', () {
    final controller = _buildController(_MemoryWaterProgressStore());

    controller.play();
    _tapMoves(controller, const [(0, 2), (1, 0), (1, 2)]);
    controller.nextLevel();

    expect(controller.currentLevelNumber, 2);
    expect(controller.screen, WaterSortScreen.playing);
  });

  test(
    'continue after completion offers a level-end ad before next level',
    () async {
      final adService = _RecordingGameAdService();
      final controller = _buildController(
        _MemoryWaterProgressStore(),
        adService: adService,
      );

      controller.play();
      _tapMoves(controller, const [(0, 2), (1, 0), (1, 2)]);
      controller.finishCompletionAnimation();
      await controller.continueToNextLevel();

      expect(adService.levelEndInterstitialAttempts, 1);
      expect(adService.lastLevelId, 1);
      expect(controller.currentLevelNumber, 2);
      expect(controller.screen, WaterSortScreen.playing);
      expect(controller.isContinuingAfterComplete, isFalse);
    },
  );
}

WaterSortController _buildController(
  WaterProgressStore store, {
  GameTelemetry telemetry = const NoOpGameTelemetry(),
  GameAdService adService = const NoOpGameAdService(),
}) {
  return WaterSortController(
    engine: const WaterSortEngine(),
    levels: localWaterLevelPack,
    progressStore: store,
    initialProgress: WaterPlayerProgress.initial(),
    enableFeedback: false,
    telemetry: telemetry,
    adService: adService,
    now: () => DateTime(2026, 8, 10, 12),
  );
}

void _tapMoves(WaterSortController controller, List<(int, int)> moves) {
  for (final move in moves) {
    controller.tapTube(move.$1);
    controller.tapTube(move.$2);
    controller.finishPourAnimation();
  }
}

class _RecordingGameTelemetry implements GameTelemetry {
  final events = <GameTelemetryEvent>[];

  @override
  void track(GameTelemetryEvent event) {
    events.add(event);
  }
}

class _MemoryWaterProgressStore implements WaterProgressStore {
  WaterPlayerProgress? saved;

  @override
  Future<WaterPlayerProgress> load() async {
    return saved ?? WaterPlayerProgress.initial();
  }

  @override
  Future<void> save(WaterPlayerProgress progress) async {
    saved = progress;
  }
}

class _RecordingGameAdService implements GameAdService {
  int levelEndInterstitialAttempts = 0;
  int? lastLevelId;

  @override
  Future<void> initialize() async {}

  @override
  void preloadLevelEndInterstitial() {}

  @override
  Future<bool> maybeShowLevelEndInterstitial({
    required int levelId,
    required int levelNumber,
  }) async {
    levelEndInterstitialAttempts++;
    lastLevelId = levelId;
    return false;
  }

  @override
  void dispose() {}
}
