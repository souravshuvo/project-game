import 'tic_tac_toe_mark.dart';

class TicTacToeBoard {
  TicTacToeBoard._(List<TicTacToeMark?> cells)
    : cells = List.unmodifiable(cells);

  factory TicTacToeBoard.empty() {
    return TicTacToeBoard._(List<TicTacToeMark?>.filled(cellCount, null));
  }

  factory TicTacToeBoard.fromCells(List<TicTacToeMark?> cells) {
    if (cells.length != cellCount) {
      throw const FormatException('A tic tac toe board must have 9 cells.');
    }

    return TicTacToeBoard._(cells);
  }

  static const sideLength = 3;
  static const cellCount = sideLength * sideLength;

  final List<TicTacToeMark?> cells;

  TicTacToeMark? cellAt(int index) {
    if (!containsIndex(index)) {
      throw RangeError.index(index, cells, 'index');
    }

    return cells[index];
  }

  bool containsIndex(int index) => index >= 0 && index < cellCount;

  bool isCellEmpty(int index) => containsIndex(index) && cells[index] == null;

  bool get isFull => cells.every((cell) => cell != null);

  List<int> get availableCells {
    final indexes = <int>[];
    for (var index = 0; index < cells.length; index++) {
      if (cells[index] == null) {
        indexes.add(index);
      }
    }

    return indexes;
  }

  TicTacToeBoard place(int index, TicTacToeMark mark) {
    if (!isCellEmpty(index)) {
      return this;
    }

    final nextCells = cells.toList(growable: false);
    nextCells[index] = mark;

    return TicTacToeBoard._(nextCells);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! TicTacToeBoard || other.cells.length != cells.length) {
      return false;
    }

    for (var index = 0; index < cells.length; index++) {
      if (other.cells[index] != cells[index]) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode {
    return Object.hashAll(cells.map((cell) => cell?.index ?? -1));
  }
}
