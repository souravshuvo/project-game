import 'package:flutter/material.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({
    super.key,
    required this.score,
    required this.bestScore,
    required this.onPause,
  });

  final int score;
  final int bestScore;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _HudMetric(label: 'Score', value: score.toString()),
          const SizedBox(width: 10),
          _HudMetric(label: 'Best', value: bestScore.toString()),
          const Spacer(),
          IconButton.filledTonal(
            tooltip: 'Pause',
            onPressed: onPause,
            icon: const Icon(Icons.pause_rounded),
          ),
        ],
      ),
    );
  }
}

class _HudMetric extends StatelessWidget {
  const _HudMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 86),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF193528),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF315940)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9AB5A5),
              fontSize: 11,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
