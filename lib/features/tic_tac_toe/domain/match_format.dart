enum MatchFormat {
  singleRound,
  bestOfThree,
  bestOfFive;

  int get targetWins {
    return switch (this) {
      MatchFormat.singleRound => 1,
      MatchFormat.bestOfThree => 2,
      MatchFormat.bestOfFive => 3,
    };
  }

  String get label {
    return switch (this) {
      MatchFormat.singleRound => 'Single Round',
      MatchFormat.bestOfThree => 'Best of 3',
      MatchFormat.bestOfFive => 'Best of 5',
    };
  }

  String get shortLabel {
    return switch (this) {
      MatchFormat.singleRound => '1 Round',
      MatchFormat.bestOfThree => 'Best 3',
      MatchFormat.bestOfFive => 'Best 5',
    };
  }

  String get setupDescription {
    return switch (this) {
      MatchFormat.singleRound => 'One finished round is saved to history.',
      MatchFormat.bestOfThree => 'First player to 2 wins takes the match.',
      MatchFormat.bestOfFive => 'First player to 3 wins takes the match.',
    };
  }

  String get analyticsName {
    return switch (this) {
      MatchFormat.singleRound => 'single_round',
      MatchFormat.bestOfThree => 'best_of_three',
      MatchFormat.bestOfFive => 'best_of_five',
    };
  }

  String get storageName => name;

  static MatchFormat fromStorageName(String value) {
    return MatchFormat.values.firstWhere(
      (format) => format.storageName == value,
      orElse: () => MatchFormat.singleRound,
    );
  }
}
