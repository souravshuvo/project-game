import 'package:flutter/material.dart';

import '../../domain/run_state.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.score,
    required this.bestScore,
    required this.deathCause,
    required this.onRestart,
    required this.onMenu,
  });

  final int score;
  final int bestScore;
  final DeathCause? deathCause;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final causeText = switch (deathCause) {
      DeathCause.boundary => 'Boundary hit',
      DeathCause.selfTrail => 'Trail collision',
      DeathCause.botTrail => 'Rival trail hit',
      DeathCause.botHead => 'Rival head hit',
      null => 'Run ended',
    };

    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xB3000000)),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF142018),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF65F0B4)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Game Over',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      causeText,
                      style: const TextStyle(
                        color: Color(0xFFFF8A76),
                        fontSize: 15,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ResultMetric(label: 'Score', value: score),
                        const SizedBox(width: 18),
                        _ResultMetric(label: 'Best', value: bestScore),
                      ],
                    ),
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: onRestart,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                    TextButton.icon(
                      onPressed: onMenu,
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Menu'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultMetric extends StatelessWidget {
  const _ResultMetric({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9AB5A5),
            fontSize: 12,
            letterSpacing: 0,
          ),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
