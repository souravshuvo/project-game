import 'package:flutter/material.dart';

import '../../domain/models.dart';

class BoardPalette {
  const BoardPalette({
    required this.board,
    required this.border,
    required this.line,
    required this.node,
    required this.player1,
    required this.player2,
    required this.emptyNode,
    required this.normalMove,
    required this.captureMove,
    required this.capturedBead,
    required this.selected,
    required this.hint,
  });

  final Color board;
  final Color border;
  final Color line;
  final Color node;
  final Color player1;
  final Color player2;
  final Color emptyNode;
  final Color normalMove;
  final Color captureMove;
  final Color capturedBead;
  final Color selected;
  final Color hint;

  static BoardPalette fromChoice(BoardThemeChoice choice) {
    return switch (choice) {
      BoardThemeChoice.classic => const BoardPalette(
        board: Color(0xFFF6E7C8),
        border: Color(0xFF7B6545),
        line: Color(0xFF514333),
        node: Color(0xFF514333),
        player1: Color(0xFF276749),
        player2: Color(0xFF9D3D36),
        emptyNode: Color(0xFF4D463A),
        normalMove: Color(0xFF2D6CDF),
        captureMove: Color(0xFFD77B28),
        capturedBead: Color(0xFF7E1F1B),
        selected: Color(0xFF123326),
        hint: Color(0xFF7C3AED),
      ),
      BoardThemeChoice.night => const BoardPalette(
        board: Color(0xFF17211B),
        border: Color(0xFF8CBF9F),
        line: Color(0xFFD5E6D9),
        node: Color(0xFFD5E6D9),
        player1: Color(0xFF4ADE80),
        player2: Color(0xFFF87171),
        emptyNode: Color(0xFFD5E6D9),
        normalMove: Color(0xFF60A5FA),
        captureMove: Color(0xFFFBBF24),
        capturedBead: Color(0xFFFFA3A3),
        selected: Color(0xFFBBF7D0),
        hint: Color(0xFFC084FC),
      ),
      BoardThemeChoice.highContrast => const BoardPalette(
        board: Color(0xFFFFFFFF),
        border: Color(0xFF000000),
        line: Color(0xFF000000),
        node: Color(0xFF000000),
        player1: Color(0xFF0057D8),
        player2: Color(0xFFD00000),
        emptyNode: Color(0xFF111111),
        normalMove: Color(0xFF008CFF),
        captureMove: Color(0xFFFFA000),
        capturedBead: Color(0xFFD00000),
        selected: Color(0xFF000000),
        hint: Color(0xFF7B1FA2),
      ),
    };
  }
}
