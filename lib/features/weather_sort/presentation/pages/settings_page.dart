import 'package:flutter/material.dart';

import '../../application/water_sort_controller.dart';
import '../theme/weather_sort_theme.dart';

class WaterSettingsPage extends StatelessWidget {
  const WaterSettingsPage({super.key, required this.controller});

  final WaterSortController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: controller.backHome,
          icon: const Icon(Icons.home_rounded),
          tooltip: 'Home',
        ),
        title: const Text('Settings'),
      ),
      body: WeatherBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WeatherPanel(
                  shadow: true,
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: controller.soundEnabled,
                        onChanged: controller.toggleSound,
                        secondary: const Icon(Icons.volume_up_rounded),
                        title: const Text('Sound'),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        value: controller.hapticsEnabled,
                        onChanged: controller.toggleHaptics,
                        secondary: const Icon(Icons.vibration_rounded),
                        title: const Text('Haptics'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                WeatherPanel(
                  color: WeatherSortColors.wash,
                  borderColor: const Color(0xFFC9DAE8),
                  child: Text(
                    'Weather Lab Sort saves progress only on this device. No ads, accounts, or analytics are active in this build.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: WeatherSortColors.mutedInk,
                      fontWeight: FontWeight.w600,
                    ),
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
