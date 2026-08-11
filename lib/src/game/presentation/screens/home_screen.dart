import 'package:flutter/material.dart';

import '../../domain/models.dart';
import 'history_screen.dart';
import 'match_screen.dart';
import 'rules_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.settings,
    required this.history,
    required this.onSettingsChanged,
    required this.onMatchFinished,
  });

  final GameSettings settings;
  final List<MatchRecord> history;
  final ValueChanged<GameSettings> onSettingsChanged;
  final ValueChanged<MatchRecord> onMatchFinished;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Rapid Jump',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F3D2D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Offline Sholo Guti',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 40),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MatchScreen(
                        mode: MatchMode.localTwoPlayer,
                        settings: settings,
                        onMatchFinished: onMatchFinished,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Play Local'),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MatchScreen(
                        mode: MatchMode.vsBot,
                        settings: settings,
                        onMatchFinished: onMatchFinished,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.smart_toy_rounded),
                label: const Text('Play Bot'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SettingsScreen(
                        settings: settings,
                        onChanged: onSettingsChanged,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.tune_rounded),
                label: const Text('Settings'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => HistoryScreen(history: history),
                    ),
                  );
                },
                icon: const Icon(Icons.history_rounded),
                label: const Text('History'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RulesScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('Rules'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Version 1: offline play only. No ads, accounts, shop, or online play.',
                textAlign: TextAlign.center,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
