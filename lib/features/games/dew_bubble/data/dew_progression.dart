import 'dart:math' as math;

import '../../../tracing/data/progress_repository.dart';
import '../domain/bubble_color.dart';
import '../domain/bubble_level.dart';
import 'dew_levels.dart';

class DewCampaignChapter {
  const DewCampaignChapter({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.startLevelIndex,
    required this.endLevelIndex,
  });

  final String id;
  final String title;
  final String subtitle;
  final int startLevelIndex;
  final int endLevelIndex;

  bool containsLevelIndex(int levelIndex) {
    return levelIndex >= startLevelIndex && levelIndex <= endLevelIndex;
  }
}

class DewBubbleAchievement {
  const DewBubbleAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });

  final String id;
  final String title;
  final String description;
  final bool Function(DewProgressSnapshot snapshot) isUnlocked;
}

class DewProgressSnapshot {
  const DewProgressSnapshot({
    required this.unlockedStages,
    required this.totalStages,
    required this.clearedStages,
    required this.savedStars,
    required this.totalStars,
    required this.threeStarClears,
    required this.bestScore,
    required this.targetScoreClears,
    required this.campaignCleared,
  });

  final int unlockedStages;
  final int totalStages;
  final int clearedStages;
  final int savedStars;
  final int totalStars;
  final int threeStarClears;
  final int bestScore;
  final int targetScoreClears;
  final bool campaignCleared;
}

const dewCampaignChapters = <DewCampaignChapter>[
  DewCampaignChapter(
    id: 'opening-route',
    title: 'Opening Route',
    subtitle: 'Learn clean matches and early drops.',
    startLevelIndex: 0,
    endLevelIndex: 9,
  ),
  DewCampaignChapter(
    id: 'canopy-control',
    title: 'Canopy Control',
    subtitle: 'Read four-color layouts before shooting.',
    startLevelIndex: 10,
    endLevelIndex: 19,
  ),
  DewCampaignChapter(
    id: 'pressure-run',
    title: 'Pressure Run',
    subtitle: 'Save shots while the board gets denser.',
    startLevelIndex: 20,
    endLevelIndex: 29,
  ),
  DewCampaignChapter(
    id: 'master-route',
    title: 'Master Route',
    subtitle: 'Chain streaks through the final patterns.',
    startLevelIndex: 30,
    endLevelIndex: 39,
  ),
];

const dewBubbleStageMissions = <String>[
  'Learn three clean color matches.',
  'Stack vertical pairs without wasting shots.',
  'Drop loose bubbles from the side.',
  'Use corner pairs to open green.',
  'Balance four colors in one route.',
  'Clear lattice gaps with measured shots.',
  'Thread shots through the leaf lanes.',
  'Build two fast matches before the board spreads.',
  'Use bridge pairs to set up a drop.',
  'Read the canopy gaps before firing.',
  'Keep the four-color queue under control.',
  'Bounce once to reach protected pairs.',
  'Save shots while clearing three rows.',
  'Turn a side match into a floating drop.',
  'Avoid breaking setup pairs too early.',
  'Clear dense bridges with a streak.',
  'Control the canopy from the outside in.',
  'Score with quick pairs before saving shots.',
  'Use lane openings to reach the back row.',
  'Break the gate with one clean drop.',
  'Keep the middle open for late colors.',
  'Plan two moves ahead through the bridge.',
  'Set up the overlap before chasing score.',
  'Clear the shelf without clipping side pairs.',
  'Use canopy gaps to reach hidden matches.',
  'Turn the first drop into a score chase.',
  'Hold quiet shots for a late streak.',
  'Bounce into the balcony instead of forcing it.',
  'Clear mesh pairs in the right order.',
  'Use open space to protect your streak.',
  'Control lanes before they crowd the launcher.',
  'Break the spiral from a safe angle.',
  'Use bridges to create one large drop.',
  'Keep final shots for star pace.',
  'Clear the weave with precise bounces.',
  'Push for target score before the last row.',
  'Keep the route open through the nook.',
  'Chain two matches in the final canopy.',
  'Save enough shots for a clean finish.',
  'Clear the final pattern and beat your best.',
];

final dewBubbleAchievements = <DewBubbleAchievement>[
  DewBubbleAchievement(
    id: 'first-clear',
    title: 'First Clear',
    description: 'Clear any stage.',
    isUnlocked: (snapshot) => snapshot.clearedStages >= 1,
  ),
  DewBubbleAchievement(
    id: 'route-runner',
    title: 'Route Runner',
    description: 'Unlock 10 stages.',
    isUnlocked: (snapshot) => snapshot.unlockedStages >= 10,
  ),
  DewBubbleAchievement(
    id: 'canopy-reader',
    title: 'Canopy Reader',
    description: 'Unlock 20 stages.',
    isUnlocked: (snapshot) => snapshot.unlockedStages >= 20,
  ),
  DewBubbleAchievement(
    id: 'star-collector',
    title: 'Star Collector',
    description: 'Bank 30 campaign stars.',
    isUnlocked: (snapshot) => snapshot.savedStars >= 30,
  ),
  DewBubbleAchievement(
    id: 'clean-dozen',
    title: 'Clean Dozen',
    description: 'Earn 3 stars on 12 stages.',
    isUnlocked: (snapshot) => snapshot.threeStarClears >= 12,
  ),
  DewBubbleAchievement(
    id: 'target-chaser',
    title: 'Target Chaser',
    description: 'Beat target score on 15 stages.',
    isUnlocked: (snapshot) => snapshot.targetScoreClears >= 15,
  ),
  DewBubbleAchievement(
    id: 'star-garden',
    title: 'Star Garden',
    description: 'Earn 3 stars on 25 stages.',
    isUnlocked: (snapshot) => snapshot.threeStarClears >= 25,
  ),
  DewBubbleAchievement(
    id: 'target-master',
    title: 'Target Master',
    description: 'Beat target score on 30 stages.',
    isUnlocked: (snapshot) => snapshot.targetScoreClears >= 30,
  ),
  DewBubbleAchievement(
    id: 'score-spark',
    title: 'Score Spark',
    description: 'Reach a 700 point best score.',
    isUnlocked: (snapshot) => snapshot.bestScore >= 700,
  ),
  DewBubbleAchievement(
    id: 'route-master',
    title: 'Route Master',
    description: 'Clear the full campaign.',
    isUnlocked: (snapshot) => snapshot.campaignCleared,
  ),
];

DewCampaignChapter dewCampaignChapterForLevelIndex(int levelIndex) {
  return dewCampaignChapters.firstWhere(
    (chapter) => chapter.containsLevelIndex(levelIndex),
    orElse: () => dewCampaignChapters.last,
  );
}

String dewBubbleStageMission(int levelIndex) {
  final safeIndex = math.max(
    0,
    math.min(levelIndex, dewBubbleStageMissions.length - 1),
  );
  return dewBubbleStageMissions[safeIndex];
}

int dewBubbleTargetScore(BubbleLevel level) {
  final bubbleCount = dewBubbleBubbleCount(level);
  final activeRows = dewBubbleActiveRows(level);
  final colorPressure = dewBubbleColorsIn(level).length;
  final rawScore =
      120 + (bubbleCount * 18) + (activeRows * 34) + (colorPressure * 22);
  return ((rawScore + 24) ~/ 25) * 25;
}

int dewBubbleBubbleCount(BubbleLevel level) {
  var count = 0;
  for (final row in level.layout) {
    for (final token in row) {
      if (token != null) {
        count++;
      }
    }
  }
  return count;
}

int dewBubbleActiveRows(BubbleLevel level) {
  var activeRows = 0;
  for (var row = 0; row < level.layout.length; row++) {
    if (level.layout[row].any((token) => token != null)) {
      activeRows = row + 1;
    }
  }
  return activeRows;
}

Set<DewBubbleColor> dewBubbleColorsIn(BubbleLevel level) {
  return {
    for (final row in level.layout)
      for (final token in row)
        if (dewBubbleColorFromToken(token) case final color?) color,
  };
}

DewProgressSnapshot dewBubbleProgressSnapshot(ProgressRepository repository) {
  var clearedStages = 0;
  var savedStars = 0;
  var threeStarClears = 0;
  var bestScore = 0;
  var targetScoreClears = 0;

  for (final level in dewBubbleLevels) {
    final levelStars = repository.dewBubbleBestStars(level.id);
    final levelScore = repository.dewBubbleBestScore(level.id);
    if (levelStars > 0 || levelScore > 0) {
      clearedStages++;
    }
    if (levelStars >= 3) {
      threeStarClears++;
    }
    if (levelScore >= dewBubbleTargetScore(level)) {
      targetScoreClears++;
    }
    savedStars += levelStars;
    bestScore = math.max(bestScore, levelScore);
  }

  final totalStages = dewBubbleLevels.length;
  final unlockedStages = totalStages == 0
      ? 0
      : repository.dewBubbleHighestUnlockedLevelIndex
                .clamp(0, totalStages - 1)
                .toInt() +
            1;

  return DewProgressSnapshot(
    unlockedStages: unlockedStages,
    totalStages: totalStages,
    clearedStages: clearedStages,
    savedStars: savedStars,
    totalStars: totalStages * 3,
    threeStarClears: threeStarClears,
    bestScore: bestScore,
    targetScoreClears: targetScoreClears,
    campaignCleared: repository.isGameComplete(dewBubbleGameId),
  );
}

Map<String, Object> dewBubbleProgressAnalyticsParams(
  DewProgressSnapshot snapshot,
) {
  return {
    'unlocked_stages': snapshot.unlockedStages,
    'total_stages': snapshot.totalStages,
    'cleared_stages': snapshot.clearedStages,
    'saved_stars': snapshot.savedStars,
    'total_stars': snapshot.totalStars,
    'three_star_clears': snapshot.threeStarClears,
    'best_score': snapshot.bestScore,
    'target_score_clears': snapshot.targetScoreClears,
    'campaign_cleared': snapshot.campaignCleared,
  };
}

List<DewBubbleAchievement> dewBubbleUnlockedAchievements(
  DewProgressSnapshot snapshot,
) {
  return [
    for (final achievement in dewBubbleAchievements)
      if (achievement.isUnlocked(snapshot)) achievement,
  ];
}

DewBubbleAchievement? dewBubbleNextAchievement(DewProgressSnapshot snapshot) {
  for (final achievement in dewBubbleAchievements) {
    if (!achievement.isUnlocked(snapshot)) {
      return achievement;
    }
  }
  return null;
}
