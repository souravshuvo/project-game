import 'dart:convert';

import 'game_engine.dart';

class MatchPreset {
  const MatchPreset({
    required this.id,
    required this.title,
    required this.description,
    required this.rules,
  });

  final String id;
  final String title;
  final String description;
  final GameRules rules;
}

const kPocketPreset = MatchPreset(
  id: 'pocket_over',
  title: 'Pocket Over',
  description: '1 over, 2 wickets. Fast and forgiving.',
  rules: GameRules(maxOvers: 1, maxWickets: 2),
);

const kClassicPreset = MatchPreset(
  id: 'notebook_classic',
  title: 'Notebook Classic',
  description: '2 overs, 3 wickets. The v1 standard.',
  rules: GameRules(maxOvers: 2, maxWickets: 3),
);

const kLongPreset = MatchPreset(
  id: 'long_page',
  title: 'Long Page',
  description: '3 overs, 4 wickets. More room for a comeback.',
  rules: GameRules(maxOvers: 3, maxWickets: 4),
);

const kMatchPresets = <MatchPreset>[
  kPocketPreset,
  kClassicPreset,
  kLongPreset,
];

class GameSetup {
  const GameSetup({
    required this.mode,
    required this.preset,
    this.challenge,
  });

  factory GameSetup.challenge(ChallengeSpec challenge) {
    return GameSetup(
      mode: challenge.mode,
      preset: challenge.preset,
      challenge: challenge,
    );
  }

  final GameMode mode;
  final MatchPreset preset;
  final ChallengeSpec? challenge;

  GameRules get rules => preset.rules;

  String get modeLabel {
    return mode == GameMode.practiceInnings
        ? 'Practice innings'
        : 'Target chase';
  }

  String get title => challenge?.title ?? modeLabel;

  String get detail {
    final challengeDetail = challenge;
    if (challengeDetail != null) {
      return '${challengeDetail.difficulty.label} challenge - ${preset.title}';
    }

    return '${preset.title} - ${preset.description}';
  }
}

enum ChallengeDifficulty {
  beginner('Beginner'),
  steady('Steady'),
  sharp('Sharp');

  const ChallengeDifficulty(this.label);

  final String label;
}

enum ChallengeGoalType {
  completeMatch,
  scoreAtLeast,
  winChase,
  wicketsAtMost,
  extrasAtLeast,
  extrasAtMost,
  boundaryCountAtLeast,
  sixCountAtLeast,
  ballsLeftAtLeast,
  tieMatch,
}

class ChallengeGoal {
  const ChallengeGoal(this.type, {this.value = 0});

  final ChallengeGoalType type;
  final int value;

  String get label {
    return switch (type) {
      ChallengeGoalType.completeMatch => 'Finish the match',
      ChallengeGoalType.scoreAtLeast => 'Score $value+ runs',
      ChallengeGoalType.winChase => 'Win the chase',
      ChallengeGoalType.wicketsAtMost => 'Lose $value or fewer wickets',
      ChallengeGoalType.extrasAtLeast => 'Collect $value+ extras',
      ChallengeGoalType.extrasAtMost => 'Give away $value or fewer extras',
      ChallengeGoalType.boundaryCountAtLeast => 'Hit $value+ boundaries',
      ChallengeGoalType.sixCountAtLeast => 'Hit $value+ sixes',
      ChallengeGoalType.ballsLeftAtLeast => 'Win with $value+ balls left',
      ChallengeGoalType.tieMatch => 'Finish with a tie',
    };
  }

  bool isMet(MatchState state, GameMode mode) {
    if (state.phase != MatchPhase.matchComplete) {
      return false;
    }

    final score = mode == GameMode.practiceInnings
        ? state.firstInnings
        : state.secondInnings;

    return switch (type) {
      ChallengeGoalType.completeMatch => true,
      ChallengeGoalType.scoreAtLeast => score.runs >= value,
      ChallengeGoalType.winChase => _isChaseWin(state),
      ChallengeGoalType.wicketsAtMost => score.wickets <= value,
      ChallengeGoalType.extrasAtLeast => score.extras >= value,
      ChallengeGoalType.extrasAtMost => score.extras <= value,
      ChallengeGoalType.boundaryCountAtLeast =>
        _boundaryCount(state) >= value,
      ChallengeGoalType.sixCountAtLeast => _sixCount(state) >= value,
      ChallengeGoalType.ballsLeftAtLeast =>
        _isChaseWin(state) && state.ballsRemaining >= value,
      ChallengeGoalType.tieMatch => state.matchResult == 'Match tied',
    };
  }

  bool _isChaseWin(MatchState state) {
    return state.mode == GameMode.targetChase &&
        (state.matchResult?.startsWith('Chase won') ?? false);
  }

  int _boundaryCount(MatchState state) {
    return state.deliveries.where((delivery) {
      return delivery.outcome == DeliveryOutcome.four ||
          delivery.outcome == DeliveryOutcome.six;
    }).length;
  }

  int _sixCount(MatchState state) {
    return state.deliveries
        .where((delivery) => delivery.outcome == DeliveryOutcome.six)
        .length;
  }
}

class ChallengeSpec {
  const ChallengeSpec({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.mode,
    required this.preset,
    required this.goals,
  });

  final String id;
  final String title;
  final String description;
  final ChallengeDifficulty difficulty;
  final GameMode mode;
  final MatchPreset preset;
  final List<ChallengeGoal> goals;

  String get goalText => goals.map((goal) => goal.label).join(' - ');

  bool isComplete(MatchState state) {
    return goals.every((goal) => goal.isMet(state, mode));
  }
}

const kChallengeLadder = <ChallengeSpec>[
  ChallengeSpec(
    id: 'first_scribble',
    title: 'First Scribble',
    description: 'Finish a tiny practice innings.',
    difficulty: ChallengeDifficulty.beginner,
    mode: GameMode.practiceInnings,
    preset: kPocketPreset,
    goals: [ChallengeGoal(ChallengeGoalType.completeMatch)],
  ),
  ChallengeSpec(
    id: 'six_marks',
    title: 'Six Marks',
    description: 'Put a small score on the page.',
    difficulty: ChallengeDifficulty.beginner,
    mode: GameMode.practiceInnings,
    preset: kPocketPreset,
    goals: [ChallengeGoal(ChallengeGoalType.scoreAtLeast, value: 6)],
  ),
  ChallengeSpec(
    id: 'keep_it_neat',
    title: 'Keep It Neat',
    description: 'Protect your wickets in a short innings.',
    difficulty: ChallengeDifficulty.beginner,
    mode: GameMode.practiceInnings,
    preset: kPocketPreset,
    goals: [ChallengeGoal(ChallengeGoalType.wicketsAtMost, value: 1)],
  ),
  ChallengeSpec(
    id: 'margin_note',
    title: 'Margin Note',
    description: 'Find one clean boundary.',
    difficulty: ChallengeDifficulty.beginner,
    mode: GameMode.practiceInnings,
    preset: kPocketPreset,
    goals: [ChallengeGoal(ChallengeGoalType.boundaryCountAtLeast, value: 1)],
  ),
  ChallengeSpec(
    id: 'double_digits',
    title: 'Double Digits',
    description: 'Reach a two-digit pocket score.',
    difficulty: ChallengeDifficulty.beginner,
    mode: GameMode.practiceInnings,
    preset: kPocketPreset,
    goals: [ChallengeGoal(ChallengeGoalType.scoreAtLeast, value: 10)],
  ),
  ChallengeSpec(
    id: 'tiny_target',
    title: 'Tiny Target',
    description: 'Complete a one-over target chase.',
    difficulty: ChallengeDifficulty.beginner,
    mode: GameMode.targetChase,
    preset: kPocketPreset,
    goals: [ChallengeGoal(ChallengeGoalType.completeMatch)],
  ),
  ChallengeSpec(
    id: 'pocket_chaser',
    title: 'Pocket Chaser',
    description: 'Win a one-over chase.',
    difficulty: ChallengeDifficulty.beginner,
    mode: GameMode.targetChase,
    preset: kPocketPreset,
    goals: [ChallengeGoal(ChallengeGoalType.winChase)],
  ),
  ChallengeSpec(
    id: 'one_ball_spare',
    title: 'One Ball Spare',
    description: 'Win quickly enough to leave a ball unused.',
    difficulty: ChallengeDifficulty.beginner,
    mode: GameMode.targetChase,
    preset: kPocketPreset,
    goals: [
      ChallengeGoal(ChallengeGoalType.winChase),
      ChallengeGoal(ChallengeGoalType.ballsLeftAtLeast, value: 1),
    ],
  ),
  ChallengeSpec(
    id: 'classic_warmup',
    title: 'Classic Warmup',
    description: 'Finish the standard notebook innings.',
    difficulty: ChallengeDifficulty.steady,
    mode: GameMode.practiceInnings,
    preset: kClassicPreset,
    goals: [ChallengeGoal(ChallengeGoalType.completeMatch)],
  ),
  ChallengeSpec(
    id: 'dozen_desk',
    title: 'Dozen Desk',
    description: 'Build a useful classic score.',
    difficulty: ChallengeDifficulty.steady,
    mode: GameMode.practiceInnings,
    preset: kClassicPreset,
    goals: [ChallengeGoal(ChallengeGoalType.scoreAtLeast, value: 12)],
  ),
  ChallengeSpec(
    id: 'extra_ink',
    title: 'Extra Ink',
    description: 'Turn loose deliveries into runs.',
    difficulty: ChallengeDifficulty.steady,
    mode: GameMode.practiceInnings,
    preset: kClassicPreset,
    goals: [ChallengeGoal(ChallengeGoalType.extrasAtLeast, value: 2)],
  ),
  ChallengeSpec(
    id: 'boundary_pair',
    title: 'Boundary Pair',
    description: 'Find the rope twice.',
    difficulty: ChallengeDifficulty.steady,
    mode: GameMode.practiceInnings,
    preset: kClassicPreset,
    goals: [ChallengeGoal(ChallengeGoalType.boundaryCountAtLeast, value: 2)],
  ),
  ChallengeSpec(
    id: 'six_finder',
    title: 'Six Finder',
    description: 'Land one big hit.',
    difficulty: ChallengeDifficulty.steady,
    mode: GameMode.practiceInnings,
    preset: kClassicPreset,
    goals: [ChallengeGoal(ChallengeGoalType.sixCountAtLeast, value: 1)],
  ),
  ChallengeSpec(
    id: 'classic_chase',
    title: 'Classic Chase',
    description: 'Complete a standard target chase.',
    difficulty: ChallengeDifficulty.steady,
    mode: GameMode.targetChase,
    preset: kClassicPreset,
    goals: [ChallengeGoal(ChallengeGoalType.completeMatch)],
  ),
  ChallengeSpec(
    id: 'chase_calm',
    title: 'Chase Calm',
    description: 'Win a standard chase.',
    difficulty: ChallengeDifficulty.steady,
    mode: GameMode.targetChase,
    preset: kClassicPreset,
    goals: [ChallengeGoal(ChallengeGoalType.winChase)],
  ),
  ChallengeSpec(
    id: 'two_balls_spare',
    title: 'Two Balls Spare',
    description: 'Win a classic chase with time left.',
    difficulty: ChallengeDifficulty.steady,
    mode: GameMode.targetChase,
    preset: kClassicPreset,
    goals: [
      ChallengeGoal(ChallengeGoalType.winChase),
      ChallengeGoal(ChallengeGoalType.ballsLeftAtLeast, value: 2),
    ],
  ),
  ChallengeSpec(
    id: 'long_page_complete',
    title: 'Long Page Complete',
    description: 'Finish the long-form practice innings.',
    difficulty: ChallengeDifficulty.sharp,
    mode: GameMode.practiceInnings,
    preset: kLongPreset,
    goals: [ChallengeGoal(ChallengeGoalType.completeMatch)],
  ),
  ChallengeSpec(
    id: 'twenty_mark',
    title: 'Twenty Mark',
    description: 'Post a confident long-page total.',
    difficulty: ChallengeDifficulty.sharp,
    mode: GameMode.practiceInnings,
    preset: kLongPreset,
    goals: [ChallengeGoal(ChallengeGoalType.scoreAtLeast, value: 20)],
  ),
  ChallengeSpec(
    id: 'boundary_trio',
    title: 'Boundary Trio',
    description: 'Hit three boundaries in one match.',
    difficulty: ChallengeDifficulty.sharp,
    mode: GameMode.practiceInnings,
    preset: kLongPreset,
    goals: [ChallengeGoal(ChallengeGoalType.boundaryCountAtLeast, value: 3)],
  ),
  ChallengeSpec(
    id: 'six_pair',
    title: 'Six Pair',
    description: 'Clear the rope twice.',
    difficulty: ChallengeDifficulty.sharp,
    mode: GameMode.practiceInnings,
    preset: kLongPreset,
    goals: [ChallengeGoal(ChallengeGoalType.sixCountAtLeast, value: 2)],
  ),
  ChallengeSpec(
    id: 'tidy_twenty',
    title: 'Tidy Twenty',
    description: 'Score well without losing the page.',
    difficulty: ChallengeDifficulty.sharp,
    mode: GameMode.practiceInnings,
    preset: kLongPreset,
    goals: [
      ChallengeGoal(ChallengeGoalType.scoreAtLeast, value: 18),
      ChallengeGoal(ChallengeGoalType.wicketsAtMost, value: 2),
    ],
  ),
  ChallengeSpec(
    id: 'long_chase',
    title: 'Long Chase',
    description: 'Complete a long-page chase.',
    difficulty: ChallengeDifficulty.sharp,
    mode: GameMode.targetChase,
    preset: kLongPreset,
    goals: [ChallengeGoal(ChallengeGoalType.completeMatch)],
  ),
  ChallengeSpec(
    id: 'cool_finish',
    title: 'Cool Finish',
    description: 'Win a long chase with room to breathe.',
    difficulty: ChallengeDifficulty.sharp,
    mode: GameMode.targetChase,
    preset: kLongPreset,
    goals: [
      ChallengeGoal(ChallengeGoalType.winChase),
      ChallengeGoal(ChallengeGoalType.ballsLeftAtLeast, value: 3),
    ],
  ),
  ChallengeSpec(
    id: 'pencil_master',
    title: 'Pencil Master',
    description: 'Win big and hit clean in a long chase.',
    difficulty: ChallengeDifficulty.sharp,
    mode: GameMode.targetChase,
    preset: kLongPreset,
    goals: [
      ChallengeGoal(ChallengeGoalType.winChase),
      ChallengeGoal(ChallengeGoalType.scoreAtLeast, value: 20),
      ChallengeGoal(ChallengeGoalType.boundaryCountAtLeast, value: 3),
    ],
  ),
];

class MatchRecord {
  const MatchRecord({
    required this.setupTitle,
    required this.presetTitle,
    required this.mode,
    required this.result,
    required this.firstScore,
    required this.secondScore,
    this.challengeTitle,
  });

  factory MatchRecord.fromMatch({
    required GameSetup setup,
    required MatchState state,
  }) {
    return MatchRecord(
      setupTitle: setup.title,
      presetTitle: setup.preset.title,
      mode: setup.mode,
      result: state.matchResult ?? 'Match complete',
      firstScore:
          '${state.firstInnings.runs}/${state.firstInnings.wickets}',
      secondScore: setup.mode == GameMode.targetChase
          ? '${state.secondInnings.runs}/${state.secondInnings.wickets}'
          : null,
      challengeTitle: setup.challenge?.title,
    );
  }

  factory MatchRecord.fromJson(Map<String, Object?> json) {
    return MatchRecord(
      setupTitle: json['setupTitle'] as String? ?? 'Match',
      presetTitle: json['presetTitle'] as String? ?? 'Preset',
      mode: _modeFromName(json['mode'] as String?),
      result: json['result'] as String? ?? 'Match complete',
      firstScore: json['firstScore'] as String? ?? '0/0',
      secondScore: json['secondScore'] as String?,
      challengeTitle: json['challengeTitle'] as String?,
    );
  }

  final String setupTitle;
  final String presetTitle;
  final GameMode mode;
  final String result;
  final String firstScore;
  final String? secondScore;
  final String? challengeTitle;

  String get scoreLine {
    final chaseScore = secondScore;
    if (chaseScore == null) {
      return firstScore;
    }

    return '$firstScore -> $chaseScore';
  }

  Map<String, Object?> toJson() {
    return {
      'setupTitle': setupTitle,
      'presetTitle': presetTitle,
      'mode': mode.name,
      'result': result,
      'firstScore': firstScore,
      'secondScore': secondScore,
      'challengeTitle': challengeTitle,
    };
  }
}

class GameProgress {
  const GameProgress({
    required this.completedChallengeIds,
    required this.matchesPlayed,
    required this.bestPracticeRuns,
    required this.bestChaseRuns,
    required this.targetChaseWins,
    required this.recentMatches,
  });

  factory GameProgress.initial() {
    return const GameProgress(
      completedChallengeIds: <String>{},
      matchesPlayed: 0,
      bestPracticeRuns: 0,
      bestChaseRuns: 0,
      targetChaseWins: 0,
      recentMatches: <MatchRecord>[],
    );
  }

  factory GameProgress.fromJsonString(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is Map) {
        return GameProgress.fromJson(decoded.cast<String, Object?>());
      }
    } catch (_) {
      return GameProgress.initial();
    }

    return GameProgress.initial();
  }

  factory GameProgress.fromJson(Map<String, Object?> json) {
    final recent = json['recentMatches'];
    return GameProgress(
      completedChallengeIds: Set<String>.from(
        (json['completedChallengeIds'] as List? ?? const <Object?>[])
            .whereType<String>(),
      ),
      matchesPlayed: json['matchesPlayed'] as int? ?? 0,
      bestPracticeRuns: json['bestPracticeRuns'] as int? ?? 0,
      bestChaseRuns: json['bestChaseRuns'] as int? ?? 0,
      targetChaseWins: json['targetChaseWins'] as int? ?? 0,
      recentMatches: recent is List
          ? recent
              .whereType<Map>()
              .map((item) => MatchRecord.fromJson(item.cast<String, Object?>()))
              .toList()
          : const <MatchRecord>[],
    );
  }

  final Set<String> completedChallengeIds;
  final int matchesPlayed;
  final int bestPracticeRuns;
  final int bestChaseRuns;
  final int targetChaseWins;
  final List<MatchRecord> recentMatches;

  int get completedChallengeCount => completedChallengeIds.length;

  ChallengeSpec? get nextChallenge {
    for (final challenge in kChallengeLadder) {
      if (isChallengeUnlocked(challenge) && !isChallengeComplete(challenge)) {
        return challenge;
      }
    }

    return null;
  }

  bool isChallengeComplete(ChallengeSpec challenge) {
    return completedChallengeIds.contains(challenge.id);
  }

  bool isChallengeUnlocked(ChallengeSpec challenge) {
    final index = kChallengeLadder.indexWhere((item) => item.id == challenge.id);
    if (index < 0) {
      return false;
    }

    if (index == 0) {
      return true;
    }

    return kChallengeLadder
        .take(index)
        .every((item) => completedChallengeIds.contains(item.id));
  }

  GameProgress recordMatch({
    required GameSetup setup,
    required MatchState state,
  }) {
    final completedChallenges = {...completedChallengeIds};
    final challenge = setup.challenge;
    if (challenge != null && challenge.isComplete(state)) {
      completedChallenges.add(challenge.id);
    }

    final score = setup.mode == GameMode.practiceInnings
        ? state.firstInnings
        : state.secondInnings;
    final recent = [
      MatchRecord.fromMatch(setup: setup, state: state),
      ...recentMatches,
    ].take(5).toList();

    return GameProgress(
      completedChallengeIds: completedChallenges,
      matchesPlayed: matchesPlayed + 1,
      bestPracticeRuns: setup.mode == GameMode.practiceInnings
          ? _max(bestPracticeRuns, score.runs)
          : bestPracticeRuns,
      bestChaseRuns: setup.mode == GameMode.targetChase
          ? _max(bestChaseRuns, score.runs)
          : bestChaseRuns,
      targetChaseWins: setup.mode == GameMode.targetChase &&
              (state.matchResult?.startsWith('Chase won') ?? false)
          ? targetChaseWins + 1
          : targetChaseWins,
      recentMatches: recent,
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  Map<String, Object?> toJson() {
    final orderedCompletedIds = kChallengeLadder
        .where((challenge) => completedChallengeIds.contains(challenge.id))
        .map((challenge) => challenge.id)
        .toList();

    return {
      'completedChallengeIds': orderedCompletedIds,
      'matchesPlayed': matchesPlayed,
      'bestPracticeRuns': bestPracticeRuns,
      'bestChaseRuns': bestChaseRuns,
      'targetChaseWins': targetChaseWins,
      'recentMatches': recentMatches.map((record) => record.toJson()).toList(),
    };
  }
}

int _max(int a, int b) => a > b ? a : b;

GameMode _modeFromName(String? name) {
  return GameMode.values.firstWhere(
    (mode) => mode.name == name,
    orElse: () => GameMode.targetChase,
  );
}
