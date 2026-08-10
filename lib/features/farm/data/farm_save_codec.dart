import 'dart:convert';
import 'dart:math' as math;

import '../domain/farm_plot.dart';
import '../domain/farm_rules.dart';
import '../domain/farm_state.dart';
import '../domain/inventory_state.dart';

class FarmSaveCodec {
  const FarmSaveCodec(this.rules);

  final FarmRules rules;

  String encode(FarmState state) {
    return jsonEncode(<String, Object?>{
      'version': 1,
      'coins': state.coins,
      'water': state.water,
      'farmLevel': state.farmLevel,
      'lastWaterRefillAtMs': state.lastWaterRefillAtMs,
      'lastSavedAtMs': state.lastSavedAtMs,
      'inventory': <String, Object?>{
        'seeds': state.inventory.seeds,
        'crate': state.inventory.crate,
      },
      'plots': <Map<String, Object?>>[
        for (final plot in state.plots)
          <String, Object?>{
            'cropId': plot.cropId,
            'plantedAtMs': plot.plantedAtMs,
            'wateredAtMs': plot.wateredAtMs,
          },
      ],
    });
  }

  FarmState decode(String raw, {required int nowMs}) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Save root was not an object.');
    }

    final inventoryJson = decoded['inventory'];
    final crateJson = inventoryJson is Map<String, dynamic>
        ? inventoryJson['crate']
        : null;
    final plotsJson = decoded['plots'];

    final plots = <FarmPlot>[
      if (plotsJson is List)
        for (final value in plotsJson)
          if (value is Map<String, dynamic>)
            FarmPlot(
              cropId: _readCropId(value['cropId']),
              plantedAtMs: _readNullableInt(value['plantedAtMs']),
              wateredAtMs: _readNullableInt(value['wateredAtMs']),
            )
          else
            const FarmPlot.empty(),
    ];

    while (plots.length < rules.plotCount) {
      plots.add(const FarmPlot.empty());
    }

    final farmLevel = _readInt(
      decoded['farmLevel'],
      fallback: 1,
    ).clamp(1, rules.maxLevel).toInt();
    return FarmState(
      coins: math.max(
        0,
        _readInt(decoded['coins'], fallback: rules.startingCoins),
      ),
      water: _readInt(
        decoded['water'],
        fallback: rules.startingWater,
      ).clamp(0, rules.waterCap(farmLevel)).toInt(),
      farmLevel: farmLevel,
      lastWaterRefillAtMs: _readInt(
        decoded['lastWaterRefillAtMs'],
        fallback: nowMs,
      ),
      lastSavedAtMs: _readInt(decoded['lastSavedAtMs'], fallback: nowMs),
      inventory: InventoryState(
        seeds: math.max(
          0,
          _readInt(
            inventoryJson is Map<String, dynamic>
                ? inventoryJson['seeds']
                : null,
            fallback: rules.startingSeeds,
          ),
        ),
        crate: _readCrate(crateJson),
      ),
      plots: plots.take(rules.plotCount).map(_sanitizePlot).toList(),
    );
  }

  FarmPlot _sanitizePlot(FarmPlot plot) {
    if (plot.cropId == null || plot.plantedAtMs == null) {
      return const FarmPlot.empty();
    }
    if (!rules.crops.any((crop) => crop.id == plot.cropId)) {
      return const FarmPlot.empty();
    }
    if (plot.wateredAtMs != null && plot.wateredAtMs! < plot.plantedAtMs!) {
      return FarmPlot.planted(plot.cropId!, plot.plantedAtMs!);
    }
    return plot;
  }

  static String? _readCropId(Object? value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  static int? _readNullableInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }

  static int _readInt(Object? value, {required int fallback}) {
    return _readNullableInt(value) ?? fallback;
  }

  Map<String, int> _readCrate(Object? value) {
    if (value is! Map<String, dynamic>) {
      return const <String, int>{};
    }

    final crate = <String, int>{};
    for (final entry in value.entries) {
      if (!rules.crops.any((crop) => crop.id == entry.key)) {
        continue;
      }
      final count = _readInt(entry.value, fallback: 0);
      if (count > 0) {
        crate[entry.key] = count;
      }
    }
    return crate;
  }
}
