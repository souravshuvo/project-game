import 'package:flutter/material.dart';

import '../../domain/crop_definition.dart';
import '../../domain/farm_plot.dart';
import '../../domain/farm_rules.dart';
import '../../domain/farm_state.dart';

class PlotActionPanel extends StatelessWidget {
  const PlotActionPanel({
    super.key,
    required this.state,
    required this.rules,
    required this.selectedCrop,
    required this.selectedPlot,
    required this.nowMs,
    required this.onPlant,
    required this.onWater,
    required this.onHarvest,
  });

  final FarmState state;
  final FarmRules rules;
  final CropDefinition selectedCrop;
  final int selectedPlot;
  final int nowMs;
  final VoidCallback onPlant;
  final VoidCallback onWater;
  final VoidCallback onHarvest;

  @override
  Widget build(BuildContext context) {
    final status = rules.plotStatus(state, selectedPlot, nowMs);
    final plot = state.plots[selectedPlot];
    final canPlant =
        status == PlotStatus.empty &&
        state.inventory.seeds >= selectedCrop.seedCost &&
        rules.isCropUnlocked(selectedCrop.id, state.farmLevel);
    final canWater = status == PlotStatus.plantedDry && state.water > 0;
    final canHarvest = status == PlotStatus.ready;
    final helperText = _helperText(plot, status, canPlant, canWater);

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
              const Icon(Icons.agriculture_outlined, color: Color(0xFF405A37)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Plot ${selectedPlot + 1} / ${_plotStatusText(plot, status, rules, nowMs)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(helperText, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: canPlant ? onPlant : null,
                icon: const Icon(Icons.spa_outlined),
                label: Text('Plant ${selectedCrop.name}'),
              ),
              FilledButton.icon(
                onPressed: canWater ? onWater : null,
                icon: const Icon(Icons.water_drop_outlined),
                label: const Text('Water'),
              ),
              FilledButton.icon(
                onPressed: canHarvest ? onHarvest : null,
                icon: const Icon(Icons.shopping_basket_outlined),
                label: const Text('Harvest'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _helperText(
    FarmPlot plot,
    PlotStatus status,
    bool canPlant,
    bool canWater,
  ) {
    return switch (status) {
      PlotStatus.locked => 'Upgrade the garden to open this plot.',
      PlotStatus.empty when !rules.isCropUnlocked(
        selectedCrop.id,
        state.farmLevel,
      ) =>
        '${selectedCrop.name} unlocks at level ${selectedCrop.unlockLevel}.',
      PlotStatus.empty when state.inventory.seeds < selectedCrop.seedCost =>
        'Buy a seed pack before planting.',
      PlotStatus.empty when canPlant =>
        'Plant ${selectedCrop.name} to begin this plot.',
      PlotStatus.empty => 'Choose an available seed for this plot.',
      PlotStatus.plantedDry when canWater =>
        'Water now to start the growth timer.',
      PlotStatus.plantedDry =>
        'Water refills over time. Come back shortly.',
      PlotStatus.growing =>
        'Ready in ${rules.remainingGrowth(plot, nowMs).inSeconds + 1}s.',
      PlotStatus.ready => 'Harvest this crop into the crate.',
    };
  }

  String _plotStatusText(
    FarmPlot plot,
    PlotStatus status,
    FarmRules rules,
    int nowMs,
  ) {
    return switch (status) {
      PlotStatus.locked => 'locked',
      PlotStatus.empty => 'empty',
      PlotStatus.plantedDry => 'needs water',
      PlotStatus.ready => 'ready',
      PlotStatus.growing =>
        'growing ${rules.remainingGrowth(plot, nowMs).inSeconds + 1}s',
    };
  }
}
