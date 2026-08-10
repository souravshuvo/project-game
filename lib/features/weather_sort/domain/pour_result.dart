import 'water_board.dart';
import 'weather_essence.dart';

enum PourInvalidReason {
  outOfRange,
  sameTube,
  sourceEmpty,
  destinationFull,
  colorMismatch,
  noTransfer,
}

class PourResult {
  const PourResult._({
    required this.board,
    required this.layersMoved,
    required this.essence,
    required this.invalidReason,
  });

  factory PourResult.valid({
    required WaterBoard board,
    required int layersMoved,
    required WeatherEssence essence,
  }) {
    return PourResult._(
      board: board,
      layersMoved: layersMoved,
      essence: essence,
      invalidReason: null,
    );
  }

  factory PourResult.invalid({
    required WaterBoard board,
    required PourInvalidReason reason,
  }) {
    return PourResult._(
      board: board,
      layersMoved: 0,
      essence: null,
      invalidReason: reason,
    );
  }

  final WaterBoard board;
  final int layersMoved;
  final WeatherEssence? essence;
  final PourInvalidReason? invalidReason;

  bool get isValid => invalidReason == null;
}
