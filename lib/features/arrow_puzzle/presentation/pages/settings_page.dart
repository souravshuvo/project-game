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
        title: const Text('Settings'),
      ),
      body: GameBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _SettingsSwitch(
                icon: Icons.volume_up_rounded,
                title: 'Sound',
                value: controller.soundEnabled,
                onChanged: controller.toggleSound,
              ),
              const SizedBox(height: 12),
              _SettingsSwitch(
                icon: Icons.vibration_rounded,
                title: 'Haptics',
                value: controller.hapticsEnabled,
                onChanged: controller.toggleHaptics,
              ),
              const SizedBox(height: 18),
              _HintBalanceCard(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ArrowPuzzleCard(
      padding: EdgeInsets.zero,
      shadow: true,
      child: Material(
        color: Colors.transparent,
        child: SwitchListTile(
          secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _HintBalanceCard extends StatelessWidget {
  const _HintBalanceCard({required this.controller});

  final PuzzleController controller;

  @override
  Widget build(BuildContext context) {
    return ArrowPuzzleCard(
      color: ArrowPuzzleColors.blueSoft,
      borderColor: const Color(0xFFB7D4FF),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${controller.hintCount} hints available',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
