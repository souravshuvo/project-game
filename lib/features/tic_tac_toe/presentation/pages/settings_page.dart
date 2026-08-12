import 'package:flutter/material.dart';

import '../../application/tic_tac_toe_controller.dart';
import '../theme/pocket_observatory_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.controller});

  final TicTacToeController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: controller.closeSettings,
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
        title: const Text('Settings'),
      ),
      body: ObservatoryBackdrop(
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
                title: 'Vibration',
                value: controller.hapticsEnabled,
                onChanged: controller.toggleHaptics,
              ),
              const SizedBox(height: 12),
              ObservatoryPanel(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(
                    Icons.help_outline_rounded,
                    color: PocketObservatoryColors.gold,
                  ),
                  title: Text(
                    'How to Play',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: controller.showHelp,
                ),
              ),
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
    return ObservatoryPanel(
      padding: EdgeInsets.zero,
      child: SwitchListTile(
        secondary: Icon(icon, color: PocketObservatoryColors.gold),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
