import 'dart:async';

import 'package:flutter/material.dart';

import '../ads/ad_banner_slot.dart';
import '../ads/ad_service.dart';
import '../analytics/analytics_service.dart';
import '../app/feedback_controller.dart';
import '../app/game_settings.dart';
import '../game/challenges/challenge.dart';
import '../game/game_feedback.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({
    super.key,
    required this.settings,
    required this.analytics,
    required this.ads,
  });

  final GameSettings settings;
  final AnalyticsService analytics;
  final AdService ads;

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  void _tap() {
    FeedbackController(widget.settings).play(GameFeedback.tap);
  }

  @override
  void initState() {
    super.initState();
    unawaited(widget.analytics.logScreen('main_menu'));
  }

  @override
  Widget build(BuildContext context) {
    final challengeCount = productionV1Challenges().length;

    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.settings,
          builder: (context, _) {
            final progress = widget.settings.progress;
            final startIndex = progress.highestUnlockedChallengeIndex;
            final isComplete = progress.completedCount >= challengeCount;
            final playLabel = isComplete
                ? 'Replay Final Challenge'
                : progress.hasProgress
                ? 'Continue Challenge ${startIndex + 1}'
                : 'Play';

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Text(
                    'Rooftop Curve',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aim, curve, and score in one-shot rooftop football puzzles.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${progress.completedCount}/$challengeCount challenges  '
                    '${progress.totalStars}/${challengeCount * 3} stars',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: () {
                      _tap();
                      unawaited(widget.analytics.logMenuAction('play'));
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => GameScreen(
                            settings: widget.settings,
                            analytics: widget.analytics,
                            ads: widget.ads,
                            initialChallengeIndex: startIndex,
                          ),
                        ),
                      );
                    },
                    child: Text(playLabel),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      _tap();
                      unawaited(widget.analytics.logMenuAction('how_to_play'));
                      _showHowToPlay(context);
                    },
                    child: const Text('How to Play'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      _tap();
                      unawaited(widget.analytics.logMenuAction('settings'));
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => SettingsScreen(
                            settings: widget.settings,
                            analytics: widget.analytics,
                          ),
                        ),
                      );
                    },
                    child: const Text('Settings'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      _tap();
                      unawaited(widget.analytics.logMenuAction('credits'));
                      showAboutDialog(
                        context: context,
                        applicationName: 'Rooftop Curve',
                        applicationVersion: 'v1 content',
                        children: const [
                          Text(
                            'Original minimal visuals. No official teams, '
                            'players, kits, clubs, leagues, or tournaments.',
                          ),
                        ],
                      );
                    },
                    child: const Text('Credits'),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: AdBannerSlot(
                      ads: widget.ads,
                      placement: 'main_menu_bottom',
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Original game. No official teams, leagues, or players.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showHowToPlay(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('How to Play'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. Touch the glowing ball or just below it.'),
              SizedBox(height: 8),
              Text('2. Pull down to shoot upward and set power.'),
              SizedBox(height: 8),
              Text('3. Slide sideways to curve the shot.'),
              SizedBox(height: 8),
              Text('4. Release to score past keepers and boards.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _tap();
                unawaited(widget.analytics.logMenuAction('how_to_play_close'));
                Navigator.of(context).pop();
              },
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}
