import 'package:flutter/material.dart';

import 'game_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

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
                'Rooftop Curve',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(
                'Aim, curve, and score in one-shot rooftop football puzzles.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 36),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const GameScreen()),
                  );
                },
                child: const Text('Play'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Rooftop Curve',
                    applicationVersion: 'v1 starter',
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
              const Spacer(),
              Text(
                'Original game. No official teams, leagues, or players.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
