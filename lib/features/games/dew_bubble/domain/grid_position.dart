import 'package:flutter/foundation.dart';

@immutable
class GridPosition {
  const GridPosition(this.row, this.column);

  final int row;
  final int column;

  @override
  bool operator ==(Object other) {
    return other is GridPosition && other.row == row && other.column == column;
  }

  @override
  int get hashCode => Object.hash(row, column);

  @override
  String toString() => 'GridPosition($row, $column)';
}
