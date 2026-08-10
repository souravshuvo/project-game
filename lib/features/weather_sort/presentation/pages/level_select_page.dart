import 'package:flutter/material.dart';

import '../../application/water_sort_controller.dart';
import '../theme/weather_sort_theme.dart';

class WaterLevelSelectPage extends StatelessWidget {
  const WaterLevelSelectPage({super.key, required this.controller});

  final WaterSortController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: controller.backHome,
          icon: const Icon(Icons.home_rounded),
          tooltip: 'Home',
        ),
        title: const Text('Levels'),
      ),
      body: WeatherBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
                child: WeatherPanel(
                  shadow: true,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.water_drop_rounded,
                        color: WeatherSortColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${controller.completedLevelCount}/${controller.totalLevels} levels complete',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(18),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.86,
                  ),
                  itemCount: controller.totalLevels,
                  itemBuilder: (context, index) {
                    return _LevelTile(controller: controller, index: index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({required this.controller, required this.index});

  final WaterSortController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    final level = controller.allLevels[index];
    final isUnlocked = controller.isLevelUnlocked(index);
    final isComplete = controller.isLevelComplete(level.id);
    final bestMoves = controller.bestMovesForLevel(level.id);
    final bestStars = controller.bestStarsForLevel(level.id);
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = isUnlocked
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.42);
    final borderColor = isComplete
        ? WeatherSortColors.mint
        : isUnlocked
        ? WeatherSortColors.primary.withValues(alpha: 0.42)
        : WeatherSortColors.line;

    return Material(
      color: isComplete
          ? const Color(0xFFEAF8EF)
          : isUnlocked
          ? Colors.white
          : const Color(0xFFECEFF6),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isUnlocked ? () => controller.selectLevel(index) : null,
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isUnlocked
                          ? isComplete
                                ? Icons.check_circle_rounded
                                : Icons.play_circle_rounded
                          : Icons.lock_rounded,
                      color: isComplete
                          ? WeatherSortColors.mint
                          : isUnlocked
                          ? WeatherSortColors.primary
                          : foreground,
                    ),
                    const Spacer(),
                    Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  level.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  isUnlocked
                      ? bestMoves == null
                            ? '${level.tubeSymbols.length} vessels'
                            : '$bestMoves moves - ${bestStars ?? 1} stars'
                      : 'Locked',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
