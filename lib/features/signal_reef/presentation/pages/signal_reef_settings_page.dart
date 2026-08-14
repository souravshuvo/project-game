import 'package:flutter/material.dart';

import '../../application/signal_reef_controller.dart';
import '../theme/signal_reef_theme.dart';

class SignalReefSettingsPage extends StatelessWidget {
  const SignalReefSettingsPage({super.key, required this.controller});

  final SignalReefController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: controller.backHome,
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
        title: const Text('Settings'),
      ),
      body: SignalReefBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              SignalReefPanel(
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      value: controller.soundEnabled,
                      onChanged: controller.toggleSound,
                      secondary: const Icon(Icons.volume_up_rounded),
                      title: const Text('Sound'),
                      subtitle: const Text('System taps and alerts'),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: controller.hapticsEnabled,
                      onChanged: controller.toggleHaptics,
                      secondary: const Icon(Icons.vibration_rounded),
                      title: const Text('Haptics'),
                      subtitle: const Text(
                        'Touch, hit, damage, and result feel',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SignalReefPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to play',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _HelpRow(
                      icon: Icons.touch_app_rounded,
                      text:
                          'Drag anywhere on the arena to move without covering the ship.',
                    ),
                    const _HelpRow(
                      icon: Icons.bolt_rounded,
                      text:
                          'Laser bolts fire automatically from the ship nose.',
                    ),
                    const _HelpRow(
                      icon: Icons.favorite_rounded,
                      text:
                          'Avoid enemy craft and red plasma fire. Lose all hull and the run ends.',
                    ),
                    const _HelpRow(
                      icon: Icons.star_rounded,
                      text:
                          'Clear each enemy wave to boost your score and push deeper into the star lane.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  const _HelpRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: SignalReefColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SignalReefColors.mutedInk,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
