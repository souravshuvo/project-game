import 'round_outcome.dart';
import 'tic_tac_toe_board.dart';
import 'tic_tac_toe_mark.dart';

class TicTacToeRound {
  const TicTacToeRound({
    required this.board,
    required this.currentMark,
    required this.outcome,
    required this.moveCount,
  });

  factory TicTacToeRound.fresh({TicTacToeMark startingMark = TicTacToeMark.x}) {
    return TicTacToeRound(
      board: TicTacToeBoard.empty(),
      currentMark: startingMark,
      outcome: const RoundOutcome.playing(),
      moveCount: 0,
    );
  }

  final TicTacToeBoard board;
  final TicTacToeMark currentMark;
  final RoundOutcome outcome;
  final int moveCount;

  bool get isOver => outcome.isOver;

  TicTacToeRound copyWith({
    TicTacToeBoard? board,
    TicTacToeMark? currentMark,
    RoundOutcome? outcome,
    int? moveCount,
  }) {
    return TicTacToeRound(
      board: board ?? this.board,
      currentMark: currentMark ?? this.currentMark,
      outcome: outcome ?? this.outcome,
      moveCount: moveCount ?? this.moveCount,
    );
  }
}
