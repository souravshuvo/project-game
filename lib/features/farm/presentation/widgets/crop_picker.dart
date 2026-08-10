import 'package:flutter/material.dart';

import '../../domain/crop_definition.dart';

class CropPicker extends StatelessWidget {
  const CropPicker({
    super.key,
    required this.crops,
    required this.farmLevel,
    required this.selectedCropId,
    required this.onSelected,
  });

  final List<CropDefinition> crops;
  final int farmLevel;
  final String selectedCropId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0D5C4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_florist_outlined),
              const SizedBox(width: 8),
              Text('Seeds', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final crop in crops)
                ChoiceChip(
                  label: Text(_labelFor(crop)),
                  selected: crop.id == selectedCropId,
                  onSelected: crop.unlockLevel <= farmLevel
                      ? (_) => onSelected(crop.id)
                      : null,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _labelFor(CropDefinition crop) {
    if (crop.unlockLevel > farmLevel) {
      return '${crop.name} L${crop.unlockLevel}';
    }
    return '${crop.name} ${crop.growDuration.inSeconds}s';
  }
}
