import 'round_outcome.dart';
import 'tic_tac_toe_mark.dart';

class GameScore {
  const GameScore({
    required this.xWins,
    required this.oWins,
    required this.draws,
  });

  const GameScore.zero() : this(xWins: 0, oWins: 0, draws: 0);

  final int xWins;
  final int oWins;
  final int draws;

  GameScore record(RoundOutcome outcome) {
    return switch (outcome.status) {
      RoundStatus.playing => this,
      RoundStatus.draw => copyWith(draws: draws + 1),
      RoundStatus.won => switch (outcome.winner) {
        TicTacToeMark.x => copyWith(xWins: xWins + 1),
        TicTacToeMark.o => copyWith(oWins: oWins + 1),
        null => this,
      },
    };
  }

  GameScore copyWith({int? xWins, int? oWins, int? draws}) {
    return GameScore(
      xWins: xWins ?? this.xWins,
      oWins: oWins ?? this.oWins,
      draws: draws ?? this.draws,
    );
  }
}
