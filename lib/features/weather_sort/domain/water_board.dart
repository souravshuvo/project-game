import 'water_tube.dart';

class WaterBoard {
  WaterBoard(List<WaterTube> tubes) : tubes = List.unmodifiable(tubes) {
    if (tubes.isEmpty) {
      throw const FormatException('A board must contain at least one tube.');
    }
  }

  final List<WaterTube> tubes;

  int get tubeCount => tubes.length;

  WaterTube tubeAt(int index) => tubes[index];

  bool containsTube(int index) {
    return index >= 0 && index < tubeCount;
  }

  WaterBoard replaceTube(int index, WaterTube tube) {
    final nextTubes = tubes.toList(growable: false);
    nextTubes[index] = tube;

    return WaterBoard(nextTubes);
  }

  List<String> toSymbolRows() {
    return tubes.map((tube) => tube.toSymbols()).toList(growable: false);
  }
}
