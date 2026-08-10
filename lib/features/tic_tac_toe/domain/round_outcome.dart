import 'tic_tac_toe_mark.dart';

enum RoundStatus { playing, won, draw }

class RoundOutcome {
  const RoundOutcome._({
    required this.status,
    this.winner,
    this.winningLine = const [],
  });

  const RoundOutcome.playing() : this._(status: RoundStatus.playing);

  const RoundOutcome.won({
    required TicTacToeMark winner,
    required List<int> winningLine,
  }) : this._(
         status: RoundStatus.won,
         winner: winner,
         winningLine: winningLine,
       );

  const RoundOutcome.draw() : this._(status: RoundStatus.draw);

  final RoundStatus status;
  final TicTacToeMark? winner;
  final List<int> winningLine;

  bool get isOver => status != RoundStatus.playing;
}
