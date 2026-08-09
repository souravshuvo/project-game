class BoardPosition {
  const BoardPosition(this.row, this.col);

  final int row;
  final int col;

  @override
  bool operator ==(Object other) {
    return other is BoardPosition && other.row == row && other.col == col;
  }

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => 'BoardPosition(row: $row, col: $col)';
}
