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
        children: [
          _HudPill(
            icon: Icons.waves_rounded,
            label: 'Wave',
            value: '${game.currentWaveNumber}/3',
          ),
          const SizedBox(width: 8),
          _HudPill(
            icon: Icons.star_rounded,
            label: 'Score',
            value: '${game.score}',
          ),
          const Spacer(),
          _HullPill(hull: game.hull),
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
            return Icon(
              index < hull
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: 18,
              color: index < hull
                  ? SignalReefColors.danger
                  : SignalReefColors.mutedInk,
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
            Text(
              '$label $value',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
