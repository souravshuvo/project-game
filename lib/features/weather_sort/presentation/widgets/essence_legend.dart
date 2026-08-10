import 'package:flutter/material.dart';

import '../../domain/weather_essence.dart';
import '../theme/weather_sort_theme.dart';
import 'weather_essence_view.dart';

class EssenceLegend extends StatelessWidget {
  const EssenceLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final essence in WeatherEssence.values)
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: WeatherSortColors.line),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(essence.icon, size: 17, color: essence.color),
                  const SizedBox(width: 6),
                  Text(
                    essence.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: WeatherSortColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
