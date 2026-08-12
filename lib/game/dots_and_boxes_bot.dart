import 'dots_and_boxes.dart';

enum BotDifficulty {
  casual,
  tactical;

  String get label {
    return switch (this) {
      BotDifficulty.casual => 'Casual',
      BotDifficulty.tactical => 'Tactical',
    };
  }

  String get description {
    return switch (this) {
      BotDifficulty.casual => 'Takes captures, otherwise plays simply.',
      BotDifficulty.tactical => 'Takes captures and avoids easy giveaways.',
    };
  }
}

class DotsAndBoxesBot {
  const DotsAndBoxesBot({required this.difficulty});

  final BotDifficulty difficulty;

  BoardLine? chooseMove(DotsAndBoxesGame game) {
    final openLines = game.openLines;
    if (openLines.isEmpty || game.isGameOver) {
      return null;
    }

    return switch (difficulty) {
      BotDifficulty.casual => _chooseCasualMove(game, openLines),
      BotDifficulty.tactical => _chooseTacticalMove(game, openLines),
    };
  }

  BoardLine _chooseCasualMove(
    DotsAndBoxesGame game,
    List<BoardLine> openLines,
  ) {
    return _bestScoringMove(game, openLines) ?? openLines.first;
  }

  BoardLine _chooseTacticalMove(
    DotsAndBoxesGame game,
    List<BoardLine> openLines,
  ) {
    final scoringMove = _bestScoringMove(game, openLines);
    if (scoringMove != null) {
      return scoringMove;
    }

    final safeMoves = openLines.where((line) {
      return _opponentCaptureOpportunitiesAfter(game, line) == 0;
    }).toList();
    if (safeMoves.isNotEmpty) {
      return safeMoves.first;
    }

    final rankedMoves = [...openLines]
      ..sort((a, b) {
        return _opponentCaptureOpportunitiesAfter(
          game,
          a,
        ).compareTo(_opponentCaptureOpportunitiesAfter(game, b));
      });
    return rankedMoves.first;
  }

  BoardLine? _bestScoringMove(
    DotsAndBoxesGame game,
    List<BoardLine> openLines,
  ) {
    BoardLine? bestLine;
    var bestScore = 0;

    for (final line in openLines) {
      final score = game.completedBoxesForLine(line);
      if (score > bestScore) {
        bestScore = score;
        bestLine = line;
      }
    }

    return bestScore > 0 ? bestLine : null;
  }

  int _opponentCaptureOpportunitiesAfter(
    DotsAndBoxesGame game,
    BoardLine line,
  ) {
    var opportunities = 0;

    for (final box in game.boxesAdjacentTo(line)) {
      if (game.claimedBoxes.containsKey(box)) {
        continue;
      }

      final sidesAfterMove = game.drawnSideCountForBox(box) + 1;
      if (sidesAfterMove == 3) {
        opportunities += 1;
      }
    }

    return opportunities;
  }
}
