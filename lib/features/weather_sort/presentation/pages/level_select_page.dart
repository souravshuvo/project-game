import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../application/water_sort_controller.dart';
import '../theme/weather_sort_theme.dart';

class WaterLevelSelectPage extends StatelessWidget {
  const WaterLevelSelectPage({super.key, required this.controller});

  final WaterSortController controller;

  static const _forecastSets = [
    _ForecastSet(
      title: 'Clear Skies',
      detail: 'Learn the lab with rain, sun, and mist.',
      icon: Icons.wb_sunny_rounded,
      color: WeatherSortColors.sun,
      startIndex: 0,
      endIndex: 9,
    ),
    _ForecastSet(
      title: 'Cloud Shift',
      detail: 'Work through denser four-essence forecasts.',
      icon: Icons.cloud_rounded,
      color: WeatherSortColors.cloud,
      startIndex: 10,
      endIndex: 19,
    ),
    _ForecastSet(
      title: 'Frost Line',
      detail: 'Bring every weather essence into balance.',
      icon: Icons.ac_unit_rounded,
      color: WeatherSortColors.frost,
      startIndex: 20,
      endIndex: 29,
    ),
    _ForecastSet(
      title: 'Pressure Systems',
      detail: 'Hold tighter recovery routes through five-essence boards.',
      icon: Icons.thunderstorm_rounded,
      color: WeatherSortColors.coral,
      startIndex: 30,
      endIndex: 39,
    ),
    _ForecastSet(
      title: 'Lab Mastery',
      detail: 'Complete compact forecasts with every essence in play.',
      icon: Icons.auto_awesome_rounded,
      color: WeatherSortColors.primary,
      startIndex: 40,
      endIndex: 49,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: controller.backHome,
          icon: const Icon(Icons.home_rounded),
          tooltip: 'Home',
        ),
        title: const Text('Campaign Map'),
      ),
      body: WeatherBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            children: [
              Text(
                'Forecast campaign',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: WeatherSortColors.primaryDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${controller.completedLevelCount}/${controller.totalLevels} forecasts sorted | ${controller.earnedStarCount} best stars',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: WeatherSortColors.mutedInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _MapResumePanel(controller: controller),
              const SizedBox(height: 22),
              for (final forecastSet in _forecastSets)
                if (forecastSet.startIndex < controller.totalLevels)
                  _ForecastSetSection(
                    controller: controller,
                    forecastSet: forecastSet,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapResumePanel extends StatelessWidget {
  const _MapResumePanel({required this.controller});

  final WaterSortController controller;

  @override
  Widget build(BuildContext context) {
    final level = controller.allLevels[controller.resumeLevelNumber - 1];

    return WeatherPanel(
      shadow: true,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: WeatherSortColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const SizedBox(
              width: 46,
              height: 46,
              child: Icon(
                Icons.play_arrow_rounded,
                color: WeatherSortColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resume route',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: WeatherSortColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Forecast ${controller.resumeLevelNumber}: ${level.name}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: WeatherSortColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Par ${level.parMoves} | ${level.tubeSymbols.length} vessels',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: WeatherSortColors.mutedInk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 86,
            child: FilledButton(
              onPressed: controller.play,
              child: const Text('Play'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastSet {
  const _ForecastSet({
    required this.title,
    required this.detail,
    required this.icon,
    required this.color,
    required this.startIndex,
    required this.endIndex,
  });

  final String title;
  final String detail;
  final IconData icon;
  final Color color;
  final int startIndex;
  final int endIndex;
}

class _ForecastSetSection extends StatelessWidget {
  const _ForecastSetSection({
    required this.controller,
    required this.forecastSet,
  });

  final WaterSortController controller;
  final _ForecastSet forecastSet;

  @override
  Widget build(BuildContext context) {
    final lastIndex = math.min(
      forecastSet.endIndex,
      controller.totalLevels - 1,
    );
    final indexes = List<int>.generate(
      lastIndex - forecastSet.startIndex + 1,
      (offset) => forecastSet.startIndex + offset,
    );
    final completedCount = indexes
        .where(
          (index) => controller.isLevelComplete(controller.allLevels[index].id),
        )
        .length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: forecastSet.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(forecastSet.icon, color: forecastSet.color),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      forecastSet.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      forecastSet.detail,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: WeatherSortColors.mutedInk,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$completedCount/${indexes.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: forecastSet.color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: indexes.isEmpty ? 0 : completedCount / indexes.length,
              color: forecastSet.color,
              backgroundColor: forecastSet.color.withValues(alpha: 0.16),
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 370 ? 4 : 5;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemCount: indexes.length,
                itemBuilder: (context, offset) => _LevelTile(
                  controller: controller,
                  index: indexes[offset],
                  accentColor: forecastSet.color,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.controller,
    required this.index,
    required this.accentColor,
  });

  final WaterSortController controller;
  final int index;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final level = controller.allLevels[index];
    final isUnlocked = controller.isLevelUnlocked(index);
    final isComplete = controller.isLevelComplete(level.id);
    final stars = controller.bestStarsForLevel(level.id) ?? 0;
    final foreground = isUnlocked
        ? WeatherSortColors.ink
        : WeatherSortColors.mutedInk.withValues(alpha: 0.55);

    return Semantics(
      button: isUnlocked,
      label: isUnlocked
          ? 'Level ${index + 1}, ${level.name}, ${isComplete ? '$stars stars earned' : 'ready to play'}'
          : 'Level ${index + 1}, locked',
      child: Material(
        color: isComplete
            ? accentColor.withValues(alpha: 0.12)
            : isUnlocked
            ? Colors.white
            : const Color(0xFFECEFF6),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: isUnlocked
              ? () => controller.selectLevel(index, source: 'forecast_archive')
              : null,
          borderRadius: BorderRadius.circular(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isComplete ? accentColor : WeatherSortColors.line,
                width: isComplete ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isComplete
                      ? Icons.check_circle_rounded
                      : isUnlocked
                      ? Icons.play_circle_rounded
                      : Icons.lock_rounded,
                  color: isComplete ? accentColor : foreground,
                  size: 23,
                ),
                const SizedBox(height: 5),
                Text(
                  '${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (isComplete)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var star = 0; star < 3; star++)
                        Icon(
                          star < stars
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: WeatherSortColors.sun,
                          size: 14,
                        ),
                    ],
                  )
                else
                  Text(
                    isUnlocked ? 'Play' : 'Locked',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
