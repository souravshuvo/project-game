import 'dart:async';

import 'package:flutter/material.dart';

import '../../application/water_sort_controller.dart';
import '../../domain/water_lab_goal.dart';
import '../theme/weather_sort_theme.dart';

class WaterLevelCompletePage extends StatelessWidget {
  const WaterLevelCompletePage({super.key, required this.controller});

  final WaterSortController controller;

  @override
  Widget build(BuildContext context) {
    final stars = controller.starsForCurrentAttempt;
    final bestMoves = controller.currentLevelBestMoves ?? controller.moveCount;
    final overPar = controller.moveCount - controller.currentLevel.parMoves;
    final nextLevel = controller.isLastLevel
        ? null
        : controller.allLevels[controller.currentLevelNumber];

    return Scaffold(
      body: WeatherBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.78, end: 1),
                          duration: const Duration(milliseconds: 420),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(scale: value, child: child);
                          },
                          child: const Icon(
                            Icons.check_circle_rounded,
                            size: 96,
                            color: WeatherSortColors.mint,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'Forecast clear',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: WeatherSortColors.primaryDark,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Level ${controller.currentLevelNumber}: ${_rewardLine(stars, overPar)}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: WeatherSortColors.mutedInk,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _StarRow(stars: stars),
                        const SizedBox(height: 14),
                        _RewardBanner(controller: controller),
                        const SizedBox(height: 12),
                        _NextLabGoalBanner(controller: controller),
                        const SizedBox(height: 20),
                        WeatherPanel(
                          shadow: true,
                          child: Wrap(
                            alignment: WrapAlignment.spaceAround,
                            runAlignment: WrapAlignment.center,
                            spacing: 18,
                            runSpacing: 14,
                            children: [
                              _StatItem(
                                icon: Icons.touch_app_rounded,
                                label: 'Moves',
                                value: '${controller.moveCount}',
                              ),
                              _StatItem(
                                icon: Icons.flag_rounded,
                                label: 'Par',
                                value: '${controller.currentLevel.parMoves}',
                              ),
                              _StatItem(
                                icon: Icons.military_tech_rounded,
                                label: 'Best',
                                value: '$bestMoves',
                              ),
                              _StatItem(
                                icon: Icons.bolt_rounded,
                                label: 'Flow',
                                value: '${controller.bestFlowStreak}',
                              ),
                            ],
                          ),
                        ),
                        if (nextLevel != null) ...[
                          const SizedBox(height: 16),
                          _NextForecastPreview(nextLevelName: nextLevel.name),
                        ],
                        const SizedBox(height: 28),
                        FilledButton.icon(
                          onPressed: controller.isContinuingAfterComplete
                              ? null
                              : controller.isLastLevel
                              ? controller.backHome
                              : () {
                                  unawaited(controller.continueToNextLevel());
                                },
                          icon: Icon(
                            controller.isContinuingAfterComplete
                                ? Icons.hourglass_top_rounded
                                : controller.isLastLevel
                                ? Icons.home_rounded
                                : Icons.arrow_forward_rounded,
                          ),
                          label: Text(
                            controller.isContinuingAfterComplete
                                ? 'Preparing'
                                : controller.isLastLevel
                                ? 'Back Home'
                                : 'Continue Campaign',
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: controller.replayLevel,
                          icon: const Icon(Icons.replay_rounded),
                          label: Text(
                            stars == 3
                                ? 'Replay Best Route'
                                : 'Replay for 3 Stars',
                          ),
                        ),
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

  String _rewardLine(int stars, int overPar) {
    if (stars == 3) {
      return 'Par met. A clean forecast.';
    }
    if (overPar == 1) {
      return 'One move over par. Replay to improve your stars.';
    }
    return '$overPar moves over par. Replay to improve your stars.';
  }
}

class _NextLabGoalBanner extends StatelessWidget {
  const _NextLabGoalBanner({required this.controller});

  final WaterSortController controller;

  @override
  Widget build(BuildContext context) {
    final goal = _nextLabGoal(controller.labGoals);

    if (goal == null) {
      return WeatherPanel(
        color: WeatherSortColors.mint.withValues(alpha: 0.11),
        borderColor: WeatherSortColors.mint.withValues(alpha: 0.36),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              color: WeatherSortColors.mint,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'All Lab Goals complete. Replay any forecast to chase a lower move route.',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: WeatherSortColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final color = _labGoalColor(goal);

    return WeatherPanel(
      color: color.withValues(alpha: 0.1),
      borderColor: color.withValues(alpha: 0.36),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(_labGoalIcon(goal), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Next Lab Goal: ${goal.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: WeatherSortColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${goal.current}/${goal.target}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: WeatherSortColors.mutedInk,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: goal.progress,
              color: color,
              backgroundColor: color.withValues(alpha: 0.16),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextForecastPreview extends StatelessWidget {
  const _NextForecastPreview({required this.nextLevelName});

  final String nextLevelName;

  @override
  Widget build(BuildContext context) {
    return WeatherPanel(
      color: WeatherSortColors.wash,
      borderColor: const Color(0xFFC9DAE8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.arrow_forward_rounded,
            color: WeatherSortColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next forecast unlocked',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: WeatherSortColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  nextLevelName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: WeatherSortColors.ink,
                    fontWeight: FontWeight.w900,
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

WaterLabGoal? _nextLabGoal(List<WaterLabGoal> goals) {
  for (final goal in goals) {
    if (!goal.isComplete) {
      return goal;
    }
  }

  return null;
}

IconData _labGoalIcon(WaterLabGoal goal) {
  return switch (goal.kind) {
    WaterLabGoalKind.firstClear => Icons.flag_rounded,
    WaterLabGoalKind.clearForecastSet => Icons.route_rounded,
    WaterLabGoalKind.perfectForecastSet => Icons.auto_awesome_rounded,
    WaterLabGoalKind.starCollector => Icons.star_rounded,
    WaterLabGoalKind.clearCampaign => Icons.emoji_events_rounded,
    WaterLabGoalKind.perfectCampaign => Icons.military_tech_rounded,
  };
}

Color _labGoalColor(WaterLabGoal goal) {
  return switch (goal.kind) {
    WaterLabGoalKind.firstClear => WeatherSortColors.primary,
    WaterLabGoalKind.clearForecastSet => WeatherSortColors.cloud,
    WaterLabGoalKind.perfectForecastSet => WeatherSortColors.sun,
    WaterLabGoalKind.starCollector => WeatherSortColors.coral,
    WaterLabGoalKind.clearCampaign => WeatherSortColors.primaryDark,
    WaterLabGoalKind.perfectCampaign => WeatherSortColors.frost,
  };
}

class _RewardBanner extends StatelessWidget {
  const _RewardBanner({required this.controller});

  final WaterSortController controller;

  @override
  Widget build(BuildContext context) {
    final reward = _completionReward(controller);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: reward.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: reward.color.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(reward.icon, color: reward.color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                reward.message,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: WeatherSortColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

_CompletionReward _completionReward(WaterSortController controller) {
  if (controller.lastCompletionWasFirstClear) {
    return const _CompletionReward(
      message: 'New forecast cleared. The next puzzle is unlocked.',
      icon: Icons.lock_open_rounded,
      color: WeatherSortColors.mint,
    );
  }
  if (controller.lastCompletionImprovedStars) {
    return const _CompletionReward(
      message: 'Star rating improved. Keep chasing clean forecasts.',
      icon: Icons.star_rounded,
      color: WeatherSortColors.sun,
    );
  }
  if (controller.lastCompletionImprovedBestMoves) {
    return const _CompletionReward(
      message: 'New best move count for this forecast.',
      icon: Icons.military_tech_rounded,
      color: WeatherSortColors.primary,
    );
  }

  return const _CompletionReward(
    message: 'Forecast logged. Replay to beat your best route.',
    icon: Icons.replay_rounded,
    color: WeatherSortColors.primary,
  );
}

class _CompletionReward {
  const _CompletionReward({
    required this.message,
    required this.icon,
    required this.color,
  });

  final String message;
  final IconData icon;
  final Color color;
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < 3; index++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.72, end: 1),
              duration: Duration(milliseconds: 240 + index * 80),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Icon(
                index < stars ? Icons.star_rounded : Icons.star_border_rounded,
                size: 42,
                color: WeatherSortColors.sun,
              ),
            ),
          ),
      ],
    );
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
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: WeatherSortColors.mutedInk,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
