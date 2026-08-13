import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../../infrastructure/analytics/game_analytics.dart';
import 'history_screen.dart';
import 'match_screen.dart';
import 'rules_screen.dart';
import 'settings_screen.dart';
import '../progress/match_history.dart';
import '../services/game_feedback.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = MatchHistoryScope.watch(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sixteen Breed'),
        actions: [
          IconButton(
            tooltip: 'Match history',
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              GameFeedback.play(context, GameFeedbackCue.tap);
              GameAnalyticsScope.read(context).logMenuAction('history');
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  settings: const RouteSettings(name: 'history'),
                  builder: (_) => const HistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              GameFeedback.play(context, GameFeedbackCue.tap);
              GameAnalyticsScope.read(context).logMenuAction('settings');
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  settings: const RouteSettings(name: 'settings'),
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                  maxWidth: 460,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Sixteen Breed',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sholo Guti / 16 Beads',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 22),
                      _HowToStartBox(
                        text:
                            'Tap or drag one of your beads, then choose a '
                            'highlighted point. Amber jumps capture.',
                      ),
                      const SizedBox(height: 28),
                      FilledButton.icon(
                        onPressed: () {
                          GameFeedback.play(context, GameFeedbackCue.tap);
                          GameAnalyticsScope.read(
                            context,
                          ).logMenuAction('start_local');
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              settings: const RouteSettings(
                                name: 'match_local',
                              ),
                              builder: (_) => const MatchScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Local 2 Player'),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          GameFeedback.play(context, GameFeedbackCue.tap);
                          GameAnalyticsScope.read(
                            context,
                          ).logMenuAction('open_bot_picker');
                          _showBotDifficultyPicker(context);
                        },
                        icon: const Icon(Icons.smart_toy_rounded),
                        label: const Text('Player vs Bot'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          GameFeedback.play(context, GameFeedbackCue.tap);
                          GameAnalyticsScope.read(
                            context,
                          ).logMenuAction('rules');
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              settings: const RouteSettings(name: 'rules'),
                              builder: (_) => const RulesScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.menu_book_rounded),
                        label: const Text('Rules'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          GameFeedback.play(context, GameFeedbackCue.tap);
                          GameAnalyticsScope.read(
                            context,
                          ).logMenuAction('history');
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              settings: const RouteSettings(name: 'history'),
                              builder: (_) => const HistoryScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.history_rounded),
                        label: Text('History (${history.entries.length})'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showBotDifficultyPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            children: [
              Text(
                'Choose Bot Difficulty',
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              for (final difficulty in BotDifficulty.values) ...[
                ListTile(
                  leading: Icon(_difficultyIcon(difficulty)),
                  title: Text(difficulty.label),
                  subtitle: Text(difficulty.description),
                  onTap: () {
                    GameFeedback.play(sheetContext, GameFeedbackCue.tap);
                    GameAnalyticsScope.read(
                      context,
                    ).logMenuAction('start_bot_${difficulty.name}');
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        settings: RouteSettings(
                          name: 'match_bot_${difficulty.name}',
                        ),
                        builder: (_) => MatchScreen(
                          setup: MatchSetup.playerVsBot(difficulty),
                        ),
                      ),
                    );
                  },
                ),
                if (difficulty != BotDifficulty.values.last)
                  const Divider(height: 1),
              ],
            ],
          ),
        );
      },
    );
  }

  IconData _difficultyIcon(BotDifficulty difficulty) {
    return switch (difficulty) {
      BotDifficulty.easy => Icons.sentiment_satisfied_rounded,
      BotDifficulty.balanced => Icons.psychology_alt_rounded,
      BotDifficulty.sharp => Icons.local_fire_department_rounded,
    };
  }
}

class _HowToStartBox extends StatelessWidget {
  const _HowToStartBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.touch_app_rounded, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}
