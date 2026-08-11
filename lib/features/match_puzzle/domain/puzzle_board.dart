import 'board_position.dart';
import 'tile_kind.dart';

class PuzzleBoard {
  PuzzleBoard({
    required this.width,
    required this.height,
    required List<TileKind?> cells,
  }) : cells = List.unmodifiable(cells) {
    if (width <= 0 || height <= 0) {
      throw const FormatException('Board dimensions must be positive.');
    }
    if (cells.length != width * height) {
      throw const FormatException('Cell count must match board dimensions.');
    }
  }

  factory PuzzleBoard.fromRows(List<String> rows) {
    if (rows.isEmpty) {
      throw const FormatException('A board must contain rows.');
    }

    final width = rows.first.length;
    if (width == 0) {
      throw const FormatException('A board row cannot be empty.');
    }

    final cells = <TileKind?>[];
    for (final row in rows) {
      if (row.length != width) {
        throw const FormatException('Board rows must be rectangular.');
      }
      for (final symbol in row.split('')) {
        cells.add(symbol == '.' ? null : TileKind.fromSymbol(symbol));
      }
    }

    return PuzzleBoard(width: width, height: rows.length, cells: cells);
  }

  final int width;
  final int height;
  final List<TileKind?> cells;

  bool get hasEmptyCells => cells.any((tile) => tile == null);

  bool contains(BoardPosition position) {
    return position.row >= 0 &&
        position.row < height &&
        position.col >= 0 &&
        position.col < width;
  }

  int indexOf(BoardPosition position) {
    if (!contains(position)) {
      throw RangeError('Position is outside the board: $position');
    }
    return position.row * width + position.col;
  }

  TileKind? tileAt(BoardPosition position) => cells[indexOf(position)];

  PuzzleBoard withTile(BoardPosition position, TileKind? tile) {
    final next = cells.toList(growable: false);
    next[indexOf(position)] = tile;
    return PuzzleBoard(width: width, height: height, cells: next);
  }

  PuzzleBoard swap(BoardPosition first, BoardPosition second) {
    final firstIndex = indexOf(first);
    final secondIndex = indexOf(second);
    final next = cells.toList(growable: false);
    final firstTile = next[firstIndex];
    next[firstIndex] = next[secondIndex];
    next[secondIndex] = firstTile;
    return PuzzleBoard(width: width, height: height, cells: next);
  }

  Iterable<BoardPosition> get positions sync* {
    for (var row = 0; row < height; row++) {
      for (var col = 0; col < width; col++) {
        yield BoardPosition(row, col);
      }
    }
  }

  List<String> toRows() {
    return List.generate(height, (row) {
      final symbols = <String>[];
      for (var col = 0; col < width; col++) {
        symbols.add(tileAt(BoardPosition(row, col))?.symbol ?? '.');
      }
      return symbols.join();
    }, growable: false);
  }
}
