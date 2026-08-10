import 'weather_essence.dart';

class WaterTube {
  WaterTube({required this.capacity, required List<WeatherEssence> layers})
    : layers = List.unmodifiable(layers) {
    if (capacity <= 0) {
      throw const FormatException('Tube capacity must be greater than zero.');
    }
    if (layers.length > capacity) {
      throw const FormatException('A tube cannot exceed its capacity.');
    }
  }

  factory WaterTube.empty(int capacity) {
    return WaterTube(capacity: capacity, layers: const []);
  }

  factory WaterTube.fromSymbols(String symbols, {required int capacity}) {
    return WaterTube(
      capacity: capacity,
      layers: symbols
          .split('')
          .where((symbol) => symbol.trim().isNotEmpty)
          .map(WeatherEssence.fromSymbol)
          .toList(growable: false),
    );
  }

  final int capacity;
  final List<WeatherEssence> layers;

  int get layerCount => layers.length;

  int get freeSlots => capacity - layerCount;

  bool get isEmpty => layers.isEmpty;

  bool get isFull => layerCount == capacity;

  WeatherEssence? get top => isEmpty ? null : layers.last;

  bool get isUniform {
    if (layers.isEmpty) {
      return true;
    }

    final first = layers.first;
    return layers.every((layer) => layer == first);
  }

  int get topGroupSize {
    final topLayer = top;
    if (topLayer == null) {
      return 0;
    }

    var count = 0;
    for (var index = layers.length - 1; index >= 0; index--) {
      if (layers[index] != topLayer) {
        break;
      }
      count++;
    }

    return count;
  }

  WaterTube removeFromTop(int count) {
    if (count < 0 || count > layerCount) {
      throw RangeError.range(count, 0, layerCount, 'count');
    }

    return WaterTube(
      capacity: capacity,
      layers: layers.take(layerCount - count).toList(growable: false),
    );
  }

  WaterTube addToTop(List<WeatherEssence> addedLayers) {
    if (addedLayers.length > freeSlots) {
      throw const FormatException('Added layers would overflow the tube.');
    }

    return WaterTube(capacity: capacity, layers: [...layers, ...addedLayers]);
  }

  String toSymbols() {
    return layers.map((layer) => layer.symbol).join();
  }
}
