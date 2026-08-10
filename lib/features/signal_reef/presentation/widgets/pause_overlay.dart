import 'package:flutter/material.dart';

import '../../application/signal_reef_controller.dart';
import '../theme/signal_reef_theme.dart';

class SignalReefPauseOverlay extends StatelessWidget {
  const SignalReefPauseOverlay({super.key, required this.controller});

  final SignalReefController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.58),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SignalReefPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Paused',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: controller.resume,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Resume'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: controller.retry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Restart'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: controller.backHome,
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Menu'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
