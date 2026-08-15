enum WeatherEssence {
  rain('R', 'Rain'),
  sun('S', 'Sun'),
  mist('M', 'Mist'),
  cloud('C', 'Cloud'),
  frost('F', 'Frost');

  const WeatherEssence(this.symbol, this.label);

  final String symbol;
  final String label;

  static WeatherEssence fromSymbol(String symbol) {
    for (final essence in WeatherEssence.values) {
      if (essence.symbol == symbol) {
        return essence;
      }
    }

    throw FormatException('Unsupported weather essence symbol: $symbol');
  }
}
