import 'package:flutter/material.dart';

import '../../application/water_sort_controller.dart';
import '../theme/weather_sort_theme.dart';

class WaterLevelCompletePage extends StatelessWidget {
  const WaterLevelCompletePage({super.key, required this.controller});

  final WaterSortController controller;

  @override
  Widget build(BuildContext context) {
    final stars = controller.starsForCurrentAttempt;
    final bestMoves = controller.currentLevelBestMoves ?? controller.moveCount;

    return Scaffold(
      body: WeatherBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
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
                  'Forecast Sorted',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: WeatherSortColors.primaryDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                _StarRow(stars: stars),
                const SizedBox(height: 20),
                WeatherPanel(
                  shadow: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                    ],
                  ),
                ),
                const SizedBox(height: 34),
                FilledButton.icon(
                  onPressed: controller.isLastLevel
                      ? controller.backHome
                      : controller.nextLevel,
                  icon: Icon(
                    controller.isLastLevel
                        ? Icons.home_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                  label: Text(
                    controller.isLastLevel ? 'Back Home' : 'Next Level',
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: controller.replayLevel,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Replay Level'),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
            child: Icon(
              index < stars ? Icons.star_rounded : Icons.star_border_rounded,
              size: 42,
              color: WeatherSortColors.sun,
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
