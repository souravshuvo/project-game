import 'package:pocket_observatory_xo/features/arrow_puzzle/application/game_telemetry.dart';
import 'package:pocket_observatory_xo/features/arrow_puzzle/application/puzzle_controller.dart';
import 'package:pocket_observatory_xo/features/arrow_puzzle/data/puzzle_progress_store.dart';
import 'package:pocket_observatory_xo/features/arrow_puzzle/domain/board_position.dart';
import 'package:pocket_observatory_xo/features/arrow_puzzle/domain/player_progress.dart';
import 'package:pocket_observatory_xo/features/arrow_puzzle/domain/puzzle_engine.dart';
import 'package:pocket_observatory_xo/features/arrow_puzzle/domain/puzzle_level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('completion unlocks next level and records best moves', () {
    final store = _MemoryProgressStore();
    final controller = PuzzleController(
      engine: const PuzzleEngine(),
      levels: const [
        PuzzleLevel(id: 1, name: 'One', rows: ['R'], lesson: 'Go right.'),
        PuzzleLevel(id: 2, name: 'Two', rows: ['R'], lesson: 'Go right again.'),
      ],
      progressStore: store,
      initialProgress: PlayerProgress.initial(),
      enableFeedback: false,
      now: () => DateTime(2026, 8, 2),
    );

    controller.play();
    controller.tap(const BoardPosition(0, 0));

    expect(controller.screen, PuzzleScreen.complete);
    expect(controller.unlockedLevelCount, 2);
    expect(controller.bestMovesForLevel(1), 1);
    expect(controller.streakDays, 1);
    expect(store.saved?.completedLevelIds, {1});
  });

  test('settings toggles persist through controller', () {
    final store = _MemoryProgressStore();
    final controller = _buildController(store);

    controller.toggleSound(false);
    controller.toggleHaptics(false);

    expect(controller.soundEnabled, isFalse);
    expect(controller.hapticsEnabled, isFalse);
    expect(store.saved?.soundEnabled, isFalse);
    expect(store.saved?.hapticsEnabled, isFalse);
  });

  test('daily hint can be claimed and used to highlight a valid move', () {
    final store = _MemoryProgressStore();
    final controller = _buildController(
      store,
      initialProgress: PlayerProgress.initial().copyWith(hintCount: 0),
    );

    controller.claimDailyHint();
    controller.play();
    controller.useHint();

    expect(controller.hintCount, 0);
    expect(controller.hintedPosition, const BoardPosition(0, 0));
    expect(store.saved?.hintCount, 0);
    expect(store.saved?.lastHintClaimDate, '2026-08-02');
  });

  test('records privacy-safe launch and gameplay telemetry events', () {
    final store = _MemoryProgressStore();
    final telemetry = _RecordingGameTelemetry();
    final controller = _buildController(store, telemetry: telemetry);

    controller.play();
    controller.tap(const BoardPosition(0, 0));

    expect(
      telemetry.events.map((event) => event.name),
      containsAllInOrder([
        'app_open',
        'screen_view',
        'level_start',
        'level_complete',
        'screen_view',
      ]),
    );

    final completeEvent = telemetry.events.firstWhere(
      (event) => event.name == 'level_complete',
    );
    expect(completeEvent.parameters['level_id'], 1);
    expect(completeEvent.parameters['level_number'], 1);
    expect(completeEvent.parameters['move_count'], 1);
    expect(completeEvent.parameters['is_daily_level'], isA<bool>());
  });
}

PuzzleController _buildController(
  PuzzleProgressStore store, {
  PlayerProgress? initialProgress,
  GameTelemetry telemetry = const NoOpGameTelemetry(),
}) {
  return PuzzleController(
    engine: const PuzzleEngine(),
    levels: const [
      PuzzleLevel(id: 1, name: 'One', rows: ['R'], lesson: 'Go right.'),
      PuzzleLevel(id: 2, name: 'Two', rows: ['R'], lesson: 'Go right again.'),
    ],
    progressStore: store,
    initialProgress: initialProgress ?? PlayerProgress.initial(),
    enableFeedback: false,
    telemetry: telemetry,
    now: () => DateTime(2026, 8, 2),
  );
}

class _RecordingGameTelemetry implements GameTelemetry {
  final events = <GameTelemetryEvent>[];

  @override
  void track(GameTelemetryEvent event) {
    events.add(event);
  }
}

class _MemoryProgressStore implements PuzzleProgressStore {
  PlayerProgress? saved;

  @override
  Future<PlayerProgress> load() async {
    return saved ?? PlayerProgress.initial();
  }

  @override
  Future<void> save(PlayerProgress progress) async {
    saved = progress;
  }
}
