enum TicTacToeMark {
  x,
  o;

  TicTacToeMark get opponent {
    return switch (this) {
      TicTacToeMark.x => TicTacToeMark.o,
      TicTacToeMark.o => TicTacToeMark.x,
    };
  }

  String get symbol {
    return switch (this) {
      TicTacToeMark.x => 'X',
      TicTacToeMark.o => 'O',
    };
  }
}
