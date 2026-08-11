class BoardPosition {
  const BoardPosition(this.row, this.col);

  final int row;
  final int col;

  bool isAdjacentTo(BoardPosition other) {
    final rowDistance = (row - other.row).abs();
    final colDistance = (col - other.col).abs();
    return rowDistance + colDistance == 1;
  }

  @override
  bool operator ==(Object other) {
    return other is BoardPosition && row == other.row && col == other.col;
  }

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => 'BoardPosition($row, $col)';
}
