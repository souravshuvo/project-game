import 'dart:async';

import 'package:flutter/material.dart';

import '../analytics/analytics_service.dart';
import '../app/feedback_controller.dart';
import '../app/game_settings.dart';
import '../game/game_feedback.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.analytics,
  });

  final GameSettings settings;
  final AnalyticsService analytics;

  void _tap() {
    FeedbackController(settings).play(GameFeedback.tap);
  }

  void _showGameplayHelp(BuildContext context) {
    _tap();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Gameplay Help'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Touch the glowing ball or the space just below it.'),
              SizedBox(height: 8),
              Text(
                'Pull down to shoot upward. Pull farther for a stronger shot.',
              ),
              SizedBox(height: 8),
              Text('Drag sideways to curve around keepers or boards.'),
              SizedBox(height: 8),
              Text(
                'Release to shoot, then retry or move to the next challenge.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _tap();
                Navigator.of(context).pop();
              },
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  void _confirmResetProgress(BuildContext context) {
    _tap();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Progress?'),
          content: const Text(
            'This clears unlocked challenges and best stars for this app session.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                _tap();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final completedCount = settings.progress.completedCount;
                final totalStars = settings.progress.totalStars;
                settings.resetProgress();
                _tap();
                unawaited(
                  analytics.logProgressReset(
                    completedCount: completedCount,
                    totalStars: totalStars,
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: settings,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  title: const Text('Sound feedback'),
                  subtitle: const Text('Uses lightweight system sounds only.'),
                  value: settings.soundEnabled,
                  onChanged: (value) {
                    settings.setSoundEnabled(value);
                    FeedbackController(settings).play(GameFeedback.tap);
                  },
                ),
                SwitchListTile(
                  title: const Text('Haptic feedback'),
                  subtitle: const Text(
                    'Vibrates for shots, goals, and misses.',
                  ),
                  value: settings.hapticsEnabled,
                  onChanged: (value) {
                    settings.setHapticsEnabled(value);
                    FeedbackController(settings).play(GameFeedback.tap);
                  },
                ),
                const Divider(height: 32),
                ListTile(
                  title: const Text('Gameplay help'),
                  subtitle: const Text(
                    'Touch the glowing ball, pull down for power, '
                    'slide sideways for curve.',
                  ),
                  trailing: const Icon(Icons.sports_soccer),
                  onTap: () => _showGameplayHelp(context),
                ),
                const Divider(height: 32),
                ListTile(
                  enabled: settings.progress.hasProgress,
                  title: const Text('Reset progress'),
                  subtitle: Text(
                    '${settings.progress.completedCount} challenges complete, '
                    '${settings.progress.totalStars} stars earned.',
                  ),
                  trailing: const Icon(Icons.restart_alt),
                  onTap: settings.progress.hasProgress
                      ? () => _confirmResetProgress(context)
                      : null,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
