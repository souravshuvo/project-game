import 'package:flutter/material.dart';

class MenuOverlay extends StatelessWidget {
  const MenuOverlay({
    super.key,
    required this.bestScore,
    required this.gamesPlayed,
    required this.onPlay,
  });

  final int bestScore;
  final int gamesPlayed;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF101510)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _BrandMark(),
                const SizedBox(height: 24),
                const Text(
                  'Trail Arena',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Offline arena survival with glowing trails and simple bots.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFB8C9BD),
                    fontSize: 15,
                    height: 1.35,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MenuMetric(label: 'Best', value: bestScore.toString()),
                    const SizedBox(width: 12),
                    _MenuMetric(label: 'Runs', value: gamesPlayed.toString()),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Play'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: const Color(0xFF193528),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF46735A), width: 3),
      ),
      child: const Center(
        child: Icon(
          Icons.radio_button_checked_rounded,
          color: Color(0xFF65F0B4),
          size: 52,
        ),
      ),
    );
  }
}

class _MenuMetric extends StatelessWidget {
  const _MenuMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF9AB5A5), letterSpacing: 0),
        ),
        Text(
          value,
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
