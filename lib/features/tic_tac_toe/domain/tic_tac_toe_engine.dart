import 'round_outcome.dart';
import 'tic_tac_toe_board.dart';
import 'tic_tac_toe_mark.dart';
import 'tic_tac_toe_round.dart';

class TicTacToeEngine {
  const TicTacToeEngine();

  static const winningLines = <List<int>>[
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  bool canPlay(TicTacToeRound round, int cellIndex) {
    return !round.isOver && round.board.isCellEmpty(cellIndex);
  }

  TicTacToeRound playMove(TicTacToeRound round, int cellIndex) {
    if (!canPlay(round, cellIndex)) {
      return round;
    }

    final nextBoard = round.board.place(cellIndex, round.currentMark);
    final outcome = evaluate(nextBoard, lastMark: round.currentMark);
    final nextMark = outcome.isOver
        ? round.currentMark
        : round.currentMark.opponent;

    return round.copyWith(
      board: nextBoard,
      currentMark: nextMark,
      outcome: outcome,
      moveCount: round.moveCount + 1,
    );
  }

  RoundOutcome evaluate(
    TicTacToeBoard board, {
    required TicTacToeMark lastMark,
  }) {
    for (final line in winningLines) {
      final hasLine = line.every((index) => board.cellAt(index) == lastMark);
      if (hasLine) {
        return RoundOutcome.won(winner: lastMark, winningLine: line);
      }
    }

    if (board.isFull) {
      return const RoundOutcome.draw();
    }

    return const RoundOutcome.playing();
  }
}
