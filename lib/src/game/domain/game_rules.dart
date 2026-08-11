import 'board_spec.dart';
import 'models.dart';

class GameRules {
  const GameRules._();

  static List<GameMove> legalMoves(MatchState state, {int? fromNode}) {
    if (state.isGameOver) {
      return const [];
    }

    if (state.isCaptureChain) {
      final chainNode = state.chainNode!;
      if (fromNode != null && fromNode != chainNode) {
        return const [];
      }
      return captureMovesFrom(state, chainNode);
    }

    if (fromNode != null) {
      if (state.occupancy[fromNode] != state.currentPlayer) {
        return const [];
      }
      return [
        ...normalMovesFrom(state, fromNode),
        ...captureMovesFrom(state, fromNode),
      ];
    }

    return [
      for (var node = 0; node < BoardSpec.nodeCount; node++)
        if (state.occupancy[node] == state.currentPlayer) ...[
          ...normalMovesFrom(state, node),
          ...captureMovesFrom(state, node),
        ],
    ];
  }

  static List<GameMove> normalMovesFrom(MatchState state, int from) {
    if (state.occupancy[from] != state.currentPlayer || state.isCaptureChain) {
      return const [];
    }
    return [
      for (final to in BoardSpec.adjacency[from]!)
        if (state.occupancy[to] == null)
          GameMove(
            player: state.currentPlayer,
            from: from,
            to: to,
            kind: MoveKind.normal,
          ),
    ];
  }

  static List<GameMove> captureMovesFrom(MatchState state, int from) {
    if (state.occupancy[from] != state.currentPlayer) {
      return const [];
    }
    final opponent = state.currentPlayer.opponent;
    return [
      for (final path in BoardSpec.directionalJumpPaths)
        if (path.from == from &&
            state.occupancy[path.over] == opponent &&
            state.occupancy[path.to] == null)
          GameMove(
            player: state.currentPlayer,
            from: from,
            to: path.to,
            kind: MoveKind.capture,
            capturedNode: path.over,
          ),
    ];
  }

  static MatchState applyMove(MatchState state, GameMove move) {
    if (state.isGameOver) {
      return state;
    }
    if (move.player != state.currentPlayer) {
      return state;
    }

    final legal = legalMoves(state, fromNode: move.from).any(
      (candidate) =>
          candidate.from == move.from &&
          candidate.to == move.to &&
          candidate.kind == move.kind &&
          candidate.capturedNode == move.capturedNode,
    );
    if (!legal) {
      return state;
    }

    final nextOccupancy = List<Player?>.of(state.occupancy);
    nextOccupancy[move.from] = null;
    nextOccupancy[move.to] = state.currentPlayer;
    if (move.capturedNode != null) {
      nextOccupancy[move.capturedNode!] = null;
    }

    final movedState = state.copyWith(
      occupancy: nextOccupancy,
      chainNode: null,
      clearChainNode: true,
    );

    if (move.isCapture) {
      final captureState = movedState.copyWith(chainNode: move.to);
      if (captureMovesFrom(captureState, move.to).isNotEmpty) {
        return captureState;
      }
    }

    return _finishTurn(movedState);
  }

  static MatchState endCaptureChain(MatchState state) {
    if (!state.isCaptureChain || state.isGameOver) {
      return state;
    }
    return _finishTurn(state.copyWith(clearChainNode: true));
  }

  static MatchState _finishTurn(MatchState state) {
    final opponent = state.currentPlayer.opponent;
    if (state.beadCount(opponent) == 0) {
      return state.copyWith(
        result: MatchResult(
          winner: state.currentPlayer,
          reason: MatchEndReason.capturedAll,
        ),
      );
    }

    final nextState = state.copyWith(
      currentPlayer: opponent,
      clearChainNode: true,
    );
    if (legalMoves(nextState).isEmpty) {
      return nextState.copyWith(
        result: MatchResult(
          winner: state.currentPlayer,
          reason: MatchEndReason.blocked,
        ),
      );
    }
    return nextState;
  }
}
