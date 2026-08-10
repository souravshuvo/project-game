class LevelScore {
  const LevelScore._();

  static int starsForMoves({required int moves, required int parMoves}) {
    if (moves <= parMoves) {
      return 3;
    }

    final twoStarLimit = (parMoves * 1.25).ceil();
    if (moves <= twoStarLimit) {
      return 2;
    }

    return 1;
  }
}
