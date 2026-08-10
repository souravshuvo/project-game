import 'package:flutter/material.dart';

import 'features/triple_match/application/triple_match_controller.dart';
import 'features/triple_match/data/local_level_pack.dart';
import 'features/triple_match/domain/puzzle_engine.dart';
import 'features/triple_match/presentation/pages/puzzle_page.dart';
import 'features/triple_match/presentation/theme/triple_match_theme.dart';

void main() {
  runApp(const TripleMatchApp());
}

class TripleMatchApp extends StatefulWidget {
  const TripleMatchApp({super.key});

  @override
  State<TripleMatchApp> createState() => _TripleMatchAppState();
}

class _TripleMatchAppState extends State<TripleMatchApp> {
  late final TripleMatchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TripleMatchController(
      engine: const PuzzleEngine(),
      levels: localLevelPack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'Larder Labels',
          debugShowCheckedModeBanner: false,
          theme: TripleMatchTheme.light(),
          home: PuzzlePage(controller: _controller),
        );
      },
    );
  }
}
