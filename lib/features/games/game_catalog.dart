import 'package:flutter/material.dart';

import '../../core/audio/letter_audio_cue.dart';
import 'creative/balloon_pop_game_screen.dart';
import 'creative/drawing_game_screen.dart';
import 'creative/memory_match_game_screen.dart';
import 'creative/shape_match_game_screen.dart';
import 'logic/animal_finder_game_screen.dart';
import 'logic/color_sort_game_screen.dart';
import 'logic/counting_game_screen.dart';
import 'logic/pattern_puzzle_game_screen.dart';
import 'pulse_parade/presentation/pulse_parade_game_screen.dart';
import 'tracing/letter_tracing_game_screen.dart';
import 'tracing/number_tracing_game_screen.dart';

typedef GameScreenBuilder =
    Widget Function(
      BuildContext context,
      VoidCallback onCompleted,
      LetterAudioCue audioCue,
    );

@immutable
class KidsGame {
  const KidsGame({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.builder,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final GameScreenBuilder builder;
}

final List<KidsGame> kidsGameCatalog = List.unmodifiable(<KidsGame>[
  KidsGame(
    id: 'pulse-parade',
    title: 'Pulse Parade',
    subtitle: 'Guide sparks through circuit gates',
    icon: Icons.offline_bolt_rounded,
    colors: const [Color(0xFF129C8A), Color(0xFF286EE8)],
    builder: (context, onCompleted, audioCue) =>
        PulseParadeGameScreen(onCompleted: onCompleted),
  ),
  KidsGame(
    id: 'letter-tracing',
    title: 'Letter Tracing',
    subtitle: 'Follow the path from A to C',
    icon: Icons.gesture_rounded,
    colors: const [Color(0xFF7658E8), Color(0xFF9A7CF6)],
    builder: (context, onCompleted, audioCue) =>
        LetterTracingGameScreen(onCompleted: onCompleted, audioCue: audioCue),
  ),
  KidsGame(
    id: 'number-tracing',
    title: 'Number Tracing',
    subtitle: 'Draw numbers 1, 2, and 3',
    icon: Icons.looks_3_rounded,
    colors: const [Color(0xFFEC6F66), Color(0xFFFF9B72)],
    builder: (context, onCompleted, audioCue) =>
        NumberTracingGameScreen(onCompleted: onCompleted, audioCue: audioCue),
  ),
  KidsGame(
    id: 'magic-drawing',
    title: 'Magic Drawing',
    subtitle: 'Paint with bright crayons',
    icon: Icons.palette_rounded,
    colors: const [Color(0xFFEF4D9B), Color(0xFFFF83C1)],
    builder: (context, onCompleted, audioCue) =>
        DrawingGameScreen(onCompleted: onCompleted),
  ),
  KidsGame(
    id: 'memory-match',
    title: 'Memory Match',
    subtitle: 'Find all the matching pairs',
    icon: Icons.grid_view_rounded,
    colors: const [Color(0xFF3F8FEF), Color(0xFF67B8F7)],
    builder: (context, onCompleted, audioCue) =>
        MemoryMatchGameScreen(onCompleted: onCompleted),
  ),
  KidsGame(
    id: 'balloon-pop',
    title: 'Balloon Pop',
    subtitle: 'Pop ten floating balloons',
    icon: Icons.bubble_chart_rounded,
    colors: const [Color(0xFFFF8A3D), Color(0xFFFFC14F)],
    builder: (context, onCompleted, audioCue) =>
        BalloonPopGameScreen(onCompleted: onCompleted),
  ),
  KidsGame(
    id: 'shape-match',
    title: 'Shape Match',
    subtitle: 'Drag shapes to their homes',
    icon: Icons.category_rounded,
    colors: const [Color(0xFF2CB9A0), Color(0xFF65D5B7)],
    builder: (context, onCompleted, audioCue) =>
        ShapeMatchGameScreen(onCompleted: onCompleted),
  ),
  KidsGame(
    id: 'counting',
    title: 'Count & Choose',
    subtitle: 'Count the objects you see',
    icon: Icons.filter_9_plus_rounded,
    colors: const [Color(0xFF8D57D9), Color(0xFFBE78E8)],
    builder: (context, onCompleted, audioCue) =>
        CountingGameScreen(onCompleted: onCompleted),
  ),
  KidsGame(
    id: 'color-sort',
    title: 'Color Sorting',
    subtitle: 'Match every color basket',
    icon: Icons.color_lens_rounded,
    colors: const [Color(0xFFE34E62), Color(0xFFF88770)],
    builder: (context, onCompleted, audioCue) =>
        ColorSortGameScreen(onCompleted: onCompleted),
  ),
  KidsGame(
    id: 'animal-finder',
    title: 'Animal Finder',
    subtitle: 'Can you find the right animal?',
    icon: Icons.pets_rounded,
    colors: const [Color(0xFF3B9B62), Color(0xFF74C96F)],
    builder: (context, onCompleted, audioCue) =>
        AnimalFinderGameScreen(onCompleted: onCompleted),
  ),
  KidsGame(
    id: 'pattern-puzzle',
    title: 'Pattern Puzzle',
    subtitle: 'Pick what comes next',
    icon: Icons.extension_rounded,
    colors: const [Color(0xFF4C75D8), Color(0xFF7399EF)],
    builder: (context, onCompleted, audioCue) =>
        PatternPuzzleGameScreen(onCompleted: onCompleted),
  ),
]);
