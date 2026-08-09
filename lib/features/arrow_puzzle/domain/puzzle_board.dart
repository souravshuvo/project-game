import 'board_position.dart';
import 'puzzle_cell.dart';

class PuzzleBoard {
  PuzzleBoard._(this.cells);

  factory PuzzleBoard.fromRows(List<String> rows) {
    if (rows.isEmpty) {
      throw const FormatException('A puzzle level must contain rows.');
    }

    final width = rows.first.length;
    if (width == 0) {
      throw const FormatException('A puzzle row cannot be empty.');
    }

    final cells = <List<PuzzleCell>>[];
    var arrowCount = 0;

    for (final row in rows) {
      if (row.length != width) {
        throw const FormatException('Puzzle rows must be rectangular.');
      }

      final parsedRow = <PuzzleCell>[];
      for (final symbol in row.split('')) {
        final cell = PuzzleCell.fromSymbol(symbol);
        if (cell.isArrow) {
          arrowCount++;
        }
        parsedRow.add(cell);
      }
      cells.add(parsedRow);
    }

    if (arrowCount == 0) {
      throw const FormatException('A puzzle level must contain arrows.');
    }

    return PuzzleBoard._(cells);
  }

  final List<List<PuzzleCell>> cells;

  int get rowCount => cells.length;

  int get colCount => cells.first.length;

  PuzzleCell cellAt(BoardPosition position) =>
      cells[position.row][position.col];

  bool contains(BoardPosition position) {
    return position.row >= 0 &&
        position.row < rowCount &&
        position.col >= 0 &&
        position.col < colCount;
  }

  PuzzleBoard removeAt(BoardPosition position) {
    final nextCells = cells
        .map((row) => row.toList(growable: false))
        .toList(growable: false);
    nextCells[position.row][position.col] = PuzzleCell.empty;
    return PuzzleBoard._(nextCells);
  }

  bool get isCleared {
    return cells.every((row) => row.every((cell) => !cell.isArrow));
  }

  Iterable<BoardPosition> get positions sync* {
    for (var row = 0; row < rowCount; row++) {
      for (var col = 0; col < colCount; col++) {
        yield BoardPosition(row, col);
      }
    }
  }

  List<String> toRows() {
    return cells
        .map((row) => row.map((cell) => cell.symbol).join())
        .toList(growable: false);
  }
}
