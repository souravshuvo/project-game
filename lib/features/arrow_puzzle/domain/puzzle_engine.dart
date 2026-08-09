import 'board_position.dart';
import 'puzzle_board.dart';
import 'puzzle_cell.dart';
import 'puzzle_level.dart';

class PuzzleEngine {
  const PuzzleEngine();

  PuzzleBoard parse(PuzzleLevel level) => PuzzleBoard.fromRows(level.rows);

  bool canRemove(PuzzleBoard board, BoardPosition position) {
    if (!board.contains(position)) {
      return false;
    }

    final cell = board.cellAt(position);
    if (!cell.isArrow) {
      return false;
    }

    return switch (cell) {
      PuzzleCell.up => _isClearUp(board, position),
      PuzzleCell.down => _isClearDown(board, position),
      PuzzleCell.left => _isClearLeft(board, position),
      PuzzleCell.right => _isClearRight(board, position),
      PuzzleCell.empty => false,
    };
  }

  PuzzleBoard remove(PuzzleBoard board, BoardPosition position) {
    if (!canRemove(board, position)) {
      return board;
    }
    return board.removeAt(position);
  }

  List<BoardPosition> validMoves(PuzzleBoard board) {
    return board.positions
        .where((position) => canRemove(board, position))
        .toList(growable: false);
  }

  bool isStuck(PuzzleBoard board) {
    return !board.isCleared && validMoves(board).isEmpty;
  }

  bool isSolvable(PuzzleLevel level) {
    var board = parse(level);
    while (!board.isCleared) {
      final moves = validMoves(board);
      if (moves.isEmpty) {
        return false;
      }
      board = remove(board, moves.first);
    }
    return true;
  }

  bool _isClearUp(PuzzleBoard board, BoardPosition position) {
    for (var row = position.row - 1; row >= 0; row--) {
      if (board.cellAt(BoardPosition(row, position.col)).isArrow) {
        return false;
      }
    }
    return true;
  }

  bool _isClearDown(PuzzleBoard board, BoardPosition position) {
    for (var row = position.row + 1; row < board.rowCount; row++) {
      if (board.cellAt(BoardPosition(row, position.col)).isArrow) {
        return false;
      }
    }
    return true;
  }

  bool _isClearLeft(PuzzleBoard board, BoardPosition position) {
    for (var col = position.col - 1; col >= 0; col--) {
      if (board.cellAt(BoardPosition(position.row, col)).isArrow) {
        return false;
      }
    }
    return true;
  }

  bool _isClearRight(PuzzleBoard board, BoardPosition position) {
    for (var col = position.col + 1; col < board.colCount; col++) {
      if (board.cellAt(BoardPosition(position.row, col)).isArrow) {
        return false;
      }
    }
    return true;
  }
}
