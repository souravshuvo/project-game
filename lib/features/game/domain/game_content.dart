class MatchPreset {
  const MatchPreset({
    required this.id,
    required this.label,
    required this.rounds,
    required this.description,
  });

  final String id;
  final String label;
  final int rounds;
  final String description;
}

const List<MatchPreset> matchPresets = <MatchPreset>[
  MatchPreset(
    id: 'quick',
    label: 'Quick',
    rounds: 5,
    description: 'Short match for a fast table.',
  ),
  MatchPreset(
    id: 'classic',
    label: 'Classic',
    rounds: 7,
    description: 'A steadier match with more comeback chances.',
  ),
  MatchPreset(
    id: 'festival',
    label: 'Festival',
    rounds: 10,
    description: 'Long match for the full score chase.',
  ),
];

MatchPreset matchPresetById(String id) {
  return matchPresets.firstWhere(
    (preset) => preset.id == id,
    orElse: () => matchPresets.first,
  );
}

enum BotGuessStyle { fairRandom, scoreWatcher, tableMemory }

extension BotGuessStyleText on BotGuessStyle {
  String get id {
    switch (this) {
      case BotGuessStyle.fairRandom:
        return 'fair_random';
      case BotGuessStyle.scoreWatcher:
        return 'score_watcher';
      case BotGuessStyle.tableMemory:
        return 'table_memory';
    }
  }

  String get label {
    switch (this) {
      case BotGuessStyle.fairRandom:
        return 'Fair Random';
      case BotGuessStyle.scoreWatcher:
        return 'Score Watcher';
      case BotGuessStyle.tableMemory:
        return 'Table Memory';
    }
  }

  String get description {
    switch (this) {
      case BotGuessStyle.fairRandom:
        return 'Bots pick from valid suspects equally.';
      case BotGuessStyle.scoreWatcher:
        return 'Bots suspect the public score leader first.';
      case BotGuessStyle.tableMemory:
        return 'Bots use earlier revealed Thief history.';
    }
  }
}

BotGuessStyle botGuessStyleById(String id) {
  return BotGuessStyle.values.firstWhere(
    (style) => style.id == id,
    orElse: () => BotGuessStyle.fairRandom,
  );
}
