import 'board_position.dart';
import 'match_group.dart';
import 'puzzle_board.dart';
import 'puzzle_level.dart';
import 'puzzle_state.dart';
import 'tile_kind.dart';

class PuzzleMoveResult {
  const PuzzleMoveResult({
    required this.state,
    required this.accepted,
    required this.clearedTiles,
    required this.cascadeCount,
    required this.shuffled,
  });

  final PuzzleState state;
  final bool accepted;
  final int clearedTiles;
  final int cascadeCount;
  final bool shuffled;
}

class RefillResult {
  const RefillResult({required this.board, required this.seed});

  final PuzzleBoard board;
  final int seed;
}

class ShuffleResult {
  const ShuffleResult({
    required this.board,
    required this.seed,
    required this.changed,
  });

  final PuzzleBoard board;
  final int seed;
  final bool changed;
}

class PuzzleEngine {
  const PuzzleEngine();

  PuzzleState start(PuzzleLevel level) {
    final goals = <TileKind, int>{};
    for (final goal in level.goals) {
      goals[goal.tile] = (goals[goal.tile] ?? 0) + goal.count;
    }

    return PuzzleState(
      level: level,
      board: PuzzleBoard.fromRows(level.rows),
      movesLeft: level.moveLimit,
      goalsRemaining: goals,
      score: 0,
      seedState: level.seed,
      status: PuzzleStatus.playing,
      cascadeCount: 0,
      shuffleCount: 0,
    );
  }

  PuzzleState restart(PuzzleState state) => start(state.level);

  bool isValidSwap(
    PuzzleBoard board,
    BoardPosition first,
    BoardPosition second,
  ) {
    if (!board.contains(first) || !board.contains(second)) {
      return false;
    }
    if (!first.isAdjacentTo(second)) {
      return false;
    }
    if (board.tileAt(first) == null || board.tileAt(second) == null) {
      return false;
    }

    return findMatches(board.swap(first, second)).isNotEmpty;
  }

  PuzzleMoveResult makeMove(
    PuzzleState state,
    BoardPosition first,
    BoardPosition second,
  ) {
    if (state.status != PuzzleStatus.playing ||
        !isValidSwap(state.board, first, second)) {
      return PuzzleMoveResult(
        state: state,
        accepted: false,
        clearedTiles: 0,
        cascadeCount: 0,
        shuffled: false,
      );
    }

    final movedState = state.copyWith(
      board: state.board.swap(first, second),
      movesLeft: state.movesLeft - 1,
    );
    final resolved = _resolveMatches(movedState);
    var nextState = resolved.state;
    var shuffled = false;

    if (nextState.status == PuzzleStatus.playing &&
        !hasAnyLegalMove(nextState.board)) {
      final shuffle = shuffleBoard(nextState.board, nextState.seedState);
      nextState = nextState.copyWith(
        board: shuffle.board,
        seedState: shuffle.seed,
        shuffleCount: nextState.shuffleCount + (shuffle.changed ? 1 : 0),
      );
      shuffled = shuffle.changed;
    }

    return PuzzleMoveResult(
      state: nextState,
      accepted: true,
      clearedTiles: resolved.clearedTiles,
      cascadeCount: resolved.cascadeCount,
      shuffled: shuffled,
    );
  }

  List<MatchGroup> findMatches(PuzzleBoard board) {
    return [..._findHorizontalMatches(board), ..._findVerticalMatches(board)];
  }

  PuzzleBoard removeMatches(PuzzleBoard board, List<MatchGroup> matches) {
    final next = board.cells.toList(growable: false);
    for (final position in _matchedPositions(matches)) {
      next[board.indexOf(position)] = null;
    }
    return PuzzleBoard(width: board.width, height: board.height, cells: next);
  }

  PuzzleBoard applyGravity(PuzzleBoard board) {
    final next = List<TileKind?>.filled(board.width * board.height, null);

    for (var col = 0; col < board.width; col++) {
      var writeRow = board.height - 1;
      for (var row = board.height - 1; row >= 0; row--) {
        final tile = board.tileAt(BoardPosition(row, col));
        if (tile == null) {
          continue;
        }
        next[writeRow * board.width + col] = tile;
        writeRow--;
      }
    }

    return PuzzleBoard(width: board.width, height: board.height, cells: next);
  }

  RefillResult refill(PuzzleBoard board, int seed) {
    final next = board.cells.toList(growable: false);
    var nextSeed = seed;

    for (var row = 0; row < board.height; row++) {
      for (var col = 0; col < board.width; col++) {
        final position = BoardPosition(row, col);
        final index = board.indexOf(position);
        if (next[index] != null) {
          continue;
        }
        nextSeed = _nextSeed(nextSeed);
        next[index] = TileKind.values[nextSeed % TileKind.values.length];
      }
    }

    return RefillResult(
      board: PuzzleBoard(width: board.width, height: board.height, cells: next),
      seed: nextSeed,
    );
  }

  bool hasAnyLegalMove(PuzzleBoard board) {
    for (final position in board.positions) {
      final right = BoardPosition(position.row, position.col + 1);
      if (board.contains(right) && isValidSwap(board, position, right)) {
        return true;
      }

      final down = BoardPosition(position.row + 1, position.col);
      if (board.contains(down) && isValidSwap(board, position, down)) {
        return true;
      }
    }
    return false;
  }

  ShuffleResult shuffleBoard(PuzzleBoard board, int seed) {
    final tiles = board.cells.whereType<TileKind>().toList(growable: false);
    var nextSeed = seed;

    for (var attempt = 0; attempt < 32; attempt++) {
      final shuffled = tiles.toList(growable: false);
      for (var index = shuffled.length - 1; index > 0; index--) {
        nextSeed = _nextSeed(nextSeed);
        final swapIndex = nextSeed % (index + 1);
        final tile = shuffled[index];
        shuffled[index] = shuffled[swapIndex];
        shuffled[swapIndex] = tile;
      }

      final candidate = PuzzleBoard(
        width: board.width,
        height: board.height,
        cells: shuffled,
      );
      if (findMatches(candidate).isEmpty && hasAnyLegalMove(candidate)) {
        return ShuffleResult(
          board: candidate,
          seed: nextSeed,
          changed: candidate.toRows().join() != board.toRows().join(),
        );
      }
    }

    return ShuffleResult(board: board, seed: nextSeed, changed: false);
  }

  _ResolutionResult _resolveMatches(PuzzleState state) {
    var board = state.board;
    var goals = Map<TileKind, int>.of(state.goalsRemaining);
    var score = state.score;
    var seed = state.seedState;
    var cascadeDepth = 0;
    var clearedTiles = 0;

    while (true) {
      final matches = findMatches(board);
      if (matches.isEmpty) {
        break;
      }
      if (cascadeDepth > 50) {
        throw StateError('Cascade resolution exceeded the safety limit.');
      }

      final matchedPositions = _matchedPositions(matches);
      clearedTiles += matchedPositions.length;
      score += matchedPositions.length * (10 + cascadeDepth * 5);

      final removedTiles = <TileKind, int>{};
      for (final position in matchedPositions) {
        final tile = board.tileAt(position);
        if (tile != null) {
          removedTiles[tile] = (removedTiles[tile] ?? 0) + 1;
        }
      }
      for (final entry in removedTiles.entries) {
        final remaining = goals[entry.key];
        if (remaining != null) {
          goals[entry.key] = (remaining - entry.value)
              .clamp(0, remaining)
              .toInt();
        }
      }

      board = removeMatches(board, matches);
      board = applyGravity(board);
      final refillResult = refill(board, seed);
      board = refillResult.board;
      seed = refillResult.seed;
      cascadeDepth++;
    }

    final status = goals.values.every((remaining) => remaining <= 0)
        ? PuzzleStatus.won
        : state.movesLeft <= 0
        ? PuzzleStatus.lost
        : PuzzleStatus.playing;

    return _ResolutionResult(
      state: state.copyWith(
        board: board,
        goalsRemaining: goals,
        score: score,
        seedState: seed,
        status: status,
        cascadeCount:
            state.cascadeCount + (cascadeDepth > 0 ? cascadeDepth - 1 : 0),
      ),
      clearedTiles: clearedTiles,
      cascadeCount: cascadeDepth > 0 ? cascadeDepth - 1 : 0,
    );
  }

  List<MatchGroup> _findHorizontalMatches(PuzzleBoard board) {
    final matches = <MatchGroup>[];
    for (var row = 0; row < board.height; row++) {
      var runStart = 0;
      TileKind? runTile;

      for (var col = 0; col <= board.width; col++) {
        final tile = col < board.width
            ? board.tileAt(BoardPosition(row, col))
            : null;
        if (tile != null && tile == runTile) {
          continue;
        }

        final runLength = col - runStart;
        if (runTile != null && runLength >= 3) {
          matches.add(
            MatchGroup(
              tile: runTile,
              positions: List.generate(
                runLength,
                (offset) => BoardPosition(row, runStart + offset),
              ),
            ),
          );
        }

        runTile = tile;
        runStart = col;
      }
    }
    return matches;
  }

  List<MatchGroup> _findVerticalMatches(PuzzleBoard board) {
    final matches = <MatchGroup>[];
    for (var col = 0; col < board.width; col++) {
      var runStart = 0;
      TileKind? runTile;

      for (var row = 0; row <= board.height; row++) {
        final tile = row < board.height
            ? board.tileAt(BoardPosition(row, col))
            : null;
        if (tile != null && tile == runTile) {
          continue;
        }

        final runLength = row - runStart;
        if (runTile != null && runLength >= 3) {
          matches.add(
            MatchGroup(
              tile: runTile,
              positions: List.generate(
                runLength,
                (offset) => BoardPosition(runStart + offset, col),
              ),
            ),
          );
        }

        runTile = tile;
        runStart = row;
      }
    }
    return matches;
  }

  Set<BoardPosition> _matchedPositions(List<MatchGroup> matches) {
    return {
      for (final match in matches)
        for (final position in match.positions) position,
    };
  }

  int _nextSeed(int seed) {
    return (seed * 1103515245 + 12345) & 0x7fffffff;
  }
}

class _ResolutionResult {
  const _ResolutionResult({
    required this.state,
    required this.clearedTiles,
    required this.cascadeCount,
  });

  final PuzzleState state;
  final int clearedTiles;
  final int cascadeCount;
}
