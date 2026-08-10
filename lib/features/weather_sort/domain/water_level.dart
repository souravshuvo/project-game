import 'water_board.dart';
import 'water_tube.dart';

class WaterLevel {
  const WaterLevel({
    required this.id,
    required this.name,
    required this.capacity,
    required this.tubeSymbols,
    required this.parMoves,
    required this.lesson,
  });

  final int id;
  final String name;
  final int capacity;
  final List<String> tubeSymbols;
  final int parMoves;
  final String lesson;

  WaterBoard toBoard() {
    return WaterBoard(
      tubeSymbols
          .map((symbols) => WaterTube.fromSymbols(symbols, capacity: capacity))
          .toList(growable: false),
    );
  }
}
