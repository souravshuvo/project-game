import 'dart:math';

import 'game_rules.dart';
import 'models.dart';

class BotPlayer {
  const BotPlayer._();

  static GameMove? chooseMove(
    MatchState state, {
    required BotDifficulty difficulty,
  }) {
    final moves = GameRules.legalMoves(state);
    if (moves.isEmpty) {
      return null;
    }

    final orderedMoves = _ordered(moves);
    return switch (difficulty) {
      BotDifficulty.easy => _firstCaptureOrMove(orderedMoves),
      BotDifficulty.balanced => _bestByScore(
        state,
        orderedMoves,
        _balancedScore,
      ),
      BotDifficulty.sharp => _bestByScore(state, orderedMoves, _sharpScore),
    };
  }

  static bool shouldContinueCaptureChain(
    MatchState state, {
    required BotDifficulty difficulty,
  }) {
    if (!state.isCaptureChain || GameRules.legalMoves(state).isEmpty) {
      return false;
    }
    return switch (difficulty) {
      BotDifficulty.easy => false,
      BotDifficulty.balanced || BotDifficulty.sharp => true,
    };
  }

  static GameMove _firstCaptureOrMove(List<GameMove> moves) {
    for (final move in moves) {
      if (move.isCapture) {
        return move;
      }
    }
    return moves.first;
  }

  static GameMove _bestByScore(
    MatchState state,
    List<GameMove> moves,
    int Function(MatchState state, GameMove move) score,
  ) {
    var bestMove = moves.first;
    var bestScore = score(state, bestMove);

    for (final move in moves.skip(1)) {
      final moveScore = score(state, move);
      if (moveScore > bestScore) {
        bestMove = move;
        bestScore = moveScore;
      }
    }

    return bestMove;
  }

  static int _balancedScore(MatchState state, GameMove move) {
    final next = GameRules.applyMove(state, move);
    final ownBeads = next.beadCount(move.player);
    final opponentBeads = next.beadCount(move.player.opponent);
    final futureCaptures = next.isCaptureChain
        ? GameRules.legalMoves(
            next,
          ).where((candidate) => candidate.isCapture).length
        : 0;
    final opponentCaptures = next.currentPlayer == move.player.opponent
        ? GameRules.legalMoves(
            next,
          ).where((candidate) => candidate.isCapture).length
        : 0;

    if (next.result?.winner == move.player) {
      return 10000;
    }

    return (move.isCapture ? 160 : 0) +
        futureCaptures * 60 -
        opponentCaptures * 25 +
        (ownBeads - opponentBeads) * 12 +
        _centerScore(move.to);
  }

  static int _sharpScore(MatchState state, GameMove move) {
    final next = GameRules.applyMove(state, move);
    final ownBeads = next.beadCount(move.player);
    final opponentBeads = next.beadCount(move.player.opponent);
    final futureCaptures = next.isCaptureChain
        ? GameRules.legalMoves(
            next,
          ).where((candidate) => candidate.isCapture).length
        : 0;
    final opponentMoves = next.currentPlayer == move.player.opponent
        ? GameRules.legalMoves(next)
        : const <GameMove>[];
    final opponentCaptures = opponentMoves
        .where((candidate) => candidate.isCapture)
        .length;

    if (next.result?.winner == move.player) {
      return 20000;
    }
    if (next.result?.winner == move.player.opponent) {
      return -20000;
    }

    return (move.isCapture ? 260 : 0) +
        futureCaptures * 95 -
        opponentCaptures * 70 -
        opponentMoves.length * 2 +
        (ownBeads - opponentBeads) * 24 +
        _centerScore(move.to) * 2;
  }

  static List<GameMove> _ordered(List<GameMove> moves) {
    return [...moves]..sort((a, b) {
      final captureCompare = (b.isCapture ? 1 : 0).compareTo(
        a.isCapture ? 1 : 0,
      );
      if (captureCompare != 0) {
        return captureCompare;
      }
      final fromCompare = a.from.compareTo(b.from);
      if (fromCompare != 0) {
        return fromCompare;
      }
      final toCompare = a.to.compareTo(b.to);
      if (toCompare != 0) {
        return toCompare;
      }
      return (a.capturedNode ?? -1).compareTo(b.capturedNode ?? -1);
    });
  }

  static int _centerScore(int nodeId) {
    const centerNode = 18;
    return max(0, 10 - (nodeId - centerNode).abs());
  }
}
