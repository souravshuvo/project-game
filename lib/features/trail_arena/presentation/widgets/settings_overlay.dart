import 'package:flutter/material.dart';

import '../../domain/game_settings.dart';

class SettingsOverlay extends StatelessWidget {
  const SettingsOverlay({
    super.key,
    required this.settings,
    required this.onChanged,
    required this.onClose,
  });

  final GameSettings settings;
  final ValueChanged<GameSettings> onChanged;
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
                              'Settings',
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
                      const SizedBox(height: 8),
                      SwitchListTile(
                        value: settings.soundEnabled,
                        onChanged: (value) {
                          onChanged(settings.copyWith(soundEnabled: value));
                        },
                        title: const Text('Sound'),
                        secondary: const Icon(Icons.volume_up_rounded),
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        value: settings.hapticsEnabled,
                        onChanged: (value) {
                          onChanged(settings.copyWith(hapticsEnabled: value));
                        },
                        title: const Text('Haptics'),
                        secondary: const Icon(Icons.vibration_rounded),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.touch_app_rounded),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Steering sensitivity',
                                  style: TextStyle(letterSpacing: 0),
                                ),
                                Slider(
                                  value: settings.controlSensitivity,
                                  min: 0.75,
                                  max: 1.35,
                                  divisions: 6,
                                  label:
                                      '${(settings.controlSensitivity * 100).round()}%',
                                  onChanged: (value) {
                                    onChanged(
                                      settings.copyWith(
                                        controlSensitivity: value,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: onClose,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Done'),
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
