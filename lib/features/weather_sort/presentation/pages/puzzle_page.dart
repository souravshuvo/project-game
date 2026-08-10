import 'package:flutter/material.dart';

import '../../application/water_sort_controller.dart';
import '../theme/weather_sort_theme.dart';
import '../widgets/essence_legend.dart';
import '../widgets/tube_widget.dart';
import '../widgets/weather_essence_view.dart';

class WaterPuzzlePage extends StatelessWidget {
  const WaterPuzzlePage({super.key, required this.controller});

  final WaterSortController controller;

  @override
  Widget build(BuildContext context) {
    final level = controller.currentLevel;
    final bestMoves = controller.currentLevelBestMoves;
    final invalidMessage = invalidMoveMessage(controller.lastInvalidReason);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: controller.backHome,
          icon: const Icon(Icons.home_rounded),
          tooltip: 'Home',
        ),
        title: Text('Level ${controller.currentLevelNumber}'),
      ),
      body: WeatherBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WeatherPanel(
                  color: WeatherSortColors.wash,
                  borderColor: const Color(0xFFC9DAE8),
                  child: Column(
                    children: [
                      Text(
                        level.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: WeatherSortColors.primaryDark,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        level.lesson,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: WeatherSortColors.mutedInk,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StatusChip(
                      icon: Icons.touch_app_rounded,
                      label: 'Moves',
                      value: '${controller.moveCount}',
                    ),
                    _StatusChip(
                      icon: Icons.flag_rounded,
                      label: 'Par',
                      value: '${level.parMoves}',
                    ),
                    _StatusChip(
                      icon: Icons.military_tech_rounded,
                      label: 'Best',
                      value: bestMoves == null ? '-' : '$bestMoves',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: SizedBox(
                    key: ValueKey(invalidMessage),
                    height: 28,
                    child: Center(
                      child: Text(
                        invalidMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: WeatherSortColors.coral,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(child: _TubeGrid(controller: controller)),
                const SizedBox(height: 10),
                const EssenceLegend(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.canUndo ? controller.undo : null,
                        icon: const Icon(Icons.undo_rounded),
                        label: const Text('Undo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: controller.restartLevel,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Restart'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TubeGrid extends StatelessWidget {
  const _TubeGrid({required this.controller});

  final WaterSortController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 430 ? 3 : 5;

        return GridView.builder(
          padding: const EdgeInsets.symmetric(vertical: 6),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.48,
          ),
          itemCount: controller.board.tubeCount,
          itemBuilder: (context, index) {
            return TubeWidget(
              tube: controller.board.tubeAt(index),
              index: index,
              isSelected: controller.selectedTubeIndex == index,
              isInvalid: controller.invalidTubeIndex == index,
              feedbackToken: controller.feedbackToken,
              onTap: () => controller.tapTube(index),
            );
          },
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 7),
            Text(
              '$label: $value',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
