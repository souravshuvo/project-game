import 'package:flutter/material.dart';

import '../../application/signal_reef_ads.dart';
import '../../application/signal_reef_controller.dart';
import '../theme/signal_reef_theme.dart';
import '../widgets/signal_reef_banner_ad.dart';

class SignalReefResultPage extends StatefulWidget {
  const SignalReefResultPage({super.key, required this.controller});

  final SignalReefController controller;

  @override
  State<SignalReefResultPage> createState() => _SignalReefResultPageState();
}

class _SignalReefResultPageState extends State<SignalReefResultPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller.maybeShowResultInterstitial();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final result = controller.lastResult;

    return Scaffold(
      body: SignalReefBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 36),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.86, end: 1),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Icon(
                  result?.won == true
                      ? Icons.auto_awesome_rounded
                      : Icons.bolt_rounded,
                  size: 64,
                  color: result?.won == true
                      ? SignalReefColors.accent
                      : SignalReefColors.danger,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                result?.won == true ? 'Signal Restored' : 'Signal Lost',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result?.won == true
                    ? 'Clean run. The star lane is broadcasting again.'
                    : 'Good run. Relaunch while the enemy pattern is fresh.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: SignalReefColors.mutedInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              SignalReefPanel(
                child: Column(
                  children: [
                    _ResultRow(label: 'Score', value: '${result?.score ?? 0}'),
                    const Divider(),
                    _ResultRow(
                      label: 'Waves cleared',
                      value:
                          '${result?.wavesCleared ?? 0}/${controller.totalWaves}',
                    ),
                    const Divider(),
                    _ResultRow(
                      label: 'Wave reached',
                      value: '${result?.waveReached ?? 1}',
                    ),
                    const Divider(),
                    _ResultRow(
                      label: 'Best score',
                      value: '${controller.bestScore}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: controller.retry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Play again'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: controller.backHome,
                icon: const Icon(Icons.home_rounded),
                label: const Text('Home'),
              ),
              const SizedBox(height: 18),
              SignalReefBannerAd(
                ads: controller.ads,
                placement: SignalReefAdPlacement.resultBanner,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: Text(
              value,
              key: ValueKey('$label-$value'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
