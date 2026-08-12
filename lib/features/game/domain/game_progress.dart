import 'dart:math';

import 'game_content.dart';
import 'game_models.dart';

const int maxSavedMatchHistory = 10;

enum ChallengeMetric {
  matchesPlayed,
  matchesWon,
  roundsPlayed,
  bestMatchScore,
  totalHumanScore,
  humanPoliceCorrect,
  humanThiefEscapes,
  kingRounds,
  ministerRounds,
  policeRounds,
  thiefRounds,
  quickWins,
  classicWins,
  festivalWins,
  bestWinStreak,
  perfectPoliceMatches,
  undefeatedThiefMatches,
}

class ChallengeDefinition {
  const ChallengeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.metric,
    required this.target,
  });

  final String id;
  final String title;
  final String description;
  final ChallengeMetric metric;
  final int target;

  int currentValue(GameProgress progress) {
    return progress.valueFor(metric);
  }

  bool isUnlocked(GameProgress progress) {
    return currentValue(progress) >= target;
  }
}

const List<ChallengeDefinition> gameChallenges = <ChallengeDefinition>[
  ChallengeDefinition(
    id: 'first_table',
    title: 'First Table',
    description: 'Finish 1 match.',
    metric: ChallengeMetric.matchesPlayed,
    target: 1,
  ),
  ChallengeDefinition(
    id: 'table_regular',
    title: 'Table Regular',
    description: 'Finish 3 matches.',
    metric: ChallengeMetric.matchesPlayed,
    target: 3,
  ),
  ChallengeDefinition(
    id: 'weekend_table',
    title: 'Weekend Table',
    description: 'Finish 10 matches.',
    metric: ChallengeMetric.matchesPlayed,
    target: 10,
  ),
  ChallengeDefinition(
    id: 'round_runner',
    title: 'Round Runner',
    description: 'Play 25 rounds.',
    metric: ChallengeMetric.roundsPlayed,
    target: 25,
  ),
  ChallengeDefinition(
    id: 'first_win',
    title: 'First Win',
    description: 'Win 1 match.',
    metric: ChallengeMetric.matchesWon,
    target: 1,
  ),
  ChallengeDefinition(
    id: 'hat_trick',
    title: 'Hat Trick',
    description: 'Win 3 matches.',
    metric: ChallengeMetric.matchesWon,
    target: 3,
  ),
  ChallengeDefinition(
    id: 'crown_run',
    title: 'Crown Run',
    description: 'Win 5 matches.',
    metric: ChallengeMetric.matchesWon,
    target: 5,
  ),
  ChallengeDefinition(
    id: 'quick_crown',
    title: 'Quick Crown',
    description: 'Win a Quick match.',
    metric: ChallengeMetric.quickWins,
    target: 1,
  ),
  ChallengeDefinition(
    id: 'classic_crown',
    title: 'Classic Crown',
    description: 'Win a Classic match.',
    metric: ChallengeMetric.classicWins,
    target: 1,
  ),
  ChallengeDefinition(
    id: 'festival_crown',
    title: 'Festival Crown',
    description: 'Win a Festival match.',
    metric: ChallengeMetric.festivalWins,
    target: 1,
  ),
  ChallengeDefinition(
    id: 'first_catch',
    title: 'First Catch',
    description: 'Catch the Thief once as Police.',
    metric: ChallengeMetric.humanPoliceCorrect,
    target: 1,
  ),
  ChallengeDefinition(
    id: 'sharp_badge',
    title: 'Sharp Badge',
    description: 'Catch the Thief 3 times as Police.',
    metric: ChallengeMetric.humanPoliceCorrect,
    target: 3,
  ),
  ChallengeDefinition(
    id: 'super_sleuth',
    title: 'Super Sleuth',
    description: 'Catch the Thief 5 times as Police.',
    metric: ChallengeMetric.humanPoliceCorrect,
    target: 5,
  ),
  ChallengeDefinition(
    id: 'first_escape',
    title: 'First Escape',
    description: 'Escape once as Thief.',
    metric: ChallengeMetric.humanThiefEscapes,
    target: 1,
  ),
  ChallengeDefinition(
    id: 'shadow_steps',
    title: 'Shadow Steps',
    description: 'Escape 3 times as Thief.',
    metric: ChallengeMetric.humanThiefEscapes,
    target: 3,
  ),
  ChallengeDefinition(
    id: 'silent_ninja',
    title: 'Silent Ninja',
    description: 'Escape 5 times as Thief.',
    metric: ChallengeMetric.humanThiefEscapes,
    target: 5,
  ),
  ChallengeDefinition(
    id: 'royal_visit',
    title: 'Royal Visit',
    description: 'Receive King 5 times.',
    metric: ChallengeMetric.kingRounds,
    target: 5,
  ),
  ChallengeDefinition(
    id: 'wise_rounds',
    title: 'Wise Rounds',
    description: 'Receive Minister 5 times.',
    metric: ChallengeMetric.ministerRounds,
    target: 5,
  ),
  ChallengeDefinition(
    id: 'badge_duty',
    title: 'Badge Duty',
    description: 'Receive Police 5 times.',
    metric: ChallengeMetric.policeRounds,
    target: 5,
  ),
  ChallengeDefinition(
    id: 'sneaky_seat',
    title: 'Sneaky Seat',
    description: 'Receive Thief 5 times.',
    metric: ChallengeMetric.thiefRounds,
    target: 5,
  ),
  ChallengeDefinition(
    id: 'big_score',
    title: 'Big Score',
    description: 'Score 3000 in one match.',
    metric: ChallengeMetric.bestMatchScore,
    target: 3000,
  ),
  ChallengeDefinition(
    id: 'festival_score',
    title: 'Festival Score',
    description: 'Score 5000 in one match.',
    metric: ChallengeMetric.bestMatchScore,
    target: 5000,
  ),
  ChallengeDefinition(
    id: 'perfect_badge',
    title: 'Perfect Badge',
    description: 'Make every Police guess correct in a match.',
    metric: ChallengeMetric.perfectPoliceMatches,
    target: 1,
  ),
  ChallengeDefinition(
    id: 'clean_escape',
    title: 'Clean Escape',
    description: 'Escape every Thief round in a match.',
    metric: ChallengeMetric.undefeatedThiefMatches,
    target: 1,
  ),
];

class MatchHistoryEntry {
  const MatchHistoryEntry({
    required this.completedAt,
    required this.presetId,
    required this.presetLabel,
    required this.rounds,
    required this.botStyleId,
    required this.botStyleLabel,
    required this.humanScore,
    required this.winnerName,
    required this.humanRank,
    required this.policeCorrectGuesses,
    required this.policeAttempts,
  });

  final DateTime completedAt;
  final String presetId;
  final String presetLabel;
  final int rounds;
  final String botStyleId;
  final String botStyleLabel;
  final int humanScore;
  final String winnerName;
  final int humanRank;
  final int policeCorrectGuesses;
  final int policeAttempts;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'completedAt': completedAt.toIso8601String(),
      'presetId': presetId,
      'presetLabel': presetLabel,
      'rounds': rounds,
      'botStyleId': botStyleId,
      'botStyleLabel': botStyleLabel,
      'humanScore': humanScore,
      'winnerName': winnerName,
      'humanRank': humanRank,
      'policeCorrectGuesses': policeCorrectGuesses,
      'policeAttempts': policeAttempts,
    };
  }

  factory MatchHistoryEntry.fromJson(Map<String, Object?> json) {
    return MatchHistoryEntry(
      completedAt:
          DateTime.tryParse(_stringValue(json['completedAt'])) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      presetId: _stringValue(json['presetId'], fallback: 'quick'),
      presetLabel: _stringValue(json['presetLabel'], fallback: 'Quick'),
      rounds: _intValue(json['rounds']),
      botStyleId: _stringValue(
        json['botStyleId'],
        fallback: BotGuessStyle.fairRandom.id,
      ),
      botStyleLabel: _stringValue(
        json['botStyleLabel'],
        fallback: BotGuessStyle.fairRandom.label,
      ),
      humanScore: _intValue(json['humanScore']),
      winnerName: _stringValue(json['winnerName'], fallback: 'Unknown'),
      humanRank: _intValue(json['humanRank'], fallback: 4),
      policeCorrectGuesses: _intValue(json['policeCorrectGuesses']),
      policeAttempts: _intValue(json['policeAttempts']),
    );
  }
}

class GameProgress {
  const GameProgress({
    required this.matchesPlayed,
    required this.matchesWon,
    required this.roundsPlayed,
    required this.totalHumanScore,
    required this.bestMatchScore,
    required this.humanPoliceCorrect,
    required this.humanPoliceAttempts,
    required this.humanThiefEscapes,
    required this.humanThiefRounds,
    required this.kingRounds,
    required this.ministerRounds,
    required this.policeRounds,
    required this.thiefRounds,
    required this.quickWins,
    required this.classicWins,
    required this.festivalWins,
    required this.currentWinStreak,
    required this.bestWinStreak,
    required this.perfectPoliceMatches,
    required this.undefeatedThiefMatches,
    required this.unlockedChallengeIds,
    required this.history,
  });

  factory GameProgress.empty() {
    return const GameProgress(
      matchesPlayed: 0,
      matchesWon: 0,
      roundsPlayed: 0,
      totalHumanScore: 0,
      bestMatchScore: 0,
      humanPoliceCorrect: 0,
      humanPoliceAttempts: 0,
      humanThiefEscapes: 0,
      humanThiefRounds: 0,
      kingRounds: 0,
      ministerRounds: 0,
      policeRounds: 0,
      thiefRounds: 0,
      quickWins: 0,
      classicWins: 0,
      festivalWins: 0,
      currentWinStreak: 0,
      bestWinStreak: 0,
      perfectPoliceMatches: 0,
      undefeatedThiefMatches: 0,
      unlockedChallengeIds: <String>{},
      history: <MatchHistoryEntry>[],
    );
  }

  factory GameProgress.fromJson(Map<String, Object?> json) {
    return GameProgress(
      matchesPlayed: _intValue(json['matchesPlayed']),
      matchesWon: _intValue(json['matchesWon']),
      roundsPlayed: _intValue(json['roundsPlayed']),
      totalHumanScore: _intValue(json['totalHumanScore']),
      bestMatchScore: _intValue(json['bestMatchScore']),
      humanPoliceCorrect: _intValue(json['humanPoliceCorrect']),
      humanPoliceAttempts: _intValue(json['humanPoliceAttempts']),
      humanThiefEscapes: _intValue(json['humanThiefEscapes']),
      humanThiefRounds: _intValue(json['humanThiefRounds']),
      kingRounds: _intValue(json['kingRounds']),
      ministerRounds: _intValue(json['ministerRounds']),
      policeRounds: _intValue(json['policeRounds']),
      thiefRounds: _intValue(json['thiefRounds']),
      quickWins: _intValue(json['quickWins']),
      classicWins: _intValue(json['classicWins']),
      festivalWins: _intValue(json['festivalWins']),
      currentWinStreak: _intValue(json['currentWinStreak']),
      bestWinStreak: _intValue(json['bestWinStreak']),
      perfectPoliceMatches: _intValue(json['perfectPoliceMatches']),
      undefeatedThiefMatches: _intValue(json['undefeatedThiefMatches']),
      unlockedChallengeIds: _stringSet(json['unlockedChallengeIds']),
      history: _historyList(json['history']),
    );
  }

  final int matchesPlayed;
  final int matchesWon;
  final int roundsPlayed;
  final int totalHumanScore;
  final int bestMatchScore;
  final int humanPoliceCorrect;
  final int humanPoliceAttempts;
  final int humanThiefEscapes;
  final int humanThiefRounds;
  final int kingRounds;
  final int ministerRounds;
  final int policeRounds;
  final int thiefRounds;
  final int quickWins;
  final int classicWins;
  final int festivalWins;
  final int currentWinStreak;
  final int bestWinStreak;
  final int perfectPoliceMatches;
  final int undefeatedThiefMatches;
  final Set<String> unlockedChallengeIds;
  final List<MatchHistoryEntry> history;

  int get unlockedChallengeCount => unlockedChallengeIds.length;

  int valueFor(ChallengeMetric metric) {
    switch (metric) {
      case ChallengeMetric.matchesPlayed:
        return matchesPlayed;
      case ChallengeMetric.matchesWon:
        return matchesWon;
      case ChallengeMetric.roundsPlayed:
        return roundsPlayed;
      case ChallengeMetric.bestMatchScore:
        return bestMatchScore;
      case ChallengeMetric.totalHumanScore:
        return totalHumanScore;
      case ChallengeMetric.humanPoliceCorrect:
        return humanPoliceCorrect;
      case ChallengeMetric.humanThiefEscapes:
        return humanThiefEscapes;
      case ChallengeMetric.kingRounds:
        return kingRounds;
      case ChallengeMetric.ministerRounds:
        return ministerRounds;
      case ChallengeMetric.policeRounds:
        return policeRounds;
      case ChallengeMetric.thiefRounds:
        return thiefRounds;
      case ChallengeMetric.quickWins:
        return quickWins;
      case ChallengeMetric.classicWins:
        return classicWins;
      case ChallengeMetric.festivalWins:
        return festivalWins;
      case ChallengeMetric.bestWinStreak:
        return bestWinStreak;
      case ChallengeMetric.perfectPoliceMatches:
        return perfectPoliceMatches;
      case ChallengeMetric.undefeatedThiefMatches:
        return undefeatedThiefMatches;
    }
  }

  GameProgress copyWith({
    int? matchesPlayed,
    int? matchesWon,
    int? roundsPlayed,
    int? totalHumanScore,
    int? bestMatchScore,
    int? humanPoliceCorrect,
    int? humanPoliceAttempts,
    int? humanThiefEscapes,
    int? humanThiefRounds,
    int? kingRounds,
    int? ministerRounds,
    int? policeRounds,
    int? thiefRounds,
    int? quickWins,
    int? classicWins,
    int? festivalWins,
    int? currentWinStreak,
    int? bestWinStreak,
    int? perfectPoliceMatches,
    int? undefeatedThiefMatches,
    Set<String>? unlockedChallengeIds,
    List<MatchHistoryEntry>? history,
  }) {
    return GameProgress(
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      matchesWon: matchesWon ?? this.matchesWon,
      roundsPlayed: roundsPlayed ?? this.roundsPlayed,
      totalHumanScore: totalHumanScore ?? this.totalHumanScore,
      bestMatchScore: bestMatchScore ?? this.bestMatchScore,
      humanPoliceCorrect: humanPoliceCorrect ?? this.humanPoliceCorrect,
      humanPoliceAttempts: humanPoliceAttempts ?? this.humanPoliceAttempts,
      humanThiefEscapes: humanThiefEscapes ?? this.humanThiefEscapes,
      humanThiefRounds: humanThiefRounds ?? this.humanThiefRounds,
      kingRounds: kingRounds ?? this.kingRounds,
      ministerRounds: ministerRounds ?? this.ministerRounds,
      policeRounds: policeRounds ?? this.policeRounds,
      thiefRounds: thiefRounds ?? this.thiefRounds,
      quickWins: quickWins ?? this.quickWins,
      classicWins: classicWins ?? this.classicWins,
      festivalWins: festivalWins ?? this.festivalWins,
      currentWinStreak: currentWinStreak ?? this.currentWinStreak,
      bestWinStreak: bestWinStreak ?? this.bestWinStreak,
      perfectPoliceMatches: perfectPoliceMatches ?? this.perfectPoliceMatches,
      undefeatedThiefMatches:
          undefeatedThiefMatches ?? this.undefeatedThiefMatches,
      unlockedChallengeIds: unlockedChallengeIds ?? this.unlockedChallengeIds,
      history: history ?? this.history,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'matchesPlayed': matchesPlayed,
      'matchesWon': matchesWon,
      'roundsPlayed': roundsPlayed,
      'totalHumanScore': totalHumanScore,
      'bestMatchScore': bestMatchScore,
      'humanPoliceCorrect': humanPoliceCorrect,
      'humanPoliceAttempts': humanPoliceAttempts,
      'humanThiefEscapes': humanThiefEscapes,
      'humanThiefRounds': humanThiefRounds,
      'kingRounds': kingRounds,
      'ministerRounds': ministerRounds,
      'policeRounds': policeRounds,
      'thiefRounds': thiefRounds,
      'quickWins': quickWins,
      'classicWins': classicWins,
      'festivalWins': festivalWins,
      'currentWinStreak': currentWinStreak,
      'bestWinStreak': bestWinStreak,
      'perfectPoliceMatches': perfectPoliceMatches,
      'undefeatedThiefMatches': undefeatedThiefMatches,
      'unlockedChallengeIds': unlockedChallengeIds.toList(growable: false),
      'history': <Map<String, Object?>>[
        for (final entry in history) entry.toJson(),
      ],
    };
  }
}

class MatchProgressUpdate {
  const MatchProgressUpdate({
    required this.progress,
    required this.entry,
    required this.newUnlocks,
  });

  final GameProgress progress;
  final MatchHistoryEntry entry;
  final List<ChallengeDefinition> newUnlocks;
}

MatchProgressUpdate recordCompletedMatch({
  required GameProgress current,
  required List<GamePlayer> players,
  required List<GameRound> rounds,
  required Map<String, int> totals,
  required String humanPlayerId,
  required MatchPreset preset,
  required BotGuessStyle botGuessStyle,
  DateTime? completedAt,
}) {
  final humanScore = totals[humanPlayerId] ?? 0;
  final topScore = totals.values.fold<int>(0, max);
  final humanWon = humanScore >= topScore;
  final humanRank =
      1 + totals.values.where((score) => score > humanScore).length;
  final rankedPlayers = List<GamePlayer>.of(players)
    ..sort((a, b) {
      final scoreCompare = (totals[b.id] ?? 0).compareTo(totals[a.id] ?? 0);
      if (scoreCompare != 0) {
        return scoreCompare;
      }
      return a.seatIndex.compareTo(b.seatIndex);
    });
  final winnerName = rankedPlayers.isEmpty
      ? 'Unknown'
      : rankedPlayers.first.name;

  var matchHumanPoliceAttempts = 0;
  var matchHumanPoliceCorrect = 0;
  var matchHumanThiefRounds = 0;
  var matchHumanThiefEscapes = 0;
  var matchKingRounds = 0;
  var matchMinisterRounds = 0;
  var matchPoliceRounds = 0;
  var matchThiefRounds = 0;

  for (final round in rounds) {
    final humanRole = round.assignments[humanPlayerId];
    switch (humanRole) {
      case GameRole.king:
        matchKingRounds += 1;
      case GameRole.minister:
        matchMinisterRounds += 1;
      case GameRole.police:
        matchPoliceRounds += 1;
        matchHumanPoliceAttempts += 1;
        if (round.result.wasCorrect) {
          matchHumanPoliceCorrect += 1;
        }
      case GameRole.thief:
        matchThiefRounds += 1;
        matchHumanThiefRounds += 1;
        if (!round.result.wasCorrect) {
          matchHumanThiefEscapes += 1;
        }
      case null:
        break;
    }
  }

  final currentWinStreak = humanWon ? current.currentWinStreak + 1 : 0;
  final entry = MatchHistoryEntry(
    completedAt: completedAt ?? DateTime.now(),
    presetId: preset.id,
    presetLabel: preset.label,
    rounds: rounds.length,
    botStyleId: botGuessStyle.id,
    botStyleLabel: botGuessStyle.label,
    humanScore: humanScore,
    winnerName: winnerName,
    humanRank: humanRank,
    policeCorrectGuesses: matchHumanPoliceCorrect,
    policeAttempts: matchHumanPoliceAttempts,
  );

  final history = <MatchHistoryEntry>[
    entry,
    ...current.history,
  ].take(maxSavedMatchHistory).toList(growable: false);
  final updatedWithoutUnlocks = current.copyWith(
    matchesPlayed: current.matchesPlayed + 1,
    matchesWon: current.matchesWon + (humanWon ? 1 : 0),
    roundsPlayed: current.roundsPlayed + rounds.length,
    totalHumanScore: current.totalHumanScore + humanScore,
    bestMatchScore: max(current.bestMatchScore, humanScore),
    humanPoliceCorrect: current.humanPoliceCorrect + matchHumanPoliceCorrect,
    humanPoliceAttempts: current.humanPoliceAttempts + matchHumanPoliceAttempts,
    humanThiefEscapes: current.humanThiefEscapes + matchHumanThiefEscapes,
    humanThiefRounds: current.humanThiefRounds + matchHumanThiefRounds,
    kingRounds: current.kingRounds + matchKingRounds,
    ministerRounds: current.ministerRounds + matchMinisterRounds,
    policeRounds: current.policeRounds + matchPoliceRounds,
    thiefRounds: current.thiefRounds + matchThiefRounds,
    quickWins: current.quickWins + (humanWon && preset.id == 'quick' ? 1 : 0),
    classicWins:
        current.classicWins + (humanWon && preset.id == 'classic' ? 1 : 0),
    festivalWins:
        current.festivalWins + (humanWon && preset.id == 'festival' ? 1 : 0),
    currentWinStreak: currentWinStreak,
    bestWinStreak: max(current.bestWinStreak, currentWinStreak),
    perfectPoliceMatches:
        current.perfectPoliceMatches +
        (matchHumanPoliceAttempts > 0 &&
                matchHumanPoliceCorrect == matchHumanPoliceAttempts
            ? 1
            : 0),
    undefeatedThiefMatches:
        current.undefeatedThiefMatches +
        (matchHumanThiefRounds > 0 &&
                matchHumanThiefEscapes == matchHumanThiefRounds
            ? 1
            : 0),
    history: history,
  );

  final newUnlocks = gameChallenges
      .where(
        (challenge) =>
            !current.unlockedChallengeIds.contains(challenge.id) &&
            challenge.isUnlocked(updatedWithoutUnlocks),
      )
      .toList(growable: false);
  final updated = updatedWithoutUnlocks.copyWith(
    unlockedChallengeIds: <String>{
      ...current.unlockedChallengeIds,
      for (final challenge in newUnlocks) challenge.id,
    },
  );

  return MatchProgressUpdate(
    progress: updated,
    entry: entry,
    newUnlocks: newUnlocks,
  );
}

int _intValue(Object? value, {int fallback = 0}) {
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

String _stringValue(Object? value, {String fallback = ''}) {
  if (value is String) {
    return value;
  }
  return fallback;
}

Set<String> _stringSet(Object? value) {
  if (value is! Iterable<Object?>) {
    return <String>{};
  }
  return value.whereType<String>().toSet();
}

List<MatchHistoryEntry> _historyList(Object? value) {
  if (value is! Iterable<Object?>) {
    return const <MatchHistoryEntry>[];
  }

  return value
      .whereType<Map<Object?, Object?>>()
      .map(
        (entry) => MatchHistoryEntry.fromJson(
          entry.map((key, value) => MapEntry('$key', value)),
        ),
      )
      .toList(growable: false);
}
