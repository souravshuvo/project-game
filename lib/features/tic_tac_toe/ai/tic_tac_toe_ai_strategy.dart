import '../domain/tic_tac_toe_board.dart';
import '../domain/tic_tac_toe_mark.dart';

abstract interface class TicTacToeAiStrategy {
  int? chooseMove(TicTacToeBoard board, TicTacToeMark aiMark);
}
