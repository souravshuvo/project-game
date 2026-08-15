import 'package:flutter/material.dart';

import '../../application/water_sort_controller.dart';
import '../../domain/water_lab_goal.dart';
import '../../domain/water_level.dart';
import '../theme/weather_sort_theme.dart';

class WaterHomePage extends StatelessWidget {
  const WaterHomePage({super.key, required this.controller});

  final WaterSortController controller;

  @override
  Widget build(BuildContext context) {
    final nextLevel = controller.allLevels[controller.resumeLevelNumber - 1];

    return Scaffold(
      body: WeatherBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight > 36
                        ? constraints.maxHeight - 36
                        : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HubHeader(controller: controller),
                      const SizedBox(height: 18),
                      _NextForecastPanel(
                        controller: controller,
                        nextLevel: nextLevel,
                      ),
                      const SizedBox(height: 14),
                      _MissionPanel(
                        controller: controller,
                        nextLevel: nextLevel,
                      ),
                      const SizedBox(height: 14),
                      _CampaignProgressPanel(controller: controller),
                      const SizedBox(height: 14),
                      _LabGoalsPanel(controller: controller),
                      const SizedBox(height: 14),
                      _ForecastSetStrip(controller: controller),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: controller.showLevelSelect,
                        icon: const Icon(Icons.route_rounded),
                        label: const Text('Open Campaign Map'),
                      ),
                      const SizedBox(height: 14),
                      const _QuickRule(),
                    ],
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

class _HubHeader extends StatelessWidget {
  const _HubHeader({required this.controller});

  final WaterSortController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 132,
          height: 58,
          child: _WeatherMark(compact: true),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weather Lab Sort',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: WeatherSortColors.primaryDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Plan clean pours, beat par, unlock the forecast route.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: WeatherSortColors.mutedInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: controller.showSettings,
          icon: const Icon(Icons.settings_rounded),
          tooltip: 'Settings',
        ),
      ],
    );
  }
}

class _MissionPanel extends StatelessWidget {
  const _MissionPanel({required this.controller, required this.nextLevel});

  final WaterSortController controller;
  final WaterLevel nextLevel;

  @override
  Widget build(BuildContext context) {
    final stars = controller.bestStarsForLevel(nextLevel.id) ?? 0;
    final bestMoves = controller.bestMovesForLevel(nextLevel.id);

    return WeatherPanel(
      color: WeatherSortColors.wash,
      borderColor: const Color(0xFFC9DAE8),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: WeatherSortColors.line),
            ),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                Icons.emoji_events_rounded,
                color: WeatherSortColors.sun,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stars == 3 ? 'Replay challenge' : 'Current mission',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: WeatherSortColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  stars == 3
                      ? 'Beat your best route${bestMoves == null ? '' : ' of $bestMoves moves'}.'
                      : 'Clear ${nextLevel.name} at par for 3 stars.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: WeatherSortColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < 3; index++)
                Icon(
                  index < stars
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: WeatherSortColors.sun,
                  size: 18,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NextForecastPanel extends StatelessWidget {
  const _NextForecastPanel({required this.controller, required this.nextLevel});

  final WaterSortController controller;
  final WaterLevel nextLevel;

  @override
  Widget build(BuildContext context) {
    return WeatherPanel(
      shadow: true,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _forecastSetNameFor(controller.resumeLevelNumber).toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: WeatherSortColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const _ForecastBadge(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextLevel.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Forecast ${controller.resumeLevelNumber} | ${nextLevel.tubeSymbols.length} vessels | Par ${nextLevel.parMoves}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: WeatherSortColors.mutedInk,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              color: WeatherSortColors.wash,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFC9DAE8)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.flag_rounded, color: WeatherSortColors.sun),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Goal: clear in ${nextLevel.parMoves} moves for 3 stars.',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: WeatherSortColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: controller.play,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text('Play Forecast ${controller.resumeLevelNumber}'),
          ),
        ],
      ),
    );
  }
}

class _CampaignProgressPanel extends StatelessWidget {
  const _CampaignProgressPanel({required this.controller});

  final WaterSortController controller;

  @override
  Widget build(BuildContext context) {
    final progress = controller.completedLevelCount / controller.totalLevels;
    final setProgress = _forecastSetProgress(controller);

    return WeatherPanel(
      color: Colors.white.withValues(alpha: 0.82),
      borderColor: WeatherSortColors.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _ProgressMetric(
                  icon: Icons.check_circle_rounded,
                  value:
                      '${controller.completedLevelCount}/${controller.totalLevels}',
                  label: 'Sorted',
                  color: WeatherSortColors.mint,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProgressMetric(
                  icon: Icons.star_rounded,
                  value:
                      '${controller.earnedStarCount}/${controller.maxStarCount}',
                  label: 'Stars',
                  color: WeatherSortColors.sun,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: progress,
              color: WeatherSortColors.primary,
              backgroundColor: WeatherSortColors.primary.withValues(
                alpha: 0.12,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            '${_forecastSetNameFor(controller.resumeLevelNumber)} set: ${setProgress.cleared}/${setProgress.total} clear',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: WeatherSortColors.mutedInk,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabGoalsPanel extends StatelessWidget {
  const _LabGoalsPanel({required this.controller});

  final WaterSortController controller;

  @override
  Widget build(BuildContext context) {
    final goals = controller.labGoals;
    final visibleGoals = _visibleLabGoals(goals);

    if (visibleGoals.isEmpty) {
      return const SizedBox.shrink();
    }

    return WeatherPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: WeatherSortColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lab goals',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: WeatherSortColors.primaryDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${controller.completedLabGoalCount}/${goals.length} complete',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: WeatherSortColors.mutedInk,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < visibleGoals.length; index++) ...[
            if (index > 0) const SizedBox(height: 12),
            _LabGoalRow(goal: visibleGoals[index]),
          ],
        ],
      ),
    );
  }
}

class _LabGoalRow extends StatelessWidget {
  const _LabGoalRow({required this.goal});

  final WaterLabGoal goal;

  @override
  Widget build(BuildContext context) {
    final color = _goalColor(goal);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.32)),
          ),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(_goalIcon(goal), color: color, size: 21),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      goal.title,
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
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: WeatherSortColors.mutedInk,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                goal.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: WeatherSortColors.mutedInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  minHeight: 5,
                  value: goal.progress,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ForecastSetStrip extends StatelessWidget {
  const _ForecastSetStrip({required this.controller});

  final WaterSortController controller;

  @override
  Widget build(BuildContext context) {
    return WeatherPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.route_rounded,
                color: WeatherSortColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Forecast route',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: WeatherSortColors.primaryDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _forecastSetMetas.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final meta = _forecastSetMetas[index];
                final progress = _forecastSetProgressForRange(
                  controller,
                  meta.startIndex,
                  meta.endIndex,
                );
                final isCurrent =
                    controller.resumeLevelNumber - 1 >= meta.startIndex &&
                    controller.resumeLevelNumber - 1 <= meta.endIndex;

                return SizedBox(
                  width: 146,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? meta.color.withValues(alpha: 0.14)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrent ? meta.color : WeatherSortColors.line,
                        width: isCurrent ? 1.5 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(meta.icon, color: meta.color, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  meta.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              minHeight: 5,
                              value: progress.total == 0
                                  ? 0
                                  : progress.cleared / progress.total,
                              color: meta.color,
                              backgroundColor: meta.color.withValues(
                                alpha: 0.16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${progress.cleared}/${progress.total} clear',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: WeatherSortColors.mutedInk,
                                  fontWeight: FontWeight.w800,
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
        ],
      ),
    );
  }
}

List<WaterLabGoal> _visibleLabGoals(List<WaterLabGoal> goals) {
  final activeGoals = goals.where((goal) => !goal.isComplete).take(3).toList();
  if (activeGoals.length == 3) {
    return activeGoals;
  }

  return [
    ...activeGoals,
    ...goals.where((goal) => goal.isComplete).take(3 - activeGoals.length),
  ];
}

IconData _goalIcon(WaterLabGoal goal) {
  if (goal.isComplete) {
    return Icons.check_circle_rounded;
  }

  return switch (goal.kind) {
    WaterLabGoalKind.firstClear => Icons.flag_rounded,
    WaterLabGoalKind.clearForecastSet => Icons.route_rounded,
    WaterLabGoalKind.perfectForecastSet => Icons.auto_awesome_rounded,
    WaterLabGoalKind.starCollector => Icons.star_rounded,
    WaterLabGoalKind.clearCampaign => Icons.emoji_events_rounded,
    WaterLabGoalKind.perfectCampaign => Icons.military_tech_rounded,
  };
}

Color _goalColor(WaterLabGoal goal) {
  if (goal.isComplete) {
    return WeatherSortColors.mint;
  }

  return switch (goal.kind) {
    WaterLabGoalKind.firstClear => WeatherSortColors.primary,
    WaterLabGoalKind.clearForecastSet => WeatherSortColors.cloud,
    WaterLabGoalKind.perfectForecastSet => WeatherSortColors.sun,
    WaterLabGoalKind.starCollector => WeatherSortColors.coral,
    WaterLabGoalKind.clearCampaign => WeatherSortColors.primaryDark,
    WaterLabGoalKind.perfectCampaign => WeatherSortColors.frost,
  };
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: WeatherSortColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: WeatherSortColors.mutedInk,
                      fontWeight: FontWeight.w700,
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

({int cleared, int total}) _forecastSetProgress(
  WaterSortController controller,
) {
  final resumeIndex = controller.resumeLevelNumber - 1;
  final setStart = (resumeIndex ~/ 10) * 10;
  final requestedSetEnd = setStart + 10;
  final setEnd = requestedSetEnd > controller.totalLevels
      ? controller.totalLevels
      : requestedSetEnd;
  return _forecastSetProgressForRange(controller, setStart, setEnd - 1);
}

({int cleared, int total}) _forecastSetProgressForRange(
  WaterSortController controller,
  int startIndex,
  int endIndex,
) {
  if (startIndex >= controller.totalLevels) {
    return (cleared: 0, total: 0);
  }
  final safeEnd = endIndex >= controller.totalLevels
      ? controller.totalLevels - 1
      : endIndex;
  final levels = controller.allLevels.getRange(startIndex, safeEnd + 1);
  final cleared = levels
      .where((level) => controller.isLevelComplete(level.id))
      .length;

  return (cleared: cleared, total: safeEnd - startIndex + 1);
}

String _forecastSetNameFor(int levelNumber) {
  return switch ((levelNumber - 1) ~/ 10) {
    0 => 'Clear Skies',
    1 => 'Cloud Shift',
    2 => 'Frost Line',
    3 => 'Pressure Systems',
    _ => 'Lab Mastery',
  };
}

const _forecastSetMetas = [
  _ForecastSetMeta(
    title: 'Clear Skies',
    icon: Icons.wb_sunny_rounded,
    color: WeatherSortColors.sun,
    startIndex: 0,
    endIndex: 9,
  ),
  _ForecastSetMeta(
    title: 'Cloud Shift',
    icon: Icons.cloud_rounded,
    color: WeatherSortColors.cloud,
    startIndex: 10,
    endIndex: 19,
  ),
  _ForecastSetMeta(
    title: 'Frost Line',
    icon: Icons.ac_unit_rounded,
    color: WeatherSortColors.frost,
    startIndex: 20,
    endIndex: 29,
  ),
  _ForecastSetMeta(
    title: 'Pressure',
    icon: Icons.thunderstorm_rounded,
    color: WeatherSortColors.coral,
    startIndex: 30,
    endIndex: 39,
  ),
  _ForecastSetMeta(
    title: 'Mastery',
    icon: Icons.auto_awesome_rounded,
    color: WeatherSortColors.primary,
    startIndex: 40,
    endIndex: 49,
  ),
];

class _ForecastSetMeta {
  const _ForecastSetMeta({
    required this.title,
    required this.icon,
    required this.color,
    required this.startIndex,
    required this.endIndex,
  });

  final String title;
  final IconData icon;
  final Color color;
  final int startIndex;
  final int endIndex;
}

class _QuickRule extends StatelessWidget {
  const _QuickRule();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.lightbulb_outline_rounded,
          color: WeatherSortColors.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Tap a vessel, then choose an empty or matching vessel to pour.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: WeatherSortColors.mutedInk,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ForecastBadge extends StatelessWidget {
  const _ForecastBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: WeatherSortColors.wash,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const SizedBox(
        width: 48,
        height: 48,
        child: Icon(
          Icons.water_drop_rounded,
          color: WeatherSortColors.primary,
          size: 26,
        ),
      ),
    );
  }
}

class _WeatherMark extends StatelessWidget {
  const _WeatherMark({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final mark = const SizedBox(
      width: 236,
      height: 96,
      child: _WeatherMarkVessels(),
    );

    if (!compact) {
      return mark;
    }

    return const FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      child: SizedBox(width: 236, height: 96, child: _WeatherMarkVessels()),
    );
  }
}

class _WeatherMarkVessels extends StatelessWidget {
  const _WeatherMarkVessels();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _ForecastVessel(
          layers: [
            _ForecastLayer(
              color: WeatherSortColors.rain,
              icon: Icons.water_drop_rounded,
            ),
            _ForecastLayer(
              color: WeatherSortColors.sun,
              icon: Icons.wb_sunny_rounded,
            ),
          ],
        ),
        _ForecastVessel(
          layers: [
            _ForecastLayer(
              color: WeatherSortColors.mist,
              icon: Icons.air_rounded,
            ),
            _ForecastLayer(
              color: WeatherSortColors.cloud,
              icon: Icons.cloud_rounded,
            ),
            _ForecastLayer(
              color: WeatherSortColors.rain,
              icon: Icons.water_drop_rounded,
            ),
          ],
        ),
        _ForecastVessel(
          layers: [
            _ForecastLayer(
              color: WeatherSortColors.frost,
              icon: Icons.ac_unit_rounded,
            ),
            _ForecastLayer(
              color: WeatherSortColors.cloud,
              icon: Icons.cloud_rounded,
            ),
          ],
        ),
        _ForecastVessel(
          layers: [
            _ForecastLayer(
              color: WeatherSortColors.sun,
              icon: Icons.wb_sunny_rounded,
            ),
            _ForecastLayer(
              color: WeatherSortColors.mist,
              icon: Icons.air_rounded,
            ),
            _ForecastLayer(
              color: WeatherSortColors.frost,
              icon: Icons.ac_unit_rounded,
            ),
          ],
        ),
      ],
    );
  }
}

class _ForecastLayer {
  const _ForecastLayer({required this.color, required this.icon});

  final Color color;
  final IconData icon;
}

class _ForecastVessel extends StatelessWidget {
  const _ForecastVessel({required this.layers});

  final List<_ForecastLayer> layers;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 92,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
          border: Border.all(
            color: WeatherSortColors.primaryDark.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 12, 5, 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              for (final layer in layers)
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: layer.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(layer.icon, size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
