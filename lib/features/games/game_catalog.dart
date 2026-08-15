import 'package:flutter/material.dart';

import '../../core/analytics/game_analytics.dart';
import '../../core/audio/letter_audio_cue.dart';
import '../tracing/data/progress_repository.dart';
import 'creative/balloon_pop_game_screen.dart';
import 'creative/drawing_game_screen.dart';
import 'creative/memory_match_game_screen.dart';
import 'creative/shape_match_game_screen.dart';
import 'logic/animal_finder_game_screen.dart';
import 'logic/color_sort_game_screen.dart';
import 'logic/counting_game_screen.dart';
import 'logic/pattern_puzzle_game_screen.dart';
import 'tracing/letter_tracing_game_screen.dart';
import 'tracing/number_tracing_game_screen.dart';

typedef GameScreenBuilder =
    Widget Function(
      BuildContext context,
      VoidCallback onCompleted,
      VoidCallback onPlayNextGame,
      String nextGameTitle,
      LetterAudioCue audioCue,
      ProgressRepository progressRepository,
      GameAnalytics analytics,
    );

@immutable
class KidsGame {
  const KidsGame({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.mission,
    required this.contentTotal,
    required this.difficultyTier,
    required this.icon,
    required this.colors,
    required this.builder,
  });

  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String mission;
  final int contentTotal;
  final String difficultyTier;
  final IconData icon;
  final List<Color> colors;
  final GameScreenBuilder builder;
}

final List<KidsGame> kidsGameCatalog = List.unmodifiable(<KidsGame>[
  KidsGame(
    id: 'letter-tracing',
    title: 'Letter Tracing',
    subtitle: 'Follow the path from A to Z',
    category: 'Trace Quest',
    mission: 'Trace every uppercase letter',
    contentTotal: LetterTracingGameScreen.contentCount,
    difficultyTier: 'easy',
    icon: Icons.gesture_rounded,
    colors: const [Color(0xFF7658E8), Color(0xFF9A7CF6)],
    builder:
        (
          _,
          onCompleted,
          onPlayNextGame,
          nextGameTitle,
          audioCue,
          progressRepository,
          analytics,
        ) => LetterTracingGameScreen(
          onCompleted: onCompleted,
          onPlayNextGame: onPlayNextGame,
          nextGameTitle: nextGameTitle,
          audioCue: audioCue,
          progressRepository: progressRepository,
          gameId: 'letter-tracing',
          analytics: analytics,
        ),
  ),
  KidsGame(
    id: 'number-tracing',
    title: 'Number Tracing',
    subtitle: 'Draw numbers 1 to 10',
    category: 'Trace Quest',
    mission: 'Finish the number trail',
    contentTotal: NumberTracingGameScreen.contentCount,
    difficultyTier: 'easy',
    icon: Icons.looks_3_rounded,
    colors: const [Color(0xFFEC6F66), Color(0xFFFF9B72)],
    builder:
        (
          _,
          onCompleted,
          onPlayNextGame,
          nextGameTitle,
          audioCue,
          progressRepository,
          analytics,
        ) => NumberTracingGameScreen(
          onCompleted: onCompleted,
          onPlayNextGame: onPlayNextGame,
          nextGameTitle: nextGameTitle,
          audioCue: audioCue,
          progressRepository: progressRepository,
          gameId: 'number-tracing',
          analytics: analytics,
        ),
  ),
  KidsGame(
    id: 'magic-drawing',
    title: 'Magic Drawing',
    subtitle: 'Paint sixteen little prompts',
    category: 'Creative Studio',
    mission: 'Earn sparks with bigger drawings',
    contentTotal: DrawingGameScreen.contentCount,
    difficultyTier: 'easy',
    icon: Icons.palette_rounded,
    colors: const [Color(0xFFEF4D9B), Color(0xFFFF83C1)],
    builder:
        (_, onCompleted, onPlayNextGame, nextGameTitle, audioCue, __, ___) =>
            DrawingGameScreen(
              onCompleted: onCompleted,
              onPlayNextGame: onPlayNextGame,
              nextGameTitle: nextGameTitle,
              audioCue: audioCue,
            ),
  ),
  KidsGame(
    id: 'memory-match',
    title: 'Memory Match',
    subtitle: 'Play six matching boards',
    category: 'Brain Games',
    mission: 'Clear boards in fewer moves',
    contentTotal: MemoryMatchGameScreen.contentCount,
    difficultyTier: 'medium',
    icon: Icons.grid_view_rounded,
    colors: const [Color(0xFF3F8FEF), Color(0xFF67B8F7)],
    builder:
        (_, onCompleted, onPlayNextGame, nextGameTitle, audioCue, __, ___) =>
            MemoryMatchGameScreen(
              onCompleted: onCompleted,
              onPlayNextGame: onPlayNextGame,
              nextGameTitle: nextGameTitle,
              audioCue: audioCue,
            ),
  ),
  KidsGame(
    id: 'balloon-pop',
    title: 'Balloon Pop',
    subtitle: 'Pop five balloon waves',
    category: 'Quick Play',
    mission: 'Build a pop streak',
    contentTotal: BalloonPopGameScreen.contentCount,
    difficultyTier: 'medium',
    icon: Icons.bubble_chart_rounded,
    colors: const [Color(0xFFFF8A3D), Color(0xFFFFC14F)],
    builder:
        (_, onCompleted, onPlayNextGame, nextGameTitle, audioCue, __, ___) =>
            BalloonPopGameScreen(
              onCompleted: onCompleted,
              onPlayNextGame: onPlayNextGame,
              nextGameTitle: nextGameTitle,
              audioCue: audioCue,
            ),
  ),
  KidsGame(
    id: 'shape-match',
    title: 'Shape Match',
    subtitle: 'Clear ten shape boards',
    category: 'Puzzle Path',
    mission: 'Match each shape home',
    contentTotal: ShapeMatchGameScreen.contentCount,
    difficultyTier: 'medium',
    icon: Icons.category_rounded,
    colors: const [Color(0xFF2CB9A0), Color(0xFF65D5B7)],
    builder:
        (_, onCompleted, onPlayNextGame, nextGameTitle, audioCue, __, ___) =>
            ShapeMatchGameScreen(
              onCompleted: onCompleted,
              onPlayNextGame: onPlayNextGame,
              nextGameTitle: nextGameTitle,
              audioCue: audioCue,
            ),
  ),
  KidsGame(
    id: 'counting',
    title: 'Count & Choose',
    subtitle: 'Count groups from 1 to 10',
    category: 'Number Sense',
    mission: 'Count every group',
    contentTotal: CountingGameScreen.contentCount,
    difficultyTier: 'easy',
    icon: Icons.filter_9_plus_rounded,
    colors: const [Color(0xFF8D57D9), Color(0xFFBE78E8)],
    builder:
        (_, onCompleted, onPlayNextGame, nextGameTitle, audioCue, __, ___) =>
            CountingGameScreen(
              onCompleted: onCompleted,
              onPlayNextGame: onPlayNextGame,
              nextGameTitle: nextGameTitle,
              audioCue: audioCue,
            ),
  ),
  KidsGame(
    id: 'color-sort',
    title: 'Color Sorting',
    subtitle: 'Sort ten color boards',
    category: 'Puzzle Path',
    mission: 'Sort colors without guessing',
    contentTotal: ColorSortGameScreen.contentCount,
    difficultyTier: 'hard',
    icon: Icons.color_lens_rounded,
    colors: const [Color(0xFFE34E62), Color(0xFFF88770)],
    builder:
        (_, onCompleted, onPlayNextGame, nextGameTitle, audioCue, __, ___) =>
            ColorSortGameScreen(
              onCompleted: onCompleted,
              onPlayNextGame: onPlayNextGame,
              nextGameTitle: nextGameTitle,
              audioCue: audioCue,
            ),
  ),
  KidsGame(
    id: 'animal-finder',
    title: 'Animal Finder',
    subtitle: 'Find ten friendly animals',
    category: 'Look & Learn',
    mission: 'Spot each target animal',
    contentTotal: AnimalFinderGameScreen.contentCount,
    difficultyTier: 'medium',
    icon: Icons.pets_rounded,
    colors: const [Color(0xFF3B9B62), Color(0xFF74C96F)],
    builder:
        (_, onCompleted, onPlayNextGame, nextGameTitle, audioCue, __, ___) =>
            AnimalFinderGameScreen(
              onCompleted: onCompleted,
              onPlayNextGame: onPlayNextGame,
              nextGameTitle: nextGameTitle,
              audioCue: audioCue,
            ),
  ),
  KidsGame(
    id: 'pattern-puzzle',
    title: 'Pattern Puzzle',
    subtitle: 'Solve ten little patterns',
    category: 'Brain Games',
    mission: 'Continue every pattern',
    contentTotal: PatternPuzzleGameScreen.contentCount,
    difficultyTier: 'hard',
    icon: Icons.extension_rounded,
    colors: const [Color(0xFF4C75D8), Color(0xFF7399EF)],
    builder:
        (_, onCompleted, onPlayNextGame, nextGameTitle, audioCue, __, ___) =>
            PatternPuzzleGameScreen(
              onCompleted: onCompleted,
              onPlayNextGame: onPlayNextGame,
              nextGameTitle: nextGameTitle,
              audioCue: audioCue,
            ),
  ),
]);
