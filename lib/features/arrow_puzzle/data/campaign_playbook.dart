const int _levelsPerWave = 5;

class CampaignWave {
  const CampaignWave({
    required this.index,
    required this.title,
    required this.objective,
    required this.reward,
    required this.startLevel,
    required this.endLevel,
  });

  final int index;
  final String title;
  final String objective;
  final String reward;
  final int startLevel;
  final int endLevel;

  int get levelCount => endLevel - startLevel + 1;

  bool containsLevel(int levelNumber) {
    return levelNumber >= startLevel && levelNumber <= endLevel;
  }
}

List<CampaignWave> buildCampaignWaves({required int totalLevels}) {
  if (totalLevels <= 0) {
    return const [];
  }

  const titles = <String>[
    'Flow Foundations',
    'Side-Lane Precision',
    'Column Rush',
    'Cascade Sweep',
    'Corner Control',
    'Twin Channel',
    'Streak Track',
    'Late Board',
    'Row Stack',
    'Tactical Locks',
    'Scale-Up Round',
    'Final Sweep',
  ];

  const objectives = <String>[
    'Clear the flow with cleaner sequencing and fewer retries.',
    'Use quick reads: clear the nearest edge lane before deeper lanes.',
    'Treat each column as a lane race; unlock top and bottom exits carefully.',
    'Alternate lane direction twice before moving to the next mission.',
    'Keep corner gates open by resolving near-edge blockers first.',
    'Watch two channels at once and keep both lanes moving forward.',
    'Try to keep a running combo in the middle of the wave.',
    'Pause after each clear and aim for consistent move discipline.',
    'Reduce over-taps: every tap should clear a valid arrow.',
    'Plan two-step unlock order before touching the center lane.',
    'Protect your streak: finish this wave with score chase pace.',
    'Finish strong and carry momentum into the next campaign wave.',
  ];

  const rewards = <String>[
    'Unlocks a cleaner replay pattern and the next mission block.',
    'Replay points stack with the first challenge in this wave.',
    'Momentum badge unlock on level set completion.',
    'Campaign streak refreshes with each completed set.',
    'Focus reset grants a stronger score baseline for this segment.',
    'Replay this wave to test alternate orderings and time targets.',
    'Each replay increases your route confidence for hard boards.',
    'Use this wave as a full warm-down before the next block.',
    'Combo habits from this wave carry into daily challenges.',
    'Higher-clear confidence unlocks cleaner start-of-wave flow.',
    'Bonus progress marker is reserved for full clear completion.',
    'Final wave completion marks full campaign readiness.',
  ];

  final waves = <CampaignWave>[];
  var index = 1;
  var start = 1;

  while (start <= totalLevels) {
    final end = start + _levelsPerWave - 1;
    final cappedEnd = end > totalLevels ? totalLevels : end;
    final titleIndex = (index - 1) % titles.length;

    waves.add(
      CampaignWave(
        index: index,
        title: titles[titleIndex],
        objective: objectives[titleIndex],
        reward: rewards[titleIndex],
        startLevel: start,
        endLevel: cappedEnd,
      ),
    );

    index++;
    start = cappedEnd + 1;
  }

  return waves;
}

CampaignWave? campaignWaveForLevel({
  required int levelNumber,
  required int totalLevels,
}) {
  if (levelNumber < 1 || totalLevels < 1) {
    return null;
  }

  final waves = buildCampaignWaves(totalLevels: totalLevels);
  return waves
      .cast<CampaignWave?>()
      .firstWhere((wave) => wave?.containsLevel(levelNumber) ?? false, orElse: () => null);
}

int completedLevelCountInWave(CampaignWave wave, Set<int> completedLevelIds) {
  var count = 0;
  for (var levelNumber = wave.startLevel; levelNumber <= wave.endLevel; levelNumber++) {
    if (completedLevelIds.contains(levelNumber)) {
      count++;
    }
  }
  return count;
}
