import 'package:flutter/material.dart';

class HelpOverlay extends StatelessWidget {
  const HelpOverlay({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xCC000000)),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF142018),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF65F0B4)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'How to Play',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: onClose,
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const _HelpRow(
                        icon: Icons.swipe_rounded,
                        text: 'Drag anywhere in the arena to turn.',
                      ),
                      const _HelpRow(
                        icon: Icons.radio_button_checked_rounded,
                        text: 'Collect seeds to grow and score.',
                      ),
                      const _HelpRow(
                        icon: Icons.route_rounded,
                        text: 'Avoid walls, your trail, and rival trails.',
                      ),
                      const _HelpRow(
                        icon: Icons.refresh_rounded,
                        text: 'Retry quickly and chase a better best score.',
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: onClose,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Got it'),
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

class _HelpRow extends StatelessWidget {
  const _HelpRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF65F0B4), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFE7F4EC),
                fontSize: 15,
                height: 1.3,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
