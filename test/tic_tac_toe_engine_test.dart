import 'package:pocket_observatory_xo/features/tic_tac_toe/ai/balanced_ai_strategy.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/domain/round_outcome.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/domain/tic_tac_toe_board.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/domain/tic_tac_toe_engine.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/domain/tic_tac_toe_mark.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/domain/tic_tac_toe_round.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = TicTacToeEngine();

  test('detects win and exposes the winning line', () {
    final round = _playMoves(engine, [0, 3, 1, 4, 2]);

    expect(round.outcome.status, RoundStatus.won);
    expect(round.outcome.winner, TicTacToeMark.x);
    expect(round.outcome.winningLine, [0, 1, 2]);
    expect(round.moveCount, 5);
  });

  test('detects every winning line', () {
    const winningMoveSets = [
      [0, 3, 1, 4, 2],
      [3, 0, 4, 1, 5],
      [6, 0, 7, 1, 8],
      [0, 1, 3, 2, 6],
      [1, 0, 4, 2, 7],
      [2, 0, 5, 1, 8],
      [0, 1, 4, 2, 8],
      [2, 0, 4, 1, 6],
    ];

    for (var index = 0; index < winningMoveSets.length; index++) {
      final round = _playMoves(engine, winningMoveSets[index]);

      expect(
        round.outcome.status,
        RoundStatus.won,
        reason: 'Line $index should win.',
      );
      expect(round.outcome.winningLine, TicTacToeEngine.winningLines[index]);
    }
  });

  test('detects draw when the board fills without a winner', () {
    final round = _playMoves(engine, [0, 1, 2, 4, 3, 5, 7, 6, 8]);

    expect(round.outcome.status, RoundStatus.draw);
    expect(round.outcome.winner, isNull);
    expect(round.moveCount, 9);
  });

  test('occupied cell move is invalid and leaves round unchanged', () {
    final firstMove = engine.playMove(TicTacToeRound.fresh(), 0);
    final invalidMove = engine.playMove(firstMove, 0);

    expect(invalidMove.board, firstMove.board);
    expect(invalidMove.currentMark, firstMove.currentMark);
    expect(invalidMove.moveCount, firstMove.moveCount);
    expect(invalidMove.outcome.status, RoundStatus.playing);
  });

  test('moves after a completed round are ignored', () {
    final wonRound = _playMoves(engine, [0, 3, 1, 4, 2]);
    final ignoredMove = engine.playMove(wonRound, 5);

    expect(ignoredMove.board, wonRound.board);
    expect(ignoredMove.moveCount, wonRound.moveCount);
    expect(ignoredMove.outcome.status, RoundStatus.won);
  });

  test('out of range move is invalid and leaves round unchanged', () {
    final round = TicTacToeRound.fresh();
    final next = engine.playMove(round, 99);

    expect(next.board, round.board);
    expect(next.currentMark, round.currentMark);
    expect(next.moveCount, round.moveCount);
  });

  test('balanced AI takes an immediate winning move', () {
    const strategy = BalancedAiStrategy();
    final board = TicTacToeBoard.fromCells(const [
      TicTacToeMark.o,
      TicTacToeMark.o,
      null,
      TicTacToeMark.x,
      null,
      null,
      TicTacToeMark.x,
      null,
      null,
    ]);

    expect(strategy.chooseMove(board, TicTacToeMark.o), 2);
  });

  test('balanced AI blocks an immediate opponent win', () {
    const strategy = BalancedAiStrategy();
    final board = TicTacToeBoard.fromCells(const [
      TicTacToeMark.x,
      TicTacToeMark.x,
      null,
      null,
      TicTacToeMark.o,
      null,
      null,
      null,
      null,
    ]);

    expect(strategy.chooseMove(board, TicTacToeMark.o), 2);
  });

  test('balanced AI takes center when there is no immediate line', () {
    const strategy = BalancedAiStrategy();
    final board = TicTacToeBoard.fromCells(const [
      TicTacToeMark.x,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
    ]);

    expect(strategy.chooseMove(board, TicTacToeMark.o), 4);
  });

  test('balanced AI returns null when the board is full', () {
    const strategy = BalancedAiStrategy();
    final board = TicTacToeBoard.fromCells(const [
      TicTacToeMark.x,
      TicTacToeMark.o,
      TicTacToeMark.x,
      TicTacToeMark.x,
      TicTacToeMark.o,
      TicTacToeMark.o,
      TicTacToeMark.o,
      TicTacToeMark.x,
      TicTacToeMark.x,
    ]);

    expect(strategy.chooseMove(board, TicTacToeMark.o), isNull);
  });
}

TicTacToeRound _playMoves(TicTacToeEngine engine, List<int> moves) {
  var round = TicTacToeRound.fresh();

  for (final move in moves) {
    round = engine.playMove(round, move);
  }

  return round;
}
