import 'package:flutter/material.dart';

import '../../application/signal_reef_controller.dart';
import '../theme/signal_reef_theme.dart';

class SignalReefResultPage extends StatelessWidget {
  const SignalReefResultPage({super.key, required this.controller});

  final SignalReefController controller;

  @override
  Widget build(BuildContext context) {
    final result = controller.lastResult;

    return Scaffold(
      body: SignalReefBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Icon(
                  result?.won == true
                      ? Icons.auto_awesome_rounded
                      : Icons.bolt_rounded,
                  size: 64,
                  color: result?.won == true
                      ? SignalReefColors.accent
                      : SignalReefColors.danger,
                ),
                const SizedBox(height: 18),
                Text(
                  result?.won == true ? 'Signal Restored' : 'Signal Lost',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 24),
                SignalReefPanel(
                  child: Column(
                    children: [
                      _ResultRow(
                        label: 'Score',
                        value: '${result?.score ?? 0}',
                      ),
                      const Divider(),
                      _ResultRow(
                        label: 'Waves cleared',
                        value: '${result?.wavesCleared ?? 0}/3',
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
                  label: const Text('Retry'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: controller.backHome,
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Menu'),
                ),
                const Spacer(),
              ],
            ),
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
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
