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
    return Scaffold(
      body: GameBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 720;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.all(compact ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: controller.showSettings,
                            icon: const Icon(Icons.settings_rounded),
                            tooltip: 'Settings',
                          ),
                        ),
                        SizedBox(height: compact ? 12 : 36),
                        Center(
                          child: ArrowPuzzleBrandMark(size: compact ? 78 : 92),
                        ),
                        SizedBox(height: compact ? 16 : 22),
                        Text(
                          'Arrow Puzzle',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: ArrowPuzzleColors.primaryDark,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap arrows with clear paths and slide them off the board.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: ArrowPuzzleColors.mutedInk,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: compact ? 24 : 40),
                        FilledButton.icon(
                          onPressed: controller.play,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(
                            'Continue Level ${controller.resumeLevelNumber}',
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: controller.showLevelSelect,
                          icon: const Icon(Icons.grid_view_rounded),
                          label: const Text('Level Select'),
                        ),
                        const SizedBox(height: 16),
                        _DailyCard(controller: controller),
                        const SizedBox(height: 12),
                        AnimatedBuilder(
                          animation: ads,
                          builder: (context, _) {
                            return _HintCard(controller: controller, ads: ads);
                          },
                        ),
                        const SizedBox(height: 12),
                        ArrowPuzzleAdBanner(ads: ads, placement: 'home_bottom'),
                        SizedBox(height: compact ? 18 : 34),
                        _ProgressCard(controller: controller),
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

class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    final isComplete = controller.isDailyGoalComplete;
    final colorScheme = Theme.of(context).colorScheme;

    return ArrowPuzzleCard(
      color: isComplete
          ? ArrowPuzzleColors.mintSoft
          : ArrowPuzzleColors.amberSoft,
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
                      : 'Daily Level ${controller.dailyChallengeLevelNumber}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  isComplete
                      ? 'Come back tomorrow for the next run.'
                      : controller.dailyChallengeLevel.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: controller.startDailyChallenge,
            icon: Icon(
              isComplete ? Icons.replay_rounded : Icons.arrow_forward_rounded,
            ),
            color: colorScheme.primary,
            tooltip: 'Play daily level',
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  canClaim
                      ? 'Ready now'
                      : canWatchRewardedAd
                      ? 'Optional ad for one more'
                      : 'Banked for later',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: canClaim
                ? controller.claimDailyHint
                : canWatchRewardedAd
                ? _watchRewardedHint
                : null,
            icon: Icon(
              canClaim
                  ? Icons.add_circle_rounded
                  : canWatchRewardedAd
                  ? Icons.play_circle_rounded
                  : Icons.check_rounded,
            ),
            color: colorScheme.primary,
            tooltip: canWatchRewardedAd ? 'Watch ad for hint' : 'Claim hint',
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
