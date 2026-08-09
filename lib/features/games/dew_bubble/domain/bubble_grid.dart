import 'bubble_color.dart';
import 'grid_position.dart';

class BubbleGrid {
  BubbleGrid({
    required this.rows,
    required this.columns,
    required List<List<DewBubbleColor?>> cells,
  }) : _cells = List.generate(
         rows,
         (row) => List<DewBubbleColor?>.generate(
           columns,
           (column) => row < cells.length && column < cells[row].length
               ? cells[row][column]
               : null,
         ),
       );

  factory BubbleGrid.fromTokens(List<List<String?>> layout) {
    final rows = layout.length;
    final columns = layout
        .map((row) => row.length)
        .fold<int>(0, (longest, length) => length > longest ? length : longest);

    return BubbleGrid(
      rows: rows,
      columns: columns,
      cells: [
        for (final row in layout)
          [for (final token in row) dewBubbleColorFromToken(token)],
      ],
    );
  }

  final int rows;
  final int columns;
  final List<List<DewBubbleColor?>> _cells;

  DewBubbleColor? colorAt(GridPosition position) {
    if (!contains(position)) {
      return null;
    }
    return _cells[position.row][position.column];
  }

  bool contains(GridPosition position) {
    return position.row >= 0 &&
        position.row < rows &&
        position.column >= 0 &&
        position.column < columns;
  }

  bool isEmpty(GridPosition position) {
    return contains(position) && colorAt(position) == null;
  }

  void setColor(GridPosition position, DewBubbleColor color) {
    if (!contains(position)) {
      return;
    }
    _cells[position.row][position.column] = color;
  }

  void removeAll(Iterable<GridPosition> positions) {
    for (final position in positions) {
      if (contains(position)) {
        _cells[position.row][position.column] = null;
      }
    }
  }

  List<GridPosition> occupiedPositions() {
    final positions = <GridPosition>[];
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final position = GridPosition(row, column);
        if (colorAt(position) != null) {
          positions.add(position);
        }
      }
    }
    return positions;
  }

  List<GridPosition> neighbors(GridPosition position) {
    final row = position.row;
    final column = position.column;
    final offsets = row.isEven
        ? const [(0, -1), (0, 1), (-1, -1), (-1, 0), (1, -1), (1, 0)]
        : const [(0, -1), (0, 1), (-1, 0), (-1, 1), (1, 0), (1, 1)];

    return [
      for (final (rowOffset, columnOffset) in offsets)
        GridPosition(row + rowOffset, column + columnOffset),
    ].where(contains).toList(growable: false);
  }

  Set<GridPosition> connectedSameColor(GridPosition start) {
    final color = colorAt(start);
    if (color == null) {
      return <GridPosition>{};
    }

    final visited = <GridPosition>{};
    final queue = <GridPosition>[start];

    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      if (!visited.add(current)) {
        continue;
      }

      for (final neighbor in neighbors(current)) {
        if (!visited.contains(neighbor) && colorAt(neighbor) == color) {
          queue.add(neighbor);
        }
      }
    }

    return visited;
  }

  Set<GridPosition> floatingPositions() {
    final supported = <GridPosition>{};
    final queue = <GridPosition>[
      for (var column = 0; column < columns; column++)
        if (colorAt(GridPosition(0, column)) != null) GridPosition(0, column),
    ];

    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      if (!supported.add(current)) {
        continue;
      }

      for (final neighbor in neighbors(current)) {
        if (!supported.contains(neighbor) && colorAt(neighbor) != null) {
          queue.add(neighbor);
        }
      }
    }

    return occupiedPositions()
        .where((position) => !supported.contains(position))
        .toSet();
  }

  int get bubbleCount => occupiedPositions().length;

  bool get isCleared => bubbleCount == 0;
}
