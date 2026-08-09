enum PuzzleCell {
  empty('.'),
  up('U'),
  down('D'),
  left('L'),
  right('R');

  const PuzzleCell(this.symbol);

  final String symbol;

  bool get isArrow => this != PuzzleCell.empty;

  static PuzzleCell fromSymbol(String symbol) {
    return switch (symbol) {
      '.' => PuzzleCell.empty,
      'U' => PuzzleCell.up,
      'D' => PuzzleCell.down,
      'L' => PuzzleCell.left,
      'R' => PuzzleCell.right,
      _ => throw FormatException('Unsupported puzzle symbol: $symbol'),
    };
  }
}
