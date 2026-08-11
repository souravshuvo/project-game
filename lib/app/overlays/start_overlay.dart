import 'package:flutter/material.dart';

import '../../game/world/world_config.dart';

class StartOverlay extends StatelessWidget {
  const StartOverlay({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return _PanelOverlay(
      title: WorldConfig.gameTitle.toUpperCase(),
      message:
          'Hold LEFT or RIGHT to steer. Land on weather pads to auto-jump past warning sparks.',
      buttonLabel: 'START RUN',
      onPressed: onStart,
    );
  }
}

class _PanelOverlay extends StatelessWidget {
  const _PanelOverlay({
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xff062d33).withAlpha(96),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xfffff8df).withAlpha(238),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xff163d3f), width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xff163d3f),
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xff274c48),
                          fontSize: 16,
                          height: 1.35,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 22),
                      FilledButton(
                        onPressed: onPressed,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(172, 52),
                          backgroundColor: const Color(0xffd64c35),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          buttonLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
