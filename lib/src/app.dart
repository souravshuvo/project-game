import 'package:flutter/material.dart';

import 'game/domain/models.dart';
import 'game/presentation/screens/home_screen.dart';
import 'game/presentation/widgets/board_palette.dart';

class SholoGutiApp extends StatefulWidget {
  const SholoGutiApp({super.key});

  @override
  State<SholoGutiApp> createState() => _SholoGutiAppState();
}

class _SholoGutiAppState extends State<SholoGutiApp> {
  GameSettings _settings = const GameSettings();
  final List<MatchRecord> _history = [];

  void _updateSettings(GameSettings settings) {
    setState(() {
      _settings = settings;
    });
  }

  void _recordMatch(MatchRecord record) {
    setState(() {
      _history.insert(0, record);
      if (_history.length > 20) {
        _history.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = BoardPalette.fromChoice(_settings.boardTheme);
    return MaterialApp(
      title: 'Rapid Jump',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: palette.player1,
          brightness: _settings.boardTheme == BoardThemeChoice.night
              ? Brightness.dark
              : Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(
        settings: _settings,
        history: List.unmodifiable(_history),
        onSettingsChanged: _updateSettings,
        onMatchFinished: _recordMatch,
      ),
    );
  }
}
