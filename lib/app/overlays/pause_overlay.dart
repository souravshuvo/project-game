import 'package:flutter/material.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.onResume});

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xff062d33).withAlpha(128),
      child: Center(
        child: FilledButton(onPressed: onResume, child: const Text('RESUME')),
      ),
    );
  }
}
