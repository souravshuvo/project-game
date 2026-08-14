import 'package:flutter/material.dart';

import '../../application/signal_reef_controller.dart';
import '../../game/signal_reef_game.dart';
import '../theme/signal_reef_theme.dart';

class SignalReefHud extends StatelessWidget {
  const SignalReefHud({
    super.key,
    required this.controller,
    required this.game,
  });

  final SignalReefController controller;
  final SignalReefGame game;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HudPill(
                  icon: Icons.radar_rounded,
                  label: 'Wave',
                  value: '${game.currentWaveNumber}/${game.totalWaves}',
                ),
                _HudPill(
                  icon: Icons.star_rounded,
                  label: 'Score',
                  value: '${game.score}',
                ),
                _HullPill(hull: game.hull),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton.filledTonal(
            onPressed: controller.pause,
            icon: const Icon(Icons.pause_rounded),
            tooltip: 'Pause',
          ),
        ],
      ),
    );
  }
}

class _HullPill extends StatelessWidget {
  const _HullPill({required this.hull});

  final int hull;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SignalReefColors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SignalReefColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(SignalReefGame.startingHull, (index) {
            final isFilled = index < hull;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 140),
              child: Icon(
                isFilled
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey('$index-$isFilled'),
                size: 18,
                color: isFilled
                    ? SignalReefColors.danger
                    : SignalReefColors.mutedInk,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _HudPill extends StatelessWidget {
  const _HudPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SignalReefColors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SignalReefColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: SignalReefColors.primary),
            const SizedBox(width: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 140),
              child: Text(
                '$label $value',
                key: ValueKey('$label-$value'),
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
