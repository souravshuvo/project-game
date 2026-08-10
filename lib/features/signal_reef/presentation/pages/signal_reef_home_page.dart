import 'package:flutter/material.dart';

import '../../application/signal_reef_controller.dart';
import '../theme/signal_reef_theme.dart';

class SignalReefHomePage extends StatelessWidget {
  const SignalReefHomePage({super.key, required this.controller});

  final SignalReefController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignalReefBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: controller.showSettings,
                    icon: const Icon(Icons.settings_rounded),
                    tooltip: 'Settings',
                  ),
                ),
                const Spacer(),
                const Center(child: SignalReefMark()),
                const SizedBox(height: 24),
                Text(
                  'Signal Reef',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Prototype build with original placeholder vector visuals.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: SignalReefColors.mutedInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 34),
                FilledButton.icon(
                  onPressed: controller.play,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Play Prototype'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: controller.showSettings,
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('Settings'),
                ),
                const Spacer(),
                SignalReefPanel(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.military_tech_rounded,
                        color: SignalReefColors.accent,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Best score',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        '${controller.bestScore}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
