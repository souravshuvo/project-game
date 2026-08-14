import 'package:flutter/material.dart';

import '../../application/signal_reef_ads.dart';
import '../../application/signal_reef_controller.dart';
import '../theme/signal_reef_theme.dart';
import '../widgets/signal_reef_banner_ad.dart';

class SignalReefHomePage extends StatelessWidget {
  const SignalReefHomePage({super.key, required this.controller});

  final SignalReefController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignalReefBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton.filledTonal(
                          onPressed: controller.showSettings,
                          icon: const Icon(Icons.settings_rounded),
                          tooltip: 'Settings',
                        ),
                      ),
                      const SizedBox(height: 36),
                      const Center(child: SignalReefMark(size: 84)),
                      const SizedBox(height: 24),
                      Text(
                        'Signal Reef',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Pilot a scout ship through a fractured star lane. Drag to dodge, auto-fire laser bolts, and clear enemy waves.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: SignalReefColors.mutedInk,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 24),
                      _RunFacts(totalWaves: controller.totalWaves),
                      const SizedBox(height: 28),
                      FilledButton.icon(
                        onPressed: controller.play,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: controller.showSettings,
                        icon: const Icon(Icons.help_outline_rounded),
                        label: const Text('How to play'),
                      ),
                      const SizedBox(height: 24),
                      SignalReefPanel(
                        child: Column(
                          children: [
                            _ProgressRow(
                              icon: Icons.military_tech_rounded,
                              label: 'Best score',
                              value: '${controller.bestScore}',
                            ),
                            const Divider(),
                            _ProgressRow(
                              icon: Icons.flag_rounded,
                              label: 'Best wave',
                              value:
                                  '${controller.bestWaveReached}/${controller.totalWaves}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SignalReefBannerAd(
                        ads: controller.ads,
                        placement: SignalReefAdPlacement.homeBanner,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: SignalReefColors.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(
            value,
            key: ValueKey('$label-$value'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _RunFacts extends StatelessWidget {
  const _RunFacts({required this.totalWaves});

  final int totalWaves;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _FactChip(icon: Icons.radar_rounded, label: '$totalWaves waves'),
        const _FactChip(icon: Icons.touch_app_rounded, label: 'Drag steer'),
        const _FactChip(icon: Icons.bolt_rounded, label: 'Auto-fire'),
      ],
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SignalReefColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SignalReefColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: SignalReefColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
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
