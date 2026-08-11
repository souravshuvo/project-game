import 'package:flutter/material.dart';

import '../../domain/models.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final GameSettings settings;
  final ValueChanged<GameSettings> onChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late GameSettings _settings = widget.settings;

  void _update(GameSettings settings) {
    setState(() {
      _settings = settings;
    });
    widget.onChanged(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<BotDifficulty>(
            value: _settings.botDifficulty,
            decoration: const InputDecoration(labelText: 'Bot Difficulty'),
            items: [
              for (final difficulty in BotDifficulty.values)
                DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty.label),
                ),
            ],
            onChanged: (difficulty) {
              if (difficulty != null) {
                _update(_settings.copyWith(botDifficulty: difficulty));
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<BoardThemeChoice>(
            value: _settings.boardTheme,
            decoration: const InputDecoration(labelText: 'Board Theme'),
            items: [
              for (final theme in BoardThemeChoice.values)
                DropdownMenuItem(value: theme, child: Text(theme.label)),
            ],
            onChanged: (theme) {
              if (theme != null) {
                _update(_settings.copyWith(boardTheme: theme));
              }
            },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Hints'),
            value: _settings.hintsEnabled,
            onChanged: (enabled) {
              _update(_settings.copyWith(hintsEnabled: enabled));
            },
          ),
        ],
      ),
    );
  }
}
