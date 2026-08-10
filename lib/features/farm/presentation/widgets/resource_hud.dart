import 'package:flutter/material.dart';

import '../../domain/farm_rules.dart';
import '../../domain/farm_state.dart';

class ResourceHud extends StatelessWidget {
  const ResourceHud({super.key, required this.state, required this.rules});

  final FarmState state;
  final FarmRules rules;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _ResourceChip(
          icon: Icons.paid_outlined,
          label: 'Coins',
          value: state.coins.toString(),
          color: const Color(0xFFB9821F),
        ),
        _ResourceChip(
          icon: Icons.spa_outlined,
          label: 'Seeds',
          value: state.inventory.seeds.toString(),
          color: const Color(0xFF497E35),
        ),
        _ResourceChip(
          icon: Icons.water_drop_outlined,
          label: 'Water',
          value: '${state.water}/${rules.waterCap(state.farmLevel)}',
          color: const Color(0xFF277997),
        ),
        _ResourceChip(
          icon: Icons.inventory_2_outlined,
          label: 'Crate',
          value: state.inventory.totalCrateItems.toString(),
          color: const Color(0xFF8A5C38),
        ),
      ],
    );
  }
}

class _ResourceChip extends StatelessWidget {
  const _ResourceChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 136),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0D5C4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
