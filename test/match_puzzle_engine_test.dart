import 'package:flutter_test/flutter_test.dart';

import 'package:signal_workshop/features/match_puzzle/data/local_level_pack.dart';
import 'package:signal_workshop/features/match_puzzle/domain/board_position.dart';
import 'package:signal_workshop/features/match_puzzle/domain/level_goal.dart';
import 'package:signal_workshop/features/match_puzzle/domain/player_progress.dart';
import 'package:signal_workshop/features/match_puzzle/domain/puzzle_board.dart';
import 'package:signal_workshop/features/match_puzzle/domain/puzzle_engine.dart';
import 'package:signal_workshop/features/match_puzzle/domain/puzzle_level.dart';
import 'package:signal_workshop/features/match_puzzle/domain/puzzle_state.dart';
import 'package:signal_workshop/features/match_puzzle/domain/tile_kind.dart';

void main() {
  const engine = PuzzleEngine();

  test('validates swaps only when they create a match', () {
    final board = PuzzleBoard.fromRows(['PCP', 'CPL', 'NSL']);

    expect(
      engine.isValidSwap(
        board,
        const BoardPosition(0, 1),
        const BoardPosition(1, 1),
      ),
      isTrue,
    );
    expect(
      engine.isValidSwap(
        board,
        const BoardPosition(2, 0),
        const BoardPosition(2, 1),
      ),
      isFalse,
    );
    expect(
      engine.isValidSwap(
        board,
        const BoardPosition(0, 0),
        const BoardPosition(2, 2),
      ),
      isFalse,
    );
  });

  test('detects horizontal and vertical matches', () {
    final board = PuzzleBoard.fromRows(['PPPC', 'CLNS', 'CLNS', 'CLNS']);
    final matches = engine.findMatches(board);

    expect(matches, hasLength(5));
    expect(
      matches.where((match) => match.tile == TileKind.pulse),
      hasLength(1),
    );
    expect(matches.where((match) => match.positions.length == 3), hasLength(5));
  });

  test('removes matched tiles without clearing overlap twice', () {
    final board = PuzzleBoard.fromRows(['.P.', 'PPP', '.P.']);
    final removed = engine.removeMatches(board, engine.findMatches(board));

    expect(removed.toRows(), ['...', '...', '...']);
  });

  test('applies gravity and refills deterministically', () {
    final board = PuzzleBoard.fromRows(['P.C', '.L.', '.N.']);
    final fallen = engine.applyGravity(board);

    expect(fallen.toRows(), ['...', '.L.', 'PNC']);

    final firstRefill = engine.refill(fallen, 42);
    final secondRefill = engine.refill(fallen, 42);

    expect(firstRefill.board.hasEmptyCells, isFalse);
    expect(firstRefill.board.toRows(), secondRefill.board.toRows());
    expect(firstRefill.seed, secondRefill.seed);
  });

  test('updates collection goals and wins after a completed move', () {
    final level = _testLevel(
      moves: 3,
      goals: const [LevelGoal(tile: TileKind.pulse, count: 3)],
    );
    final start = engine.start(level);
    final result = engine.makeMove(
      start,
      const BoardPosition(0, 1),
      const BoardPosition(1, 1),
    );

    expect(result.accepted, isTrue);
    expect(result.state.goalsRemaining[TileKind.pulse], 0);
    expect(result.state.status, PuzzleStatus.won);
    expect(result.state.movesLeft, 2);
  });

  test('loses when moves run out before the goal is complete', () {
    final level = _testLevel(
      moves: 1,
      goals: const [LevelGoal(tile: TileKind.spark, count: 99)],
    );
    final start = engine.start(level);
    final result = engine.makeMove(
      start,
      const BoardPosition(0, 1),
      const BoardPosition(1, 1),
    );

    expect(result.accepted, isTrue);
    expect(result.state.status, PuzzleStatus.lost);
    expect(result.state.movesLeft, 0);
  });

  test('restart restores board, moves, goals, and score', () {
    final level = _testLevel(
      moves: 3,
      goals: const [LevelGoal(tile: TileKind.spark, count: 99)],
    );
    final start = engine.start(level);
    final played = engine.makeMove(
      start,
      const BoardPosition(0, 1),
      const BoardPosition(1, 1),
    );
    final restarted = engine.restart(played.state);

    expect(restarted.board.toRows(), level.rows);
    expect(restarted.movesLeft, level.moveLimit);
    expect(restarted.goalsRemaining[TileKind.spark], 99);
    expect(restarted.score, 0);
    expect(restarted.status, PuzzleStatus.playing);
  });

  test('resolves cascades deterministically', () {
    const level = PuzzleLevel(
      id: 2,
      name: 'Cascade',
      rows: ['PCPC', 'LLNC', 'PLPL', 'CCLP'],
      moveLimit: 4,
      seed: 7,
      goals: [LevelGoal(tile: TileKind.coil, count: 99)],
    );
    final start = engine.start(level);
    final result = engine.makeMove(
      start,
      const BoardPosition(3, 1),
      const BoardPosition(3, 2),
    );

    expect(result.accepted, isTrue);
    expect(result.cascadeCount, greaterThanOrEqualTo(1));
    expect(result.state.board.hasEmptyCells, isFalse);
  });

  test('does not report shuffled when no legal layout is possible', () {
    final board = PuzzleBoard.fromRows(['PCN', 'LSP', 'CNL']);
    final result = engine.shuffleBoard(board, 99);

    expect(engine.hasAnyLegalMove(board), isFalse);
    expect(result.changed, isFalse);
    expect(result.board.toRows(), board.toRows());
  });

  test('local v1 level pack is sequential and starts playable', () {
    expect(localLevelPack, hasLength(20));

    for (var index = 0; index < localLevelPack.length; index++) {
      final level = localLevelPack[index];
      final board = engine.start(level).board;

      expect(level.id, index + 1);
      expect(engine.findMatches(board), isEmpty, reason: level.name);
      expect(engine.hasAnyLegalMove(board), isTrue, reason: level.name);
      expect(level.moveLimit, greaterThan(0), reason: level.name);
      expect(level.goals, isNotEmpty, reason: level.name);
    }
  });

  test('records completion, unlocks the next level, and keeps best moves', () {
    final progress = PlayerProgress.initial().recordCompletion(
      levelId: 1,
      levelIndex: 0,
      levelCount: 20,
      movesLeft: 4,
    );

    expect(progress.currentLevelIndex, 1);
    expect(progress.unlockedLevelIndex, 1);
    expect(progress.completedLevelIds, {1});
    expect(progress.bestMovesLeftByLevel[1], 4);

    final replayed = progress.recordCompletion(
      levelId: 1,
      levelIndex: 0,
      levelCount: 20,
      movesLeft: 2,
    );

    expect(replayed.bestMovesLeftByLevel[1], 4);
  });
}

PuzzleLevel _testLevel({required int moves, required List<LevelGoal> goals}) {
  return PuzzleLevel(
    id: 1,
    name: 'Test Signal',
    rows: const ['PCP', 'CPL', 'NSL'],
    moveLimit: moves,
    seed: 7,
    goals: goals,
  );
}
