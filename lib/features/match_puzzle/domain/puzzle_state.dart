import 'puzzle_board.dart';
import 'puzzle_level.dart';
import 'tile_kind.dart';

enum PuzzleStatus { playing, won, lost }

class PuzzleState {
  PuzzleState({
    required this.level,
    required this.board,
    required this.movesLeft,
    required Map<TileKind, int> goalsRemaining,
    required this.score,
    required this.seedState,
    required this.status,
    required this.cascadeCount,
    required this.shuffleCount,
  }) : goalsRemaining = Map.unmodifiable(goalsRemaining);

  final PuzzleLevel level;
  final PuzzleBoard board;
  final int movesLeft;
  final Map<TileKind, int> goalsRemaining;
  final int score;
  final int seedState;
  final PuzzleStatus status;
  final int cascadeCount;
  final int shuffleCount;

  bool get isGoalComplete {
    return goalsRemaining.values.every((remaining) => remaining <= 0);
  }

  PuzzleState copyWith({
    PuzzleBoard? board,
    int? movesLeft,
    Map<TileKind, int>? goalsRemaining,
    int? score,
    int? seedState,
    PuzzleStatus? status,
    int? cascadeCount,
    int? shuffleCount,
  }) {
    return PuzzleState(
      level: level,
      board: board ?? this.board,
      movesLeft: movesLeft ?? this.movesLeft,
      goalsRemaining: goalsRemaining ?? this.goalsRemaining,
      score: score ?? this.score,
      seedState: seedState ?? this.seedState,
      status: status ?? this.status,
      cascadeCount: cascadeCount ?? this.cascadeCount,
      shuffleCount: shuffleCount ?? this.shuffleCount,
    );
  }
}
