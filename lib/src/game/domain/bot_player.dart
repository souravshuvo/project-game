import 'dart:math';

import 'board_spec.dart';
import 'game_rules.dart';
import 'models.dart';

class BotPlayer {
  const BotPlayer._();

  static GameMove? chooseMove(
    MatchState state,
    BotDifficulty difficulty, {
    Random? random,
  }) {
    final moves = GameRules.legalMoves(state);
    if (moves.isEmpty) {
      return null;
    }

    final captures = moves.where((move) => move.isCapture).toList();
    final candidates = captures.isNotEmpty ? captures : moves;

    return switch (difficulty) {
      BotDifficulty.easy => _randomChoice(candidates, random),
      BotDifficulty.normal => _bestMove(state, candidates),
    };
  }

  static GameMove? hintMove(MatchState state) {
    final moves = GameRules.legalMoves(state);
    if (moves.isEmpty) {
      return null;
    }
    final captures = moves.where((move) => move.isCapture).toList();
    return _bestMove(state, captures.isNotEmpty ? captures : moves);
  }

  static GameMove _randomChoice(List<GameMove> moves, Random? random) {
    final rng = random ?? Random();
    return moves[rng.nextInt(moves.length)];
  }

  static GameMove _bestMove(MatchState state, List<GameMove> moves) {
    final ranked = List<GameMove>.of(moves)
      ..sort((a, b) => _scoreMove(state, b).compareTo(_scoreMove(state, a)));
    return ranked.first;
  }

  static int _scoreMove(MatchState state, GameMove move) {
    var score = BoardSpec.adjacency[move.to]?.length ?? 0;

    if (move.isCapture) {
      score += 100;
      final nextOccupancy = List<Player?>.of(state.occupancy);
      nextOccupancy[move.from] = null;
      nextOccupancy[move.to] = state.currentPlayer;
      if (move.capturedNode != null) {
        nextOccupancy[move.capturedNode!] = null;
      }
      final chainState = MatchState(
        occupancy: nextOccupancy,
        currentPlayer: state.currentPlayer,
        chainNode: move.to,
      );
      score += GameRules.captureMovesFrom(chainState, move.to).length * 25;
    }

    return score;
  }
}
