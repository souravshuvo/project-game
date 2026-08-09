import 'package:flutter/material.dart';

import '../../application/puzzle_controller.dart';
import '../theme/arrow_puzzle_theme.dart';

class LevelSelectPage extends StatelessWidget {
  const LevelSelectPage({super.key, required this.controller});

  final PuzzleController controller;

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
      body: GameBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
                child: _LevelProgressHeader(controller: controller),
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

class _LevelProgressHeader extends StatelessWidget {
  const _LevelProgressHeader({required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    final progress = controller.completedLevelCount / controller.totalLevels;

    return ArrowPuzzleCard(
      shadow: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route_rounded, color: ArrowPuzzleColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${controller.completedLevelCount}/${controller.totalLevels} cleared',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${controller.unlockedLevelCount} unlocked',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: ArrowPuzzleColors.mutedInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: ArrowPuzzleColors.line,
              color: ArrowPuzzleColors.mint,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({required this.controller, required this.index});

  final PuzzleController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    final level = controller.levels[index];
    final colorScheme = Theme.of(context).colorScheme;
    final isUnlocked = controller.isLevelUnlocked(index);
    final isComplete = controller.isLevelComplete(level.id);
    final bestMoves = controller.bestMovesForLevel(level.id);
    final foreground = isUnlocked
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.38);
    final borderColor = isComplete
        ? ArrowPuzzleColors.mint
        : isUnlocked
        ? colorScheme.primary.withValues(alpha: 0.42)
        : colorScheme.outlineVariant;

    return Material(
      color: isComplete
          ? ArrowPuzzleColors.mintSoft
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
                          ? const Color(0xFF22A66A)
                          : isUnlocked
                          ? colorScheme.primary
                          : foreground,
                    ),
                    const Spacer(),
                    Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  level.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  isUnlocked
                      ? bestMoves == null
                            ? '${level.rows.length}x${level.rows.first.length}'
                            : 'Best $bestMoves'
                      : 'Locked',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
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
