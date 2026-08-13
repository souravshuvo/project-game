import 'board_spec.dart';
import 'models.dart';

class GameRules {
  const GameRules._();

  static MatchState initialState() {
    return MatchState.fromPlacement(
      nodeCount: BoardSpec.nodeCount,
      player1Nodes: BoardSpec.player1StartNodes,
      player2Nodes: BoardSpec.player2StartNodes,
      currentPlayer: Player.player1,
    );
  }

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

    final neighbors = BoardSpec.adjacency[from]!.toList()..sort();
    return [
      for (final to in neighbors)
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
    if (state.isGameOver || move.player != state.currentPlayer) {
      return state;
    }

    final isLegal = legalMoves(state, fromNode: move.from).contains(move);
    if (!isLegal) {
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
      clearChainNode: true,
      halfTurnsSinceCapture: move.isCapture
          ? 0
          : state.halfTurnsSinceCapture + 1,
    );

    if (movedState.beadCount(state.currentPlayer.opponent) == 0) {
      return movedState.copyWith(
        result: MatchResult(
          winner: state.currentPlayer,
          reason: MatchEndReason.capturedAll,
        ),
      );
    }

    if (move.isCapture) {
      final chainState = movedState.copyWith(chainNode: move.to);
      if (captureMovesFrom(chainState, move.to).isNotEmpty) {
        return chainState;
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
    final nextPlayer = state.currentPlayer.opponent;
    final nextState = state.copyWith(
      currentPlayer: nextPlayer,
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

    if (nextState.halfTurnsSinceCapture >= 100) {
      return nextState.copyWith(
        result: const MatchResult(reason: MatchEndReason.noCaptureLimit),
      );
    }

    final recordedState = nextState.recordCurrentPosition();
    if (recordedState.currentPositionCount >= 3) {
      return recordedState.copyWith(
        result: const MatchResult(reason: MatchEndReason.repetition),
      );
    }

    return recordedState;
  }
}
