enum TileKind {
  pulse('P', 'Pulse'),
  coil('C', 'Coil'),
  lens('L', 'Lens'),
  node('N', 'Node'),
  spark('S', 'Spark');

  const TileKind(this.symbol, this.label);

  final String symbol;
  final String label;

  static TileKind fromSymbol(String symbol) {
    return switch (symbol) {
      'P' => TileKind.pulse,
      'C' => TileKind.coil,
      'L' => TileKind.lens,
      'N' => TileKind.node,
      'S' => TileKind.spark,
      _ => throw FormatException('Unsupported tile symbol: $symbol'),
    };
  }
}
