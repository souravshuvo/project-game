import 'package:flutter/material.dart';

import '../../domain/farm_rules.dart';
import '../../domain/farm_state.dart';
import '../../domain/upgrade_definition.dart';

class MarketPanel extends StatelessWidget {
  const MarketPanel({
    super.key,
    required this.state,
    required this.rules,
    required this.saving,
    required this.onSell,
    required this.onBuySeeds,
    required this.onUpgrade,
    required this.onSave,
  });

  final FarmState state;
  final FarmRules rules;
  final bool saving;
  final VoidCallback onSell;
  final VoidCallback onBuySeeds;
  final VoidCallback onUpgrade;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final nextUpgrade = rules.nextUpgrade(state.farmLevel);
    final sellValue = rules.crateSellValue(state.inventory);
    final canUpgrade = nextUpgrade != null && state.coins >= nextUpgrade.cost;
    final helperText = _helperText(sellValue, nextUpgrade, canUpgrade);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0D5C4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_outlined, color: Color(0xFF72522D)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Garden level ${state.farmLevel} / ${rules.unlockedPlotCount(state.farmLevel)} plots',
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
              OutlinedButton.icon(
                onPressed: state.inventory.hasCrateItems ? onSell : null,
                icon: const Icon(Icons.sell_outlined),
                label: Text('Sell +$sellValue'),
              ),
              OutlinedButton.icon(
                onPressed: state.coins >= rules.seedPackCost
                    ? onBuySeeds
                    : null,
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: Text('Seeds ${rules.seedPackCost}'),
              ),
              OutlinedButton.icon(
                onPressed: canUpgrade ? onUpgrade : null,
                icon: const Icon(Icons.upgrade_outlined),
                label: Text(
                  nextUpgrade == null
                      ? 'Max Level'
                      : 'Upgrade ${nextUpgrade.cost}',
                ),
              ),
              OutlinedButton.icon(
                onPressed: saving ? null : onSave,
                icon: saving
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(saving ? 'Saving' : 'Save'),
              ),
            ],
          ),
          if (nextUpgrade != null) ...[
            const SizedBox(height: 10),
            Text(
              nextUpgrade.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  String _helperText(
    int sellValue,
    UpgradeDefinition? nextUpgrade,
    bool canUpgrade,
  ) {
    if (state.inventory.hasCrateItems) {
      return 'Sell the crate for $sellValue coins.';
    }
    if (nextUpgrade == null) {
      return 'Garden level ${state.farmLevel} is complete for version 1.';
    }
    if (canUpgrade) {
      return 'Upgrade now to open more plots and crops.';
    }
    return 'Harvest, sell, then save up ${nextUpgrade.cost} coins for the next upgrade.';
  }
}
