import 'game_score.dart';
import 'match_format.dart';
import 'tic_tac_toe_mark.dart';

class MatchRecord {
  const MatchRecord({
    required this.completedAt,
    required this.modeName,
    required this.modeLabel,
    required this.format,
    required this.score,
    required this.winner,
  });

  final DateTime completedAt;
  final String modeName;
  final String modeLabel;
  final MatchFormat format;
  final GameScore score;
  final TicTacToeMark? winner;

  String get resultLabel {
    if (winner == null) {
      return 'Draw';
    }
    if (modeName == 'vs_ai') {
      return winner == TicTacToeMark.x ? 'You won' : 'AI won';
    }

    return 'Player ${winner!.symbol} won';
  }

  String get scoreLabel {
    return '${score.xWins}-${score.oWins}';
  }

  Map<String, Object?> toJson() {
    return {
      'completedAt': completedAt.millisecondsSinceEpoch,
      'modeName': modeName,
      'modeLabel': modeLabel,
      'format': format.storageName,
      'xWins': score.xWins,
      'oWins': score.oWins,
      'draws': score.draws,
      'winner': winner?.symbol,
    };
  }

  static MatchRecord? fromJson(Map<String, Object?> json) {
    final completedAtValue = json['completedAt'];
    final xWins = json['xWins'];
    final oWins = json['oWins'];
    final draws = json['draws'];
    if (completedAtValue is! int ||
        xWins is! int ||
        oWins is! int ||
        draws is! int) {
      return null;
    }

    return MatchRecord(
      completedAt: DateTime.fromMillisecondsSinceEpoch(completedAtValue),
      modeName: json['modeName'] as String? ?? 'local_two_player',
      modeLabel: json['modeLabel'] as String? ?? 'Two Players',
      format: MatchFormat.fromStorageName(json['format'] as String? ?? ''),
      score: GameScore(xWins: xWins, oWins: oWins, draws: draws),
      winner: _winnerFromSymbol(json['winner'] as String?),
    );
  }

  static TicTacToeMark? _winnerFromSymbol(String? value) {
    return switch (value) {
      'X' => TicTacToeMark.x,
      'O' => TicTacToeMark.o,
      _ => null,
    };
  }
}
