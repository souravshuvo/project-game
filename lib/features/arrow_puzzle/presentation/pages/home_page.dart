import 'package:flutter/material.dart';

import '../../application/game_ads.dart';
import '../../application/puzzle_controller.dart';
import '../theme/arrow_puzzle_theme.dart';
import '../widgets/arrow_puzzle_ad_banner.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key, required this.controller, GameAds? ads})
    : ads = ads ?? NoOpGameAds.instance;

  final PuzzleController controller;
  final GameAds ads;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 720;

    return Scaffold(
      body: GameBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.all(compact ? 14 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Spacer(),
                            IconButton(
                              onPressed: controller.showSettings,
                              icon: const Icon(Icons.settings_rounded),
                              tooltip: 'Settings',
                              iconSize: 26,
                            ),
                          ],
                        ),
                        SizedBox(height: compact ? 4 : 12),
                        Center(child: ArrowPuzzleBrandMark(size: compact ? 78 : 92)),
                        SizedBox(height: compact ? 12 : 16),
                        Text(
                          'Arrow Puzzle Hub',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: ArrowPuzzleColors.primaryDark,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'A real hub for daily flow, campaign progress, and fast reruns.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: ArrowPuzzleColors.mutedInk,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: compact ? 16 : 22),
                        _GameVitals(controller: controller),
                        SizedBox(height: compact ? 12 : 16),
                        _HomePrimaryActions(controller: controller),
                        if (controller.shouldShowTutorial) ...[
                          const SizedBox(height: 12),
                          _FirstRunOnboardingCard(controller: controller),
                        ],
                        const SizedBox(height: 12),
                        _CampaignSummary(controller: controller),
                        const SizedBox(height: 12),
                        _CampaignWaveCard(controller: controller),
                        const SizedBox(height: 12),
                        _MissionCard(controller: controller),
                        const SizedBox(height: 12),
                        _DailyCard(controller: controller),
                        SizedBox(height: compact ? 12 : 14),
                        AnimatedBuilder(
                          animation: ads,
                          builder: (context, _) {
                            return _HintCard(controller: controller, ads: ads);
                          },
                        ),
                        const SizedBox(height: 12),
                        ArrowPuzzleAdBanner(ads: ads, placement: 'home_bottom'),
                        const SizedBox(height: 8),
                        _ProgressCard(controller: controller),
                        SizedBox(height: compact ? 10 : 12),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GameVitals extends StatelessWidget {
  const _GameVitals({required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    final remainingLevels = controller.totalLevels - controller.completedLevelCount;

    return ArrowPuzzleCard(
      child: Row(
        children: [
          _VitalTile(
            icon: Icons.route_rounded,
            label: 'Campaign',
            value: '${controller.resumeLevelNumber}/${controller.totalLevels}',
          ),
          const SizedBox(width: 8),
          _VitalTile(
            icon: Icons.local_fire_department_rounded,
            label: 'Streak',
            value: '${controller.streakDays} days',
          ),
          const SizedBox(width: 8),
          _VitalTile(
            icon: Icons.sports_score_rounded,
            label: 'Remain',
            value: '$remainingLevels',
          ),
        ],
      ),
    );
  }
}

class _VitalTile extends StatelessWidget {
  const _VitalTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomePrimaryActions extends StatelessWidget {
  const _HomePrimaryActions({required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.start,
      children: [
        SizedBox(
          width: 180,
          child: FilledButton.icon(
            onPressed: () {
              if (controller.shouldShowTutorial) {
                controller.markTutorialSeen();
              }
              controller.play();
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Quick Play', maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
        SizedBox(
          width: 180,
          child: OutlinedButton.icon(
            onPressed: controller.showLevelSelect,
            icon: const Icon(Icons.route_rounded),
            label: const Text('Campaign', maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
        SizedBox(
          width: 180,
          child: OutlinedButton.icon(
            onPressed: controller.startDailyChallenge,
            icon: const Icon(Icons.today_rounded),
            label: const Text('Daily Run', maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    final currentBestMoves = controller.currentLevelBestMoves;
    final currentBestScore = controller.bestRunScoreForCurrentLevel;
    final mission = currentBestMoves == null
        ? 'Set a clean first clear on Level ${controller.resumeLevelNumber}.'
        : 'Mission: clear with ${currentBestMoves + 1} moves or fewer, then protect combo growth.';

    final scoreMessage = currentBestScore == null
        ? 'Score chase unlocked after first clear.'
        : 'Beat last clear score of $currentBestScore and protect your combo.';

    return ArrowPuzzleCard(
      borderColor: const Color(0xFFB7D4FF),
      color: ArrowPuzzleColors.blueSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: ArrowPuzzleColors.primary),
              const SizedBox(width: 10),
              Text(
                'Replay Mission',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            controller.campaignMissionObjective,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ArrowPuzzleColors.primaryDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(mission, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(scoreMessage, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(
            'Reward: ${controller.campaignMissionReward}',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 2),
          Text('Hints: ${controller.hintCount}', style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _CampaignWaveCard extends StatelessWidget {
  const _CampaignWaveCard({required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    final currentWave = controller.currentCampaignWave;
    final completed = controller.completedLevelsInWaveCount(currentWave);
    final total = currentWave?.levelCount ?? 0;
    final ratio = total == 0 ? 0.0 : completed / total;

    return ArrowPuzzleCard(
      borderColor: const Color(0xFFC8B7FF),
      color: const Color(0xFFF0EEFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.alt_route_rounded, color: ArrowPuzzleColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  currentWave == null
                      ? 'Campaign Wave'
                      : 'Wave ${currentWave.index}: ${currentWave.title}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentWave == null
                ? 'Build campaign flow across waves and mission blocks.'
                : 'Wave objective: ${currentWave.objective}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            currentWave == null
                ? 'Complete your first wave to unlock flow replay goals.'
                : 'Reward cue: ${currentWave.reward}',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: const Color(0xFFE1D6FF),
              color: ArrowPuzzleColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentWave == null
                ? 'Wave Progress: 0/0'
                : 'Wave Progress: $completed/$total',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: ArrowPuzzleColors.mutedInk,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed:
                  currentWave == null ? null : () => controller.startCampaignWave(currentWave.index),
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: const Text('Replay Wave'),
            ),
          ),
        ],
      ),
    );
  }
}


class _FirstRunOnboardingCard extends StatelessWidget {
  const _FirstRunOnboardingCard({required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    return ArrowPuzzleCard(
      color: ArrowPuzzleColors.mintSoft,
      borderColor: const Color(0xFF98D7B6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: ArrowPuzzleColors.mint,
              ),
              const SizedBox(width: 10),
              Expanded(
        child: Text(
                  'Quick Start',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ArrowPuzzleColors.primaryDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: controller.markTutorialSeen,
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Tap one arrow only when its path to board edge is clear. The board updates immediately.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ArrowPuzzleColors.primaryDark,
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () {
              controller.markTutorialSeen();
              controller.play();
            },
            icon: const Icon(Icons.play_circle_rounded),
            label: const Text('Got it, play now'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
          ),
        ],
      ),
    );
  }
}

class _CampaignSummary extends StatelessWidget {
  const _CampaignSummary({required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    return ArrowPuzzleCard(
      child: Row(
        children: [
          const Icon(Icons.rocket_launch_rounded, color: ArrowPuzzleColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Campaign: Level ${controller.resumeLevelNumber} ready',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '${controller.unlockedLevelCount}/${controller.totalLevels}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ArrowPuzzleColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    final isComplete = controller.isDailyGoalComplete;
    final colorScheme = Theme.of(context).colorScheme;

    return ArrowPuzzleCard(
      color: isComplete ? ArrowPuzzleColors.mintSoft : ArrowPuzzleColors.amberSoft,
      borderColor: isComplete
          ? const Color(0xFF9DDDBD)
          : const Color(0xFFFFCF7A),
      child: Row(
        children: [
          Icon(
            isComplete
                ? Icons.local_fire_department_rounded
                : Icons.today_rounded,
            color: isComplete
                ? const Color(0xFF16824E)
                : const Color(0xFFC77200),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isComplete
                      ? '${controller.streakDays} day streak'
                      : 'Daily Level',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isComplete
                      ? 'Come back tomorrow for a fresh daily challenge.'
                      : '${controller.dailyChallengeLevel.name} (${controller.dailyChallengeLevelNumber})',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: controller.startDailyChallenge,
            icon: Icon(isComplete ? Icons.replay_rounded : Icons.arrow_forward_rounded),
            label: Text(isComplete ? 'Replay' : 'Start'),
            style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.controller, required this.ads});

  final PuzzleController controller;
  final GameAds ads;

  @override
  Widget build(BuildContext context) {
    final canClaim = controller.canClaimDailyHint;
    final canWatchRewardedAd = !canClaim && ads.rewardedHintReady;
    final colorScheme = Theme.of(context).colorScheme;

    return ArrowPuzzleCard(
      color: ArrowPuzzleColors.blueSoft,
      borderColor: const Color(0xFFB7D4FF),
      child: Row(
        children: [
          Icon(Icons.lightbulb_rounded, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  canClaim ? 'Daily Hint' : '${controller.hintCount} hints',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  canClaim
                      ? 'Ready now'
                      : canWatchRewardedAd
                      ? 'Watch ad for one more'
                      : 'Banked for play',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: canClaim
                ? controller.claimDailyHint
                : canWatchRewardedAd
                ? _watchRewardedHint
                : null,
            child: Text(
              canClaim
                  ? 'Claim'
                  : canWatchRewardedAd
                  ? 'Watch'
                  : 'Ready',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _watchRewardedHint() async {
    bool earned;
    try {
      earned = await ads.showRewardedHint(placement: 'home_hint');
    } on Object catch (error) {
      debugPrint('Rewarded hint skipped after error: $error');
      earned = false;
    }
    if (earned) {
      controller.grantRewardedHint(placement: 'home_hint');
    }
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    return ArrowPuzzleCard(
      shadow: true,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const Icon(Icons.flag_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${controller.completedLevelCount}/${controller.totalLevels} clear - ${controller.unlockedLevelCount} unlocked',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
