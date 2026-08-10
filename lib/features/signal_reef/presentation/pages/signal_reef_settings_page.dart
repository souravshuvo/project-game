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
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: SignalReefPanel(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    value: controller.soundEnabled,
                    onChanged: controller.toggleSound,
                    secondary: const Icon(Icons.volume_up_rounded),
                    title: const Text('Sound'),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: controller.musicEnabled,
                    onChanged: controller.toggleMusic,
                    secondary: const Icon(Icons.music_note_rounded),
                    title: const Text('Music'),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: controller.hapticsEnabled,
                    onChanged: controller.toggleHaptics,
                    secondary: const Icon(Icons.vibration_rounded),
                    title: const Text('Haptics'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
