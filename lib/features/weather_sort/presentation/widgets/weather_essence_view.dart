import 'package:flutter/material.dart';

import '../../domain/pour_result.dart';
import '../../domain/weather_essence.dart';
import '../theme/weather_sort_theme.dart';

extension WeatherEssenceView on WeatherEssence {
  Color get color {
    return switch (this) {
      WeatherEssence.rain => WeatherSortColors.rain,
      WeatherEssence.sun => WeatherSortColors.sun,
      WeatherEssence.mist => WeatherSortColors.mist,
      WeatherEssence.cloud => WeatherSortColors.cloud,
      WeatherEssence.frost => WeatherSortColors.frost,
    };
  }

  Color get foregroundColor {
    return switch (this) {
      WeatherEssence.rain => Colors.white,
      WeatherEssence.sun => const Color(0xFF4B3C12),
      WeatherEssence.mist => const Color(0xFF284540),
      WeatherEssence.cloud => Colors.white,
      WeatherEssence.frost => const Color(0xFF17434B),
    };
  }

  IconData get icon {
    return switch (this) {
      WeatherEssence.rain => Icons.water_drop_rounded,
      WeatherEssence.sun => Icons.wb_sunny_rounded,
      WeatherEssence.mist => Icons.air_rounded,
      WeatherEssence.cloud => Icons.cloud_rounded,
      WeatherEssence.frost => Icons.ac_unit_rounded,
    };
  }

  String get marker => symbol;
}

String invalidMoveMessage(PourInvalidReason? reason) {
  return switch (reason) {
    PourInvalidReason.sourceEmpty => 'Choose a vessel with liquid first.',
    PourInvalidReason.destinationFull => 'That vessel is already full.',
    PourInvalidReason.colorMismatch => 'Only matching top colors can combine.',
    PourInvalidReason.sameTube => 'Choose a different vessel.',
    PourInvalidReason.outOfRange => 'That vessel is unavailable.',
    PourInvalidReason.noTransfer => 'Nothing moved.',
    null => '',
  };
}
