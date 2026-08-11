import 'dart:math';

enum DeliveryOutcome { dot, one, two, three, four, six, wicket, wide, noBall }

extension DeliveryOutcomeInfo on DeliveryOutcome {
  String get wheelLabel {
    return switch (this) {
      DeliveryOutcome.dot => '0',
      DeliveryOutcome.one => '1',
      DeliveryOutcome.two => '2',
      DeliveryOutcome.three => '3',
      DeliveryOutcome.four => '4',
      DeliveryOutcome.six => '6',
      DeliveryOutcome.wicket => 'W',
      DeliveryOutcome.wide => 'Wd',
      DeliveryOutcome.noBall => 'Nb',
    };
  }

  String get resultLabel {
    return switch (this) {
      DeliveryOutcome.dot => 'Dot ball',
      DeliveryOutcome.one => '1 run',
      DeliveryOutcome.two => '2 runs',
      DeliveryOutcome.three => '3 runs',
      DeliveryOutcome.four => 'Four',
      DeliveryOutcome.six => 'Six',
      DeliveryOutcome.wicket => 'Wicket',
      DeliveryOutcome.wide => 'Wide +1',
      DeliveryOutcome.noBall => 'No-ball +1',
    };
  }

  String get resultDetail {
    return switch (this) {
      DeliveryOutcome.dot => 'No run. One legal ball used.',
      DeliveryOutcome.one => 'Rotated the strike. One legal ball used.',
      DeliveryOutcome.two => 'Good running. One legal ball used.',
      DeliveryOutcome.three => 'Hard sprint. One legal ball used.',
      DeliveryOutcome.four => 'Clean boundary. One legal ball used.',
      DeliveryOutcome.six => 'Cleared the rope. One legal ball used.',
      DeliveryOutcome.wicket => 'Out. One legal ball used.',
      DeliveryOutcome.wide => 'Extra added. Legal ball is replayed.',
      DeliveryOutcome.noBall => 'Extra added. Legal ball is replayed.',
    };
  }

  int get runs {
    return switch (this) {
      DeliveryOutcome.dot || DeliveryOutcome.wicket => 0,
      DeliveryOutcome.one ||
      DeliveryOutcome.wide ||
      DeliveryOutcome.noBall => 1,
      DeliveryOutcome.two => 2,
      DeliveryOutcome.three => 3,
      DeliveryOutcome.four => 4,
      DeliveryOutcome.six => 6,
    };
  }

  int get extras {
    return switch (this) {
      DeliveryOutcome.wide || DeliveryOutcome.noBall => 1,
      _ => 0,
    };
  }

  bool get isLegalDelivery {
    return this != DeliveryOutcome.wide && this != DeliveryOutcome.noBall;
  }

  bool get isWicket {
    return this == DeliveryOutcome.wicket;
  }
}

class SpinWheelModel {
  const SpinWheelModel._();

  static const segments = <DeliveryOutcome>[
    DeliveryOutcome.dot,
    DeliveryOutcome.one,
    DeliveryOutcome.four,
    DeliveryOutcome.wicket,
    DeliveryOutcome.two,
    DeliveryOutcome.wide,
    DeliveryOutcome.six,
    DeliveryOutcome.dot,
    DeliveryOutcome.one,
    DeliveryOutcome.noBall,
    DeliveryOutcome.three,
    DeliveryOutcome.four,
    DeliveryOutcome.wicket,
    DeliveryOutcome.two,
  ];

  static int nextSegmentIndex(Random random) {
    return random.nextInt(segments.length);
  }
}

enum GameMode { practiceInnings, targetChase }

enum MatchPhase { firstInnings, inningsBreak, secondInnings, matchComplete }

class GameRules {
  const GameRules({this.maxOvers = 2, this.maxWickets = 3})
    : assert(maxOvers > 0),
      assert(maxWickets > 0);

  final int maxOvers;
  final int maxWickets;

  int get maxLegalBalls => maxOvers * 6;

  String get oversLimitLabel => '$maxOvers.0';
}

class InningsScore {
  const InningsScore({
    this.runs = 0,
    this.wickets = 0,
    this.legalBalls = 0,
    this.extras = 0,
  });

  final int runs;
  final int wickets;
  final int legalBalls;
  final int extras;

  String get oversLabel => '${legalBalls ~/ 6}.${legalBalls % 6}';

  bool isComplete(GameRules rules) {
    return legalBalls >= rules.maxLegalBalls || wickets >= rules.maxWickets;
  }

  InningsScore copyWith({
    int? runs,
    int? wickets,
    int? legalBalls,
    int? extras,
  }) {
    return InningsScore(
      runs: runs ?? this.runs,
      wickets: wickets ?? this.wickets,
      legalBalls: legalBalls ?? this.legalBalls,
      extras: extras ?? this.extras,
    );
  }
}

class DeliveryResult {
  const DeliveryResult({
    required this.outcome,
    required this.runsAdded,
    required this.extrasAdded,
    required this.consumedLegalBall,
    required this.tookWicket,
    required this.phaseAfter,
    required this.title,
    required this.detail,
  });

  final DeliveryOutcome outcome;
  final int runsAdded;
  final int extrasAdded;
  final bool consumedLegalBall;
  final bool tookWicket;
  final MatchPhase phaseAfter;
  final String title;
  final String detail;
}

class MatchState {
  const MatchState({
    required this.mode,
    required this.rules,
    required this.phase,
    required this.firstInnings,
    required this.secondInnings,
    this.target,
    this.lastDelivery,
  });

  factory MatchState.initial({
    required GameMode mode,
    required GameRules rules,
  }) {
    return MatchState(
      mode: mode,
      rules: rules,
      phase: MatchPhase.firstInnings,
      firstInnings: const InningsScore(),
      secondInnings: const InningsScore(),
    );
  }

  final GameMode mode;
  final GameRules rules;
  final MatchPhase phase;
  final InningsScore firstInnings;
  final InningsScore secondInnings;
  final int? target;
  final DeliveryResult? lastDelivery;

  bool get canPlayDelivery {
    return phase == MatchPhase.firstInnings ||
        phase == MatchPhase.secondInnings;
  }

  InningsScore get activeScore {
    if (phase == MatchPhase.secondInnings) {
      return secondInnings;
    }

    if (phase == MatchPhase.matchComplete && mode == GameMode.targetChase) {
      return secondInnings;
    }

    return firstInnings;
  }

  int get inningsNumber {
    return phase == MatchPhase.secondInnings ||
            (phase == MatchPhase.matchComplete && mode == GameMode.targetChase)
        ? 2
        : 1;
  }

  int get ballsRemaining {
    return max(0, rules.maxLegalBalls - activeScore.legalBalls);
  }

  int? get runsNeeded {
    final chaseTarget = target;
    if (phase != MatchPhase.secondInnings || chaseTarget == null) {
      return null;
    }

    return max(0, chaseTarget - secondInnings.runs);
  }

  String? get matchResult {
    if (phase == MatchPhase.matchComplete &&
        mode == GameMode.practiceInnings) {
      return 'Practice complete: ${firstInnings.runs}/${firstInnings.wickets}';
    }

    final chaseTarget = target;
    if (phase != MatchPhase.matchComplete || chaseTarget == null) {
      return null;
    }

    if (secondInnings.runs >= chaseTarget) {
      final wicketsLeft = rules.maxWickets - secondInnings.wickets;
      return 'Chase won by ${_pluralize(wicketsLeft, 'wicket')}';
    }

    final tyingScore = chaseTarget - 1;
    if (secondInnings.runs == tyingScore) {
      return 'Match tied';
    }

    return 'Defended by ${_pluralize(tyingScore - secondInnings.runs, 'run')}';
  }

  MatchState copyWith({
    GameMode? mode,
    MatchPhase? phase,
    InningsScore? firstInnings,
    InningsScore? secondInnings,
    int? target,
    DeliveryResult? lastDelivery,
  }) {
    return MatchState(
      mode: mode ?? this.mode,
      rules: rules,
      phase: phase ?? this.phase,
      firstInnings: firstInnings ?? this.firstInnings,
      secondInnings: secondInnings ?? this.secondInnings,
      target: target ?? this.target,
      lastDelivery: lastDelivery ?? this.lastDelivery,
    );
  }
}

class CricketMatch {
  CricketMatch({
    GameMode mode = GameMode.targetChase,
    GameRules rules = const GameRules(),
  })  : _mode = mode,
        _rules = rules,
        state = MatchState.initial(mode: mode, rules: rules);

  final GameMode _mode;
  final GameRules _rules;

  MatchState state;

  void restart() {
    state = MatchState.initial(mode: _mode, rules: _rules);
  }

  void startChase() {
    if (state.mode != GameMode.targetChase) {
      throw StateError('Practice innings do not have a chase.');
    }

    if (state.phase != MatchPhase.inningsBreak) {
      throw StateError('The chase can only start from the innings break.');
    }

    state = state.copyWith(phase: MatchPhase.secondInnings);
  }

  DeliveryResult deliver(DeliveryOutcome outcome) {
    if (!state.canPlayDelivery) {
      throw StateError('Cannot deliver while the match is not live.');
    }

    final score = state.activeScore;
    final updatedScore = _applyOutcome(score, outcome);
    var nextPhase = state.phase;
    var nextTarget = state.target;

    if (state.phase == MatchPhase.firstInnings) {
      if (updatedScore.isComplete(_rules)) {
        if (state.mode == GameMode.practiceInnings) {
          nextPhase = MatchPhase.matchComplete;
        } else {
          nextPhase = MatchPhase.inningsBreak;
          nextTarget = updatedScore.runs + 1;
        }
      }

      state = state.copyWith(
        phase: nextPhase,
        firstInnings: updatedScore,
        target: nextTarget,
      );
    } else {
      final chaseTarget = state.target;
      if (chaseTarget == null) {
        throw StateError('A chase cannot start without a target.');
      }

      if (updatedScore.runs >= chaseTarget || updatedScore.isComplete(_rules)) {
        nextPhase = MatchPhase.matchComplete;
      }

      state = state.copyWith(phase: nextPhase, secondInnings: updatedScore);
    }

    final deliveryResult = DeliveryResult(
      outcome: outcome,
      runsAdded: outcome.runs,
      extrasAdded: outcome.extras,
      consumedLegalBall: outcome.isLegalDelivery,
      tookWicket: outcome.isWicket,
      phaseAfter: nextPhase,
      title: outcome.resultLabel,
      detail: _detailFor(outcome, nextPhase, nextTarget),
    );

    state = state.copyWith(lastDelivery: deliveryResult);
    return deliveryResult;
  }

  InningsScore _applyOutcome(InningsScore score, DeliveryOutcome outcome) {
    final nextLegalBalls = outcome.isLegalDelivery
        ? min(score.legalBalls + 1, _rules.maxLegalBalls)
        : score.legalBalls;
    final nextWickets = outcome.isWicket
        ? min(score.wickets + 1, _rules.maxWickets)
        : score.wickets;

    return score.copyWith(
      runs: score.runs + outcome.runs,
      wickets: nextWickets,
      legalBalls: nextLegalBalls,
      extras: score.extras + outcome.extras,
    );
  }

  String _detailFor(
    DeliveryOutcome outcome,
    MatchPhase nextPhase,
    int? nextTarget,
  ) {
    if (nextPhase == MatchPhase.inningsBreak && nextTarget != null) {
      return 'Innings complete. Target $nextTarget.';
    }

    if (nextPhase == MatchPhase.matchComplete) {
      return state.matchResult ?? outcome.resultDetail;
    }

    return outcome.resultDetail;
  }
}

String _pluralize(int count, String noun) {
  return '$count $noun${count == 1 ? '' : 's'}';
}
