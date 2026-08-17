import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../application/game_ads.dart';
import '../../application/puzzle_controller.dart';
import '../../data/campaign_playbook.dart';
import '../theme/arrow_puzzle_theme.dart';
import '../widgets/arrow_puzzle_ad_banner.dart';

class LevelCompletePage extends StatefulWidget {
  LevelCompletePage({super.key, required this.controller, GameAds? ads})
    : ads = ads ?? NoOpGameAds.instance;

  final PuzzleController controller;
  final GameAds ads;

  @override
  State<LevelCompletePage> createState() => _LevelCompletePageState();
}

class _LevelCompletePageState extends State<LevelCompletePage> {
  var _continuing = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final ads = widget.ads;
    final colorScheme = Theme.of(context).colorScheme;
    final isFinalLevel = controller.isLastLevel;
    final currentWave = controller.currentCampaignWave;
    final nextWave = controller.nextCampaignWave;
    final allLevelsClear = isFinalLevel && controller.hasCompletedAllLevels;
    final isNewRecord = controller.lastCompletionWasNewRecord;
    final moveDelta = controller.lastCompletionMoveDelta;
    final bestMoves = controller.currentLevelBestMoves;
    final lastRunScore = controller.lastCompletionRunScore;
    final lastCombo = controller.lastCompletionMaxCombo;
    final bestScore = controller.bestRunScoreForCurrentLevel;
    final isScoreRecord = controller.lastCompletionWasScoreRecord;
    final hasNextMissionInWave =
        currentWave != null && controller.currentLevelNumber < currentWave.endLevel;
    final hasNextWave = nextWave != null;
    final completedInWave = controller.completedLevelsInWaveCount(currentWave);
    late String nextWaveObjective;
    if (nextWave == null) {
      nextWaveObjective = 'Wave complete. Replay now to chase score and combo.';
    } else {
      nextWaveObjective =
          'Wave complete. Next objective: Wave ${nextWave.index} · ${nextWave.title}.';
    }

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
                    padding: EdgeInsets.all(compact ? 18 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: compact ? 8 : 20),
                        _ClearBadge(
                          color: allLevelsClear
                              ? ArrowPuzzleColors.mint
                              : colorScheme.primary,
                          size: compact ? 108 : 132,
                        ),
                        SizedBox(height: compact ? 18 : 24),
                        Text(
                          allLevelsClear
                              ? 'All Levels Clear'
                              : 'Level ${controller.currentLevelNumber} Clear',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: ArrowPuzzleColors.primaryDark,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _completionSubtitle(
                            isNewRecord: isNewRecord,
                            moveCount: controller.moveCount,
                            bestMoves: bestMoves,
                            moveDelta: moveDelta,
                          ),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: ArrowPuzzleColors.mutedInk,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        SizedBox(height: compact ? 16 : 20),
                        _CompletionStats(
                          controller: controller,
                          isNewRecord: isNewRecord,
                          moveDelta: moveDelta,
                          runScore: lastRunScore,
                          combo: lastCombo,
                          bestScore: bestScore,
                        ),
                        if (currentWave != null) ...[
                          const SizedBox(height: 12),
                          _CampaignProgressCard(
                            controller: controller,
                            currentWave: currentWave,
                            completedInWave: completedInWave,
                            nextWaveObjective: nextWaveObjective,
                          ),
                        ],
                        if (isNewRecord) ...[
                          const SizedBox(height: 12),
                          _NewRecordBadge(
                            isNewRecord: isNewRecord,
                            moveDelta: moveDelta,
                          ),
                        ],
                        if (isScoreRecord) ...[
                          const SizedBox(height: 12),
                          _ScoreRecordBadge(
                            runScore: lastRunScore,
                            bestScore: bestScore,
                          ),
                        ],
                        const SizedBox(height: 12),
                        AnimatedBuilder(
                          animation: ads,
                          builder: (context, _) {
                            return _PostClearBoostCard(
                              controller: controller,
                              ads: ads,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        ArrowPuzzleAdBanner(
                          ads: ads,
                          placement: 'level_complete',
                        ),
                        SizedBox(height: compact ? 24 : 40),
                        FilledButton.icon(
                          onPressed: _continuing
                              ? null
                              : () => _continueAfterOptionalAd(
                                  isFinalLevel: isFinalLevel,
                                  currentWave: currentWave,
                                  hasNextMissionInWave: hasNextMissionInWave,
                                  hasNextWave: hasNextWave,
                                ),
                          icon: Icon(
                            _nextFlowIcon(
                              isFinalLevel: isFinalLevel,
                              currentWave: currentWave,
                              hasNextMissionInWave: hasNextMissionInWave,
                              hasNextWave: hasNextWave,
                            ),
                          ),
                          label: Text(
                            _nextFlowLabel(
                              isFinalLevel: isFinalLevel,
                              currentWave: currentWave,
                              hasNextMissionInWave: hasNextMissionInWave,
                              hasNextWave: hasNextWave,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: controller.retryLevel,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Replay Mission'),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: currentWave == null
                              ? controller.showLevelSelect
                              : controller.startNextCampaignWaveOrCurrent,
                          icon: const Icon(Icons.grid_view_rounded),
                          label: Text(currentWave == null ? 'Campaign' : 'Missions'),
                        ),
                        SizedBox(height: compact ? 8 : 20),
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

  String _completionSubtitle({
    required bool isNewRecord,
    required int moveCount,
    required int? bestMoves,
    required int? moveDelta,
  }) {
    final safeMoveDelta = moveDelta ?? 0;
    final targetDelta = safeMoveDelta <= 0 ? 1 : safeMoveDelta;

    if (isNewRecord && moveDelta == null) {
      return 'First clear with $moveCount moves. New high score set.';
    }
    if (isNewRecord) {
      return '$moveCount moves. New best by $moveDelta move(s)!';
    }
    if (bestMoves == null) {
      return 'Completed in $moveCount moves.';
    }
    return 'Completed in $moveCount moves. Best is $bestMoves. Try $targetDelta fewer to beat it.';
  }

  Future<void> _continueAfterOptionalAd({
    required bool isFinalLevel,
    required CampaignWave? currentWave,
    required bool hasNextMissionInWave,
    required bool hasNextWave,
  }) async {
    if (_continuing) {
      return;
    }

    setState(() => _continuing = true);
    try {
      await widget.ads.maybeShowInterstitial(
        placement: _nextFlowPlacement(
          isFinalLevel: isFinalLevel,
          currentWave: currentWave,
          hasNextMissionInWave: hasNextMissionInWave,
          hasNextWave: hasNextWave,
        ),
        levelNumber: widget.controller.currentLevelNumber,
      );
    } on Object catch (error) {
      debugPrint('Interstitial skipped after error: $error');
    }

    if (!mounted) {
      return;
    }

    if (isFinalLevel) {
      widget.controller.backHome();
    } else if (hasNextMissionInWave) {
      widget.controller.nextLevel();
    } else if (currentWave != null && hasNextWave) {
      widget.controller.startCampaignWave(currentWave.index + 1);
    } else {
      widget.controller.nextLevel();
    }

    if (mounted) {
      setState(() => _continuing = false);
    }
  }

  String _nextFlowLabel({
    required bool isFinalLevel,
    required CampaignWave? currentWave,
    required bool hasNextMissionInWave,
    required bool hasNextWave,
  }) {
    if (isFinalLevel) {
      return 'Back Home';
    }
    if (hasNextMissionInWave) {
      return 'Next Mission';
    }
    if (currentWave != null && hasNextWave) {
      return 'Next Wave';
    }
    return 'Next Level';
  }

  String _nextFlowPlacement({
    required bool isFinalLevel,
    required CampaignWave? currentWave,
    required bool hasNextMissionInWave,
    required bool hasNextWave,
  }) {
    if (isFinalLevel) {
      return 'level_complete_home';
    }
    if (hasNextMissionInWave) {
      return 'level_complete_next_mission';
    }
    if (currentWave != null && hasNextWave) {
      return 'level_complete_next_wave';
    }
    return 'level_complete_next';
  }

  IconData _nextFlowIcon({
    required bool isFinalLevel,
    required CampaignWave? currentWave,
    required bool hasNextMissionInWave,
    required bool hasNextWave,
  }) {
    if (isFinalLevel) {
      return Icons.home_rounded;
    }
    if (hasNextMissionInWave) {
      return Icons.keyboard_arrow_right_rounded;
    }
    if (currentWave != null && hasNextWave) {
      return Icons.alt_route_rounded;
    }
    return Icons.arrow_forward_rounded;
  }
}

class _ClearBadge extends StatelessWidget {
  const _ClearBadge({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.75, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _CelebrationBurstPainter(),
          child: Center(
            child: Icon(
              Icons.check_circle_rounded,
              size: size * 0.72,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _CelebrationBurstPainter extends CustomPainter {
  const _CelebrationBurstPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paints = [
      Paint()
        ..color = ArrowPuzzleColors.amber.withValues(alpha: 0.72)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
      Paint()
        ..color = ArrowPuzzleColors.mint.withValues(alpha: 0.54)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
      Paint()
        ..color = ArrowPuzzleColors.coral.withValues(alpha: 0.5)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    ];

    for (var i = 0; i < 12; i++) {
      final angle = i * 0.52;
      final start = Offset(
        center.dx + 52 * math.cos(angle),
        center.dy + 52 * math.sin(angle),
      );
      final end = Offset(
        center.dx + 64 * math.cos(angle),
        center.dy + 64 * math.sin(angle),
      );
      canvas.drawLine(start, end, paints[i % paints.length]);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompletionStats extends StatelessWidget {
  const _CompletionStats({
    required this.controller,
    required this.isNewRecord,
    required this.moveDelta,
    required this.runScore,
    required this.combo,
    required this.bestScore,
  });

  final PuzzleController controller;
  final bool isNewRecord;
  final int? moveDelta;
  final int? runScore;
  final int? combo;
  final int? bestScore;

  @override
  Widget build(BuildContext context) {
    final bestMoves = controller.currentLevelBestMoves;
    final safeMoveDelta = moveDelta ?? 0;
    final targetDelta = safeMoveDelta <= 0 ? 1 : safeMoveDelta;

    return ArrowPuzzleCard(
      shadow: true,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        runSpacing: 12,
        children: [
          _StatItem(
            icon: Icons.stars_rounded,
            label: 'Score',
            value: runScore == null ? '-' : '$runScore',
          ),
          _StatItem(
            icon: Icons.keyboard_double_arrow_up_rounded,
            label: 'This',
            value: '${controller.moveCount}',
          ),
          _StatItem(
            icon: Icons.military_tech_rounded,
            label: 'Best',
            value: bestMoves == null ? '-' : '$bestMoves',
          ),
          _StatItem(
            icon: Icons.stacked_line_chart_rounded,
            label: isNewRecord ? 'Lead' : 'Target',
            value: moveDelta == null
                ? '-'
                : isNewRecord
                ? '-$moveDelta'
                : '+$targetDelta',
          ),
          _StatItem(
            icon: Icons.local_fire_department_rounded,
            label: 'Streak',
            value: '${controller.streakDays}',
          ),
          if (combo != null)
            _StatItem(
              icon: Icons.flash_on_rounded,
              label: 'Top Combo',
              value: '$combo',
            ),
          if (bestScore != null)
            _StatItem(
              icon: Icons.emoji_events_rounded,
              label: isNewRecord ? 'Best Score' : 'Best Score',
              value: '$bestScore',
            ),
        ],
      ),
    );
  }
}

class _CampaignProgressCard extends StatelessWidget {
  const _CampaignProgressCard({
    required this.controller,
    required this.currentWave,
    required this.completedInWave,
    required this.nextWaveObjective,
  });

  final PuzzleController controller;
  final CampaignWave currentWave;
  final int completedInWave;
  final String nextWaveObjective;

  @override
  Widget build(BuildContext context) {
    final hasNextInWave = controller.currentLevelNumber < currentWave.endLevel;
    final nextWaveHint = hasNextInWave ? 'Keep momentum: finish Mission ${controller.currentLevelNumber + 1} in this wave.' : nextWaveObjective;
    final nextFlowHint = hasNextInWave
        ? 'Keep momentum: finish Mission ${controller.currentLevelNumber + 1} in this wave.'
        : nextWaveHint;
    final targetScore = controller.bestRunScoreForCurrentLevel;
    final scoreHint = targetScore == null
        ? 'Score chase unlocked for this mission on next attempt.'
        : 'Try for one cleaner replay to beat your best score of $targetScore.';

    return ArrowPuzzleCard(
      borderColor: const Color(0xFFD5F0FF),
      color: const Color(0xFFF2F9FF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.alt_route_rounded, color: ArrowPuzzleColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Wave ${currentWave.index}: ${currentWave.title}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentWave.objective,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Wave progress: $completedInWave / ${currentWave.levelCount}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: ArrowPuzzleColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            nextFlowHint,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Reward cue: ${currentWave.reward}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: ArrowPuzzleColors.mutedInk,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            scoreHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ScoreRecordBadge extends StatelessWidget {
  const _ScoreRecordBadge({required this.runScore, required this.bestScore});

  final int? runScore;
  final int? bestScore;

  @override
  Widget build(BuildContext context) {
    if (runScore == null || bestScore == null) {
      return const SizedBox.shrink();
    }

    return ArrowPuzzleCard(
      color: const Color(0xFFFFF3CC),
      borderColor: const Color(0xFFFFD15C),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFFD88A00)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Score record set at $runScore! Replay in one clean, faster run.',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: ArrowPuzzleColors.primaryDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewRecordBadge extends StatelessWidget {
  const _NewRecordBadge({required this.isNewRecord, required this.moveDelta});

  final bool isNewRecord;
  final int? moveDelta;

  @override
  Widget build(BuildContext context) {
    if (!isNewRecord) {
      return const SizedBox.shrink();
    }

    final safeMoveDelta = moveDelta ?? 1;
    final challengeText = moveDelta == null
        ? 'Clean baseline set'
        : 'Improve next run by staying closer than ${math.max(safeMoveDelta, 1)} moves';

    return ArrowPuzzleCard(
      color: ArrowPuzzleColors.mintSoft,
      borderColor: const Color(0xFF9DDDBD),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded, color: ArrowPuzzleColors.mint),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              challengeText,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: ArrowPuzzleColors.primaryDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostClearBoostCard extends StatelessWidget {
  const _PostClearBoostCard({required this.controller, required this.ads});

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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.lightbulb_rounded, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              canClaim
                  ? 'Claim your daily hint'
                  : canWatchRewardedAd
                  ? 'Watch ad for one hint'
                  : '${controller.hintCount} hints ready',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
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
                  : 'Done',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _watchRewardedHint() async {
    bool earned;
    try {
      earned = await ads.showRewardedHint(placement: 'complete_hint');
    } on Object catch (error) {
      debugPrint('Rewarded hint skipped after error: $error');
      earned = false;
    }
    if (earned) {
      controller.grantRewardedHint(placement: 'complete_hint');
    }
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
