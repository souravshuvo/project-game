import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../application/game_ads.dart';
import '../../application/puzzle_controller.dart';
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
    final allLevelsClear = isFinalLevel && controller.hasCompletedAllLevels;

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
                          allLevelsClear
                              ? 'Every board in this pack is complete.'
                              : 'Completed in ${controller.moveCount} moves',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: ArrowPuzzleColors.mutedInk,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        SizedBox(height: compact ? 16 : 20),
                        _CompletionStats(controller: controller),
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
                                ),
                          icon: Icon(
                            isFinalLevel
                                ? Icons.home_rounded
                                : Icons.arrow_forward_rounded,
                          ),
                          label: Text(
                            isFinalLevel ? 'Back Home' : 'Next Level',
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: controller.retryLevel,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Replay Level'),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: controller.showLevelSelect,
                          icon: const Icon(Icons.grid_view_rounded),
                          label: const Text('Level Select'),
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

  Future<void> _continueAfterOptionalAd({required bool isFinalLevel}) async {
    if (_continuing) {
      return;
    }

    setState(() => _continuing = true);
    try {
      await widget.ads.maybeShowInterstitial(
        placement: isFinalLevel ? 'level_complete_home' : 'level_complete_next',
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
    } else {
      widget.controller.nextLevel();
    }

    if (mounted) {
      setState(() => _continuing = false);
    }
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
  const _CompletionStats({required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    final bestMoves = controller.currentLevelBestMoves;

    return ArrowPuzzleCard(
      shadow: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.military_tech_rounded,
            label: 'Best',
            value: bestMoves == null ? '${controller.moveCount}' : '$bestMoves',
          ),
          _StatItem(
            icon: Icons.local_fire_department_rounded,
            label: 'Streak',
            value: '${controller.streakDays}',
          ),
          _StatItem(
            icon: Icons.lock_open_rounded,
            label: 'Unlocked',
            value: '${controller.unlockedLevelCount}',
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
                  ? 'Claim daily hint'
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
    return Column(
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
    );
  }
}
