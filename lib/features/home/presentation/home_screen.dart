import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../games/dew_bubble/data/dew_levels.dart';
import '../../games/dew_bubble/data/dew_progression.dart';
import '../../games/game_catalog.dart';
import '../../games/shared/kid_celebration.dart';
import '../../parent/presentation/parent_corner_screen.dart';
import '../../parent/presentation/parent_gate_dialog.dart';
import '../../tracing/data/progress_repository.dart';
import '../../../shared/ads/game_ad_service.dart';
import '../../../shared/analytics/game_analytics.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.progressRepository,
    this.analytics = const NoopGameAnalytics(),
    this.adService = const NoopGameAdService(),
    super.key,
  });

  final ProgressRepository progressRepository;
  final GameAnalytics analytics;
  final GameAdService adService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  KidsGame get _game => kidsGameCatalog.single;

  @override
  void initState() {
    super.initState();
    final progress = dewBubbleProgressSnapshot(widget.progressRepository);
    unawaited(
      widget.analytics.logEvent(GameAnalyticsEvents.homeViewed, {
        'game_id': _game.id,
        'total_levels': dewBubbleLevels.length,
        ...dewBubbleProgressAnalyticsParams(progress),
      }),
    );
    unawaited(
      widget.analytics.logEvent(GameAnalyticsEvents.progressSnapshot, {
        'game_id': _game.id,
        'source': 'home_view',
        ...dewBubbleProgressAnalyticsParams(progress),
      }),
    );
  }

  Future<void> _openGame({
    required int levelIndex,
    required bool showLevelSelect,
    required String source,
  }) async {
    final game = _game;
    final progress = dewBubbleProgressSnapshot(widget.progressRepository);
    var completionRequested = false;
    unawaited(
      widget.analytics.logEvent(GameAnalyticsEvents.gameOpened, {
        'game_id': game.id,
        'source': source,
        'level_number': levelIndex + 1,
        'show_level_select': showLevelSelect,
        ...dewBubbleProgressAnalyticsParams(progress),
      }),
    );

    void markCompleted() {
      if (completionRequested) {
        return;
      }
      completionRequested = true;
      unawaited(widget.progressRepository.markGameComplete(game.id));
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/games/${game.id}'),
        builder: (context) => game.builder(
          context,
          markCompleted,
          widget.progressRepository,
          widget.analytics,
          widget.adService,
          GameLaunchOptions(
            initialLevelIndex: levelIndex,
            showLevelSelectOnStart: showLevelSelect,
            source: source,
          ),
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openParentCorner() async {
    final unlocked = await showParentGate(context);
    if (!unlocked || !mounted) {
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/parent'),
        builder: (context) => ParentCornerScreen(
          progressRepository: widget.progressRepository,
          gameIds: [for (final game in kidsGameCatalog) game.id],
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    final progress = dewBubbleProgressSnapshot(widget.progressRepository);
    final totalLevels = progress.totalStages;
    final highestUnlocked = widget
        .progressRepository
        .dewBubbleHighestUnlockedLevelIndex
        .clamp(0, math.max(0, totalLevels - 1))
        .toInt();
    final completed = widget.progressRepository.isGameComplete(game.id);
    final nextLevelIndex = highestUnlocked;
    final nextLevel = dewBubbleLevels[nextLevelIndex];
    final nextBestScore = widget.progressRepository.dewBubbleBestScore(
      nextLevel.id,
    );
    final nextBestStars = widget.progressRepository.dewBubbleBestStars(
      nextLevel.id,
    );
    final nextTargetScore = dewBubbleTargetScore(nextLevel);
    final nextMission = dewBubbleStageMission(nextLevelIndex);
    final nextChapter = dewCampaignChapterForLevelIndex(nextLevelIndex);
    final unlockedAchievements = dewBubbleUnlockedAchievements(progress);
    final nextAchievement = dewBubbleNextAchievement(progress);
    final primaryLabel = nextLevelIndex == 0 && nextBestScore == 0
        ? 'Start Stage 1'
        : 'Continue Stage ${nextLevelIndex + 1}';

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F8FA), Color(0xFFE9F8F3), Color(0xFFFFF7E3)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HomeHeader(onParentCorner: _openParentCorner),
                          const SizedBox(height: 16),
                          _NextGardenPanel(
                            gameTitle: game.title,
                            gameSubtitle: game.subtitle,
                            levelNumber: nextLevelIndex + 1,
                            levelTitle: nextLevel.title,
                            chapterTitle: nextChapter.title,
                            mission: nextMission,
                            targetScore: nextTargetScore,
                            bestScore: nextBestScore,
                            bestStars: nextBestStars,
                            label: completed
                                ? 'Play Final Stage'
                                : primaryLabel,
                            onPlay: () => _openGame(
                              levelIndex: nextLevelIndex,
                              showLevelSelect: false,
                              source: 'home_continue',
                            ),
                            onCampaign: () => _openGame(
                              levelIndex: nextLevelIndex,
                              showLevelSelect: true,
                              source: 'home_garden_map',
                            ),
                          ),
                          const SizedBox(height: 18),
                          _BubbleGardenPreview(completed: completed),
                          const SizedBox(height: 14),
                          _RunGoalsStrip(
                            stageNumber: nextLevelIndex + 1,
                            totalStages: totalLevels,
                            targetScore: nextTargetScore,
                            nextBestScore: nextBestScore,
                            threeStarClears: progress.threeStarClears,
                            achievementCount: unlockedAchievements.length,
                            achievementTotal: dewBubbleAchievements.length,
                          ),
                          const SizedBox(height: 14),
                          _ProgressSummary(
                            unlockedLevels: progress.unlockedStages,
                            totalLevels: totalLevels,
                            savedStars: progress.savedStars,
                            maxStars: progress.totalStars,
                            bestScore: progress.bestScore,
                          ),
                          const SizedBox(height: 14),
                          _AchievementShelf(
                            unlockedCount: unlockedAchievements.length,
                            totalCount: dewBubbleAchievements.length,
                            nextAchievement: nextAchievement,
                          ),
                          const SizedBox(height: 14),
                          const _LocalPlayNote(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onParentCorner});

  final VoidCallback onParentCorner;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _BrandMark()),
        const SizedBox(width: 12),
        Semantics(
          button: true,
          label: 'Open parent settings',
          child: IconButton.filledTonal(
            key: const ValueKey('parent-corner-button'),
            onPressed: onParentCorner,
            tooltip: 'Parent Corner',
            icon: const Icon(Icons.family_restroom_rounded, size: 28),
            style: IconButton.styleFrom(
              minimumSize: const Size.square(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              foregroundColor: const Color(0xFF2E6E65),
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF2CB9A0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.bubble_chart_rounded,
              size: 28,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Dew Bubble',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF243C4A),
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _BubbleGardenPreview extends StatelessWidget {
  const _BubbleGardenPreview({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Dew Bubble preview',
      image: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = math.min(
            260.0,
            math.max(168.0, constraints.maxWidth * 0.38),
          );

          return SizedBox(
            height: height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x183F8FEF),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const CustomPaint(painter: _BubbleGardenPreviewPainter()),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: KidFloaty(
                        amplitude: 3,
                        sway: 2,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: completed
                                ? const Color(0xFFFFF0B8)
                                : const Color(0xFFE7FAFF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  completed
                                      ? Icons.check_rounded
                                      : Icons.spa_rounded,
                                  key: completed
                                      ? const ValueKey(
                                          'dew-bubble-complete-check',
                                        )
                                      : null,
                                  color: completed
                                      ? const Color(0xFFD98700)
                                      : const Color(0xFF2CB9A0),
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  completed ? 'Complete' : 'Next Run',
                                  style: const TextStyle(
                                    color: Color(0xFF34415F),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NextGardenPanel extends StatelessWidget {
  const _NextGardenPanel({
    required this.gameTitle,
    required this.gameSubtitle,
    required this.levelNumber,
    required this.levelTitle,
    required this.chapterTitle,
    required this.mission,
    required this.targetScore,
    required this.bestScore,
    required this.bestStars,
    required this.label,
    required this.onPlay,
    required this.onCampaign,
  });

  final String gameTitle;
  final String gameSubtitle;
  final int levelNumber;
  final String levelTitle;
  final String chapterTitle;
  final String mission;
  final int targetScore;
  final int bestScore;
  final int bestStars;
  final String label;
  final VoidCallback onPlay;
  final VoidCallback onCampaign;

  @override
  Widget build(BuildContext context) {
    final progressText = bestScore == 0
        ? 'Target $targetScore pts'
        : 'Best $bestScore / $bestStars stars';
    final targetProgress = targetScore <= 0
        ? 0.0
        : (bestScore / targetScore).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF172C37),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20243C4A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            gameTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            gameSubtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFBFD0D7),
              fontWeight: FontWeight.w800,
              height: 1.12,
            ),
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerLeft,
            child: _HubStatusBadge(),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2CB9A0).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.flag_rounded,
                      color: Color(0xFF67E0C9),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$chapterTitle - Stage $levelNumber',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFBFD0D7),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        levelTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        mission,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFDDEBE7),
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _HubMetric(
            icon: Icons.emoji_events_rounded,
            label: 'Score goal',
            value: progressText,
            color: const Color(0xFFFFD15C),
          ),
          const SizedBox(height: 8),
          _HubMetric(
            icon: Icons.star_rounded,
            label: 'Star chase',
            value: bestStars == 0 ? 'Save shots' : '$bestStars/3 stars',
            color: const Color(0xFF67B8F7),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: targetProgress,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.14),
              color: bestScore >= targetScore
                  ? const Color(0xFF2CB9A0)
                  : const Color(0xFFFFD15C),
            ),
          ),
          const SizedBox(height: 14),
          _PlayButton(label: label, onPressed: onPlay),
          const SizedBox(height: 10),
          _ChooseGardenButton(onPressed: onCampaign),
        ],
      ),
    );
  }
}

class _HubStatusBadge extends StatelessWidget {
  const _HubStatusBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFD15C).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFFD15C).withValues(alpha: 0.3),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, color: Color(0xFFFFD15C), size: 18),
              SizedBox(width: 4),
              Text(
                'Active Run',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubMetric extends StatelessWidget {
  const _HubMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFBFD0D7),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      key: const ValueKey('game-card-dew-bubble'),
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        backgroundColor: const Color(0xFF2CB9A0),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_arrow_rounded, size: 32),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, maxLines: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChooseGardenButton extends StatelessWidget {
  const _ChooseGardenButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: const ValueKey('choose-garden-button'),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0x80FFFFFF)),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.route_rounded),
          SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Campaign Route', maxLines: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _RunGoalsStrip extends StatelessWidget {
  const _RunGoalsStrip({
    required this.stageNumber,
    required this.totalStages,
    required this.targetScore,
    required this.nextBestScore,
    required this.threeStarClears,
    required this.achievementCount,
    required this.achievementTotal,
  });

  final int stageNumber;
  final int totalStages;
  final int targetScore;
  final int nextBestScore;
  final int threeStarClears;
  final int achievementCount;
  final int achievementTotal;

  @override
  Widget build(BuildContext context) {
    final scoreGoal = nextBestScore >= targetScore
        ? 'Beat $nextBestScore'
        : '$targetScore pts';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF243C4A),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18243C4A),
            blurRadius: 18,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Run goals',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _GoalPill(
                icon: Icons.flag_rounded,
                label: 'Current',
                value: '$stageNumber/$totalStages',
                color: const Color(0xFF67B8F7),
              ),
              _GoalPill(
                icon: Icons.emoji_events_rounded,
                label: 'Score',
                value: scoreGoal,
                color: const Color(0xFFFFD15C),
              ),
              _GoalPill(
                icon: Icons.star_rounded,
                label: 'Mastery',
                value: '$threeStarClears/$totalStages',
                color: const Color(0xFF2CB9A0),
              ),
              _GoalPill(
                icon: Icons.workspace_premium_rounded,
                label: 'Badges',
                value: '$achievementCount/$achievementTotal',
                color: const Color(0xFFBFA7FF),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalPill extends StatelessWidget {
  const _GoalPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 124, maxWidth: 156),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFBFD0D7),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementShelf extends StatelessWidget {
  const _AchievementShelf({
    required this.unlockedCount,
    required this.totalCount,
    required this.nextAchievement,
  });

  final int unlockedCount;
  final int totalCount;
  final DewBubbleAchievement? nextAchievement;

  @override
  Widget build(BuildContext context) {
    final next = nextAchievement;
    final title = next == null ? 'All badges earned' : next.title;
    final detail = next == null ? 'Route mastery complete.' : next.description;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4CE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xFFD98700),
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Badges $unlockedCount/$totalCount',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF243C4A),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2E6E65),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF68758B),
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({
    required this.unlockedLevels,
    required this.totalLevels,
    required this.savedStars,
    required this.maxStars,
    required this.bestScore,
  });

  final int unlockedLevels;
  final int totalLevels;
  final int savedStars;
  final int maxStars;
  final int bestScore;

  @override
  Widget build(BuildContext context) {
    final progress = totalLevels == 0 ? 0.0 : unlockedLevels / totalLevels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.lock_open_rounded,
                label: 'Stages',
                value: '$unlockedLevels/$totalLevels',
                color: const Color(0xFF3F8FEF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.star_rounded,
                label: 'Stars',
                value: '$savedStars/$maxStars',
                color: const Color(0xFFFFA928),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.emoji_events_rounded,
                label: 'High',
                value: '$bestScore',
                color: const Color(0xFF7257E8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Colors.white.withValues(alpha: 0.75),
            color: const Color(0xFF2CB9A0),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF243C4A),
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF68758B),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalPlayNote extends StatelessWidget {
  const _LocalPlayNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.offline_bolt_rounded, size: 18, color: Color(0xFF237A59)),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            'Offline save / No account required',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xFF237A59),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _BubbleGardenPreviewPainter extends CustomPainter {
  const _BubbleGardenPreviewPainter();

  static const _bubbles = <_PreviewBubble>[
    _PreviewBubble(0.18, 0.24, 0.12, Color(0xFF67B8F7)),
    _PreviewBubble(0.31, 0.23, 0.12, Color(0xFFEF5DA8)),
    _PreviewBubble(0.44, 0.24, 0.12, Color(0xFFFFD15C)),
    _PreviewBubble(0.57, 0.23, 0.12, Color(0xFF2DBE88)),
    _PreviewBubble(0.25, 0.39, 0.12, Color(0xFF67B8F7)),
    _PreviewBubble(0.38, 0.39, 0.12, Color(0xFFEF5DA8)),
    _PreviewBubble(0.51, 0.39, 0.12, Color(0xFFFFD15C)),
    _PreviewBubble(0.64, 0.39, 0.12, Color(0xFF2DBE88)),
    _PreviewBubble(0.70, 0.63, 0.1, Color(0xFFEF5DA8)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE9FBFF), Color(0xFFFFFAEA)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);

    final groundPaint = Paint()..color = const Color(0xFFE0F6D8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.66, size.width, size.height * 0.34),
        const Radius.circular(28),
      ),
      groundPaint,
    );

    final stemPaint = Paint()
      ..color = const Color(0xFF52A869)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(2, size.shortestSide * 0.018);
    canvas.drawLine(
      Offset(size.width * 0.72, size.height * 0.73),
      Offset(size.width * 0.72, size.height * 0.58),
      stemPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.78, size.height * 0.74),
      Offset(size.width * 0.78, size.height * 0.62),
      stemPaint,
    );

    for (final bubble in _bubbles) {
      final center = Offset(bubble.x * size.width, bubble.y * size.height);
      final radius = bubble.radius * size.shortestSide;
      final shadowPaint = Paint()
        ..color = const Color(0x2234415F)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(
        center.translate(0, radius * 0.16),
        radius,
        shadowPaint,
      );

      final fillPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.45, -0.45),
          radius: 0.9,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            bubble.color.withValues(alpha: 0.92),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, fillPaint);

      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.4, radius * 0.08)
        ..color = Colors.white.withValues(alpha: 0.7);
      canvas.drawCircle(center, radius * 0.9, ringPaint);
    }

    final shooterCenter = Offset(size.width * 0.5, size.height * 0.83);
    final shooterPaint = Paint()..color = const Color(0xFF34415F);
    final barrelPaint = Paint()
      ..color = const Color(0xFF34415F)
      ..strokeWidth = math.max(8, size.shortestSide * 0.04)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      shooterCenter,
      shooterCenter.translate(size.width * 0.12, -size.height * 0.18),
      barrelPaint,
    );
    canvas.drawCircle(shooterCenter, size.shortestSide * 0.075, shooterPaint);
    canvas.drawCircle(
      shooterCenter,
      size.shortestSide * 0.046,
      Paint()..color = const Color(0xFFFFD15C),
    );
  }

  @override
  bool shouldRepaint(covariant _BubbleGardenPreviewPainter oldDelegate) {
    return false;
  }
}

class _PreviewBubble {
  const _PreviewBubble(this.x, this.y, this.radius, this.color);

  final double x;
  final double y;
  final double radius;
  final Color color;
}
