import 'package:flutter/material.dart';

import '../../infrastructure/analytics/game_analytics.dart';
import '../services/game_feedback.dart';
import '../settings/game_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = GameSettingsScope.watch(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Feedback',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Use quick built-in cues for taps, moves, captures, invalid '
              'actions, and match results.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: settings.soundEnabled,
              secondary: const Icon(Icons.volume_up_rounded),
              title: const Text('Sound effects'),
              subtitle: const Text('System click and alert sounds'),
              onChanged: (value) {
                GameFeedback.play(context, GameFeedbackCue.tap);
                settings.setSoundEnabled(value);
                GameAnalyticsScope.read(
                  context,
                ).logSettingsChanged('sound', value);
              },
            ),
            SwitchListTile(
              value: settings.hapticsEnabled,
              secondary: const Icon(Icons.vibration_rounded),
              title: const Text('Haptics'),
              subtitle: const Text('Light vibration for important actions'),
              onChanged: (value) {
                GameFeedback.play(context, GameFeedbackCue.tap);
                settings.setHapticsEnabled(value);
                GameAnalyticsScope.read(
                  context,
                ).logSettingsChanged('haptics', value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
