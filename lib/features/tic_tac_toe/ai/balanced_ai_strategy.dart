import '../domain/round_outcome.dart';
import '../domain/tic_tac_toe_board.dart';
import '../domain/tic_tac_toe_engine.dart';
import '../domain/tic_tac_toe_mark.dart';
import 'tic_tac_toe_ai_strategy.dart';

class BalancedAiStrategy implements TicTacToeAiStrategy {
  const BalancedAiStrategy({this.engine = const TicTacToeEngine()});

  final TicTacToeEngine engine;

  static const _corners = [0, 2, 6, 8];
  static const _sides = [1, 3, 5, 7];

  @override
  int? chooseMove(TicTacToeBoard board, TicTacToeMark aiMark) {
    final winningMove = _immediateLineMove(board, aiMark);
    if (winningMove != null) {
      return winningMove;
    }

    final blockingMove = _immediateLineMove(board, aiMark.opponent);
    if (blockingMove != null) {
      return blockingMove;
    }

    if (board.isCellEmpty(4)) {
      return 4;
    }

    final corner = _firstAvailable(board, _corners);
    if (corner != null) {
      return corner;
    }

    final side = _firstAvailable(board, _sides);
    if (side != null) {
      return side;
    }

    final availableCells = board.availableCells;
    if (availableCells.isEmpty) {
      return null;
    }

    return availableCells.first;
  }

  int? _immediateLineMove(TicTacToeBoard board, TicTacToeMark mark) {
    for (final cellIndex in board.availableCells) {
      final candidate = board.place(cellIndex, mark);
      final outcome = engine.evaluate(candidate, lastMark: mark);
      if (outcome.status == RoundStatus.won) {
        return cellIndex;
      }
    }

    return null;
  }

  int? _firstAvailable(TicTacToeBoard board, List<int> priorityCells) {
    for (final cellIndex in priorityCells) {
      if (board.isCellEmpty(cellIndex)) {
        return cellIndex;
      }
    }

    return null;
  }
}
