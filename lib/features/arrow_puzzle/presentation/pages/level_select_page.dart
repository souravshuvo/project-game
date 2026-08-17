import 'package:flutter/material.dart';

import '../../application/puzzle_controller.dart';
import '../../data/campaign_playbook.dart';
import '../theme/arrow_puzzle_theme.dart';

class LevelSelectPage extends StatelessWidget {
  const LevelSelectPage({super.key, required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 720;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: controller.backHome,
          icon: const Icon(Icons.home_rounded),
          tooltip: 'Home',
        ),
        title: const Text('Campaign Hub'),
      ),
      body: GameBackdrop(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(compact ? 14 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CampaignHeader(controller: controller),
                const SizedBox(height: 12),
                _CampaignQuickActions(controller: controller),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: controller.campaignWaves.length,
                    itemBuilder: (context, index) {
                      final wave = controller.campaignWaves[index];
                      return _CampaignWaveSection(
                        controller: controller,
                        wave: wave,
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    physics: const BouncingScrollPhysics(),
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

class _CampaignHeader extends StatelessWidget {
  const _CampaignHeader({required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    final completionRatio = controller.totalLevels == 0
        ? 0.0
        : controller.completedLevelCount / controller.totalLevels;
    final unlocked = '${controller.unlockedLevelCount}/${controller.totalLevels}';

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
                  'Campaign Runbook',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Unlocked: $unlocked · Continuing: Level ${controller.resumeLevelNumber}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ArrowPuzzleColors.mutedInk,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completionRatio,
              minHeight: 8,
              backgroundColor: ArrowPuzzleColors.line,
              color: ArrowPuzzleColors.mint,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${controller.completedLevelCount} missions cleared',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: ArrowPuzzleColors.mutedInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _CampaignQuickActions extends StatelessWidget {
  const _CampaignQuickActions({required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        SizedBox(
          width: 170,
          child: FilledButton.icon(
            onPressed: controller.play,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Continue', maxLines: 1),
          ),
        ),
        SizedBox(
          width: 170,
          child: OutlinedButton.icon(
            onPressed: controller.retryLevel,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Replay Current', maxLines: 1),
          ),
        ),
        SizedBox(
          width: 170,
          child: OutlinedButton.icon(
            onPressed: controller.startNextCampaignWaveOrCurrent,
            icon: const Icon(Icons.alt_route_rounded),
            label: const Text('Wave Flow', maxLines: 1),
          ),
        ),
        SizedBox(
          width: 170,
          child: OutlinedButton.icon(
            onPressed: controller.startDailyChallenge,
            icon: const Icon(Icons.today_rounded),
            label: const Text('Daily Run', maxLines: 1),
          ),
        ),
      ],
    );
  }
}

class _CampaignWaveSection extends StatelessWidget {
  const _CampaignWaveSection({
    required this.controller,
    required this.wave,
  });

  final PuzzleController controller;
  final CampaignWave wave;

  @override
  Widget build(BuildContext context) {
    final completed = controller.completedLevelsInWaveCount(wave);
    final totalInWave = wave.levelCount;
    final ratio = totalInWave == 0 ? 0.0 : completed / totalInWave;
    final missionLabel = 'Wave ${wave.index}: ${wave.title}';

    return ArrowPuzzleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_outlined,
                color: ArrowPuzzleColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  missionLabel,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${wave.startLevel}-${wave.endLevel}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: ArrowPuzzleColors.mutedInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            wave.objective,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ArrowPuzzleColors.mutedInk,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: ArrowPuzzleColors.line,
              color: ArrowPuzzleColors.mint,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Wave progress: $completed/$totalInWave',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: ArrowPuzzleColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reward: ${wave.reward}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => controller.startCampaignWave(wave.index),
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: const Text('Replay Wave'),
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(
            totalInWave,
            (offset) => Padding(
              padding: EdgeInsets.only(bottom: offset == totalInWave - 1 ? 0 : 10),
              child: _MissionTile(
                controller: controller,
                index: wave.startLevel - 1 + offset,
                waveIndex: wave.index,
                missionIndexInWave: offset + 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionTile extends StatelessWidget {
  const _MissionTile({
    required this.controller,
    required this.index,
    required this.waveIndex,
    required this.missionIndexInWave,
  });

  final PuzzleController controller;
  final int index;
  final int waveIndex;
  final int missionIndexInWave;

  @override
  Widget build(BuildContext context) {
    final level = controller.levels[index];
    final colorScheme = Theme.of(context).colorScheme;
    final isUnlocked = controller.isLevelUnlocked(index);
    final isComplete = controller.isLevelComplete(level.id);
    final bestMoves = controller.bestMovesForLevel(level.id);
    final bestScore = controller.bestRunScoreForLevel(level.id);
    final isNext = index == controller.currentLevelNumber - 1;
    final borderColor = isComplete
        ? ArrowPuzzleColors.mint
        : isUnlocked
        ? colorScheme.primary.withValues(alpha: 0.45)
        : colorScheme.outlineVariant;
    final foreground = isUnlocked
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.38);
    final cardColor = isComplete
        ? ArrowPuzzleColors.mintSoft
        : isUnlocked
        ? Colors.white
        : const Color(0xFFECEFF6);
    final actionLabel = isComplete
        ? 'Replay'
        : isUnlocked
        ? 'Play'
        : 'Locked';

    return Material(
      borderRadius: BorderRadius.circular(10),
      color: cardColor,
      child: InkWell(
        onTap: isUnlocked ? () => controller.selectLevel(index) : null,
        borderRadius: BorderRadius.circular(10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.3),
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
                              : Icons.rocket_launch_rounded
                          : Icons.lock_rounded,
                      color: isComplete
                          ? const Color(0xFF22A66A)
                          : isUnlocked
                          ? colorScheme.primary
                          : foreground,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Wave $waveIndex · Mission $missionIndexInWave${isNext ? ' · Next' : ''}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      actionLabel,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isUnlocked ? colorScheme.primary : foreground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  level.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  runSpacing: 8,
                  spacing: 8,
                  children: [
                    _MissionStatChip(
                      icon: Icons.fitness_center_rounded,
                      label: 'Arrows',
                      value: '${level.rows.length}x${level.rows.first.length}',
                    ),
                    _MissionStatChip(
                      icon: Icons.military_tech_rounded,
                      label: 'Best',
                      value: bestMoves == null ? '—' : '$bestMoves',
                    ),
                    if (bestScore != null)
                      _MissionStatChip(
                        icon: Icons.show_chart_rounded,
                        label: 'Score',
                        value: '$bestScore',
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

class _MissionStatChip extends StatelessWidget {
  const _MissionStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ArrowPuzzleColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              '$label: $value',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
