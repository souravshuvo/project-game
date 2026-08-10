import 'package:flutter/material.dart';

import '../domain/board_position.dart';
import '../domain/puzzle_cell.dart';

IconData arrowIcon(PuzzleCell cell) {
  return switch (cell) {
    PuzzleCell.up => Icons.arrow_upward_rounded,
    PuzzleCell.down => Icons.arrow_downward_rounded,
    PuzzleCell.left => Icons.arrow_back_rounded,
    PuzzleCell.right => Icons.arrow_forward_rounded,
    PuzzleCell.empty => Icons.circle_outlined,
  };
}

Alignment exitAlignment(BoardPosition _, PuzzleCell cell) {
  return switch (cell) {
    PuzzleCell.up => const Alignment(0, -6),
    PuzzleCell.down => const Alignment(0, 6),
    PuzzleCell.left => const Alignment(-6, 0),
    PuzzleCell.right => const Alignment(6, 0),
    PuzzleCell.empty => Alignment.center,
  };
}
