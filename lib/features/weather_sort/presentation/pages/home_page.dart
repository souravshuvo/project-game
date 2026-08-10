import 'package:flutter/material.dart';

import '../../application/water_sort_controller.dart';
import '../theme/weather_sort_theme.dart';

class WaterHomePage extends StatelessWidget {
  const WaterHomePage({super.key, required this.controller});

  final WaterSortController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WeatherBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: controller.showSettings,
                    icon: const Icon(Icons.settings_rounded),
                    tooltip: 'Settings',
                  ),
                ),
                const Spacer(),
                const Center(child: _WeatherMark()),
                const SizedBox(height: 22),
                Text(
                  'Weather Lab Sort',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: WeatherSortColors.primaryDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pour rain, sun, and mist into clean weather vessels.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: WeatherSortColors.mutedInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 38),
                FilledButton.icon(
                  onPressed: controller.play,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text('Continue Level ${controller.resumeLevelNumber}'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: controller.showLevelSelect,
                  icon: const Icon(Icons.grid_view_rounded),
                  label: const Text('Levels'),
                ),
                const Spacer(),
                WeatherPanel(
                  shadow: true,
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${controller.completedLevelCount}/${controller.totalLevels} sorted - ${controller.unlockedLevelCount} unlocked',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
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

class _WeatherMark extends StatelessWidget {
  const _WeatherMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 92,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: WeatherSortColors.primary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: WeatherSortColors.primary.withValues(alpha: 0.24),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: _MarkLayer(
                  color: WeatherSortColors.rain,
                  icon: Icons.water_drop_rounded,
                ),
              ),
              SizedBox(height: 6),
              Expanded(
                child: _MarkLayer(
                  color: WeatherSortColors.sun,
                  icon: Icons.wb_sunny_rounded,
                ),
              ),
              SizedBox(height: 6),
              Expanded(
                child: _MarkLayer(
                  color: WeatherSortColors.mist,
                  icon: Icons.air_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarkLayer extends StatelessWidget {
  const _MarkLayer({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(child: Icon(icon, size: 18, color: Colors.white)),
    );
  }
}
