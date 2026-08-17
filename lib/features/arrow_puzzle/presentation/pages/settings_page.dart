import 'package:flutter/material.dart';

import '../../application/puzzle_controller.dart';
import '../theme/arrow_puzzle_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.controller});

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
        title: const Text('Control Center'),
      ),
      body: GameBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
            children: [
              _SectionCard(
                title: 'Sound & Haptics',
                subtitle: 'Tune action feel and avoid fatigue.',
                children: [
                  _LabeledSwitchTile(
                    icon: Icons.volume_up_rounded,
                    title: 'Sound effects',
                    description: 'Tap, clear, reward, and completion cues.',
                    value: controller.soundEnabled,
                    onChanged: controller.toggleSound,
                  ),
                  const Divider(height: 1),
                  _LabeledSwitchTile(
                    icon: Icons.vibration_rounded,
                    title: 'Haptics',
                    description: 'Pulse feedback for taps, errors, and combos.',
                    value: controller.hapticsEnabled,
                    onChanged: controller.toggleHaptics,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Gameflow',
                subtitle: 'Your progress and quick actions.',
                children: [
                  _ReadoutRow(
                    icon: Icons.route_rounded,
                    title: 'Campaign Progress',
                    value:
                        '${controller.completedLevelCount}/${controller.totalLevels}',
                  ),
                  const Divider(height: 1),
                  _ReadoutRow(
                    icon: Icons.local_fire_department_rounded,
                    title: 'Current streak',
                    value: '${controller.streakDays} days',
                  ),
                  const Divider(height: 1),
                  _ReadoutRow(
                    icon: Icons.lightbulb_rounded,
                    title: 'Hint bank',
                    value: '${controller.hintCount}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Replay & Hints',
                subtitle: 'Replay quickly after every clear to keep momentum.',
                children: [
                  Text(
                    'Replay is rewarded through score chases and mission targets in the hub. Daily hints are available with a cooldown.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ArrowPuzzleColors.mutedInk,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: controller.play,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Quick play next run'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: controller.startDailyChallenge,
                    icon: const Icon(Icons.today_rounded),
                    label: const Text('Daily run'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ArrowPuzzleCard(
      shadow: true,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: ArrowPuzzleColors.mutedInk),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _LabeledSwitchTile extends StatelessWidget {
  const _LabeledSwitchTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: ArrowPuzzleColors.mutedInk,
            height: 1.2,
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _ReadoutRow extends StatelessWidget {
  const _ReadoutRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: ArrowPuzzleColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
