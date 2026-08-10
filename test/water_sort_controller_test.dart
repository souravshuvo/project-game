import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/application/game_telemetry.dart';
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
    controller.tapTube(2);

    expect(controller.moveCount, 1);
    expect(controller.board.toSymbolRows(), ['RRR', 'SSSR', 'S']);
    expect(controller.canUndo, isTrue);

    controller.undo();

    expect(controller.moveCount, 0);
    expect(controller.board.toSymbolRows(), ['RRRS', 'SSSR', '']);
    expect(controller.canUndo, isFalse);
  });

  test('empty source tap gives invalid feedback without changing moves', () {
    final controller = _buildController(_MemoryWaterProgressStore());

    controller.play();
    controller.tapTube(2);

    expect(controller.moveCount, 0);
    expect(controller.lastInvalidReason, PourInvalidReason.sourceEmpty);
    expect(controller.invalidTubeIndex, 2);
  });

  test('restart restores the starting board and clears undo', () {
    final controller = _buildController(_MemoryWaterProgressStore());

    controller.play();
    controller.tapTube(0);
    controller.tapTube(2);
    controller.restartLevel();

    expect(controller.moveCount, 0);
    expect(controller.board.toSymbolRows(), ['RRRS', 'SSSR', '']);
    expect(controller.canUndo, isFalse);
    expect(controller.screen, WaterSortScreen.playing);
  });

  test('winning sequence completes the level and records progress', () async {
    final store = _MemoryWaterProgressStore();
    final telemetry = _RecordingGameTelemetry();
    final controller = _buildController(store, telemetry: telemetry);

    controller.play();
    _tapMoves(controller, const [(0, 2), (1, 0), (1, 2)]);
    await Future<void>.delayed(Duration.zero);

    expect(controller.screen, WaterSortScreen.complete);
    expect(controller.moveCount, 3);
    expect(controller.starsForCurrentAttempt, 3);
    expect(store.saved?.completedLevelIds, {1});
    expect(store.saved?.bestMovesByLevel[1], 3);
    expect(controller.unlockedLevelCount, 2);
    expect(
      telemetry.events.map((event) => event.name),
      containsAllInOrder(['level_start', 'pour_valid', 'level_complete']),
    );
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
}

WaterSortController _buildController(
  WaterProgressStore store, {
  GameTelemetry telemetry = const NoOpGameTelemetry(),
}) {
  return WaterSortController(
    engine: const WaterSortEngine(),
    levels: localWaterLevelPack,
    progressStore: store,
    initialProgress: WaterPlayerProgress.initial(),
    enableFeedback: false,
    telemetry: telemetry,
    now: () => DateTime(2026, 8, 10, 12),
  );
}

void _tapMoves(WaterSortController controller, List<(int, int)> moves) {
  for (final move in moves) {
    controller.tapTube(move.$1);
    controller.tapTube(move.$2);
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
