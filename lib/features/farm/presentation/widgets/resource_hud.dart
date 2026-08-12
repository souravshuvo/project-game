import 'package:flutter/material.dart';

import '../../domain/farm_rules.dart';
import '../../domain/farm_state.dart';

class ResourceHud extends StatelessWidget {
  const ResourceHud({super.key, required this.state, required this.rules});

  final FarmState state;
  final FarmRules rules;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF324C2E), Color(0xFF6F5736)],
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, 6),
            color: Color(0x1F000000),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _ResourceChip(
              icon: Icons.paid_outlined,
              label: 'Coins',
              value: state.coins.toString(),
              color: const Color(0xFFE5B848),
            ),
            _ResourceChip(
              icon: Icons.spa_outlined,
              label: 'Seeds',
              value: state.inventory.seeds.toString(),
              color: const Color(0xFF9DCC66),
            ),
            _ResourceChip(
              icon: Icons.water_drop_outlined,
              label: 'Water',
              value: '${state.water}/${rules.waterCap(state.farmLevel)}',
              color: const Color(0xFF7BCBE0),
            ),
            _ResourceChip(
              icon: Icons.inventory_2_outlined,
              label: 'Crate',
              value: state.inventory.totalCrateItems.toString(),
              color: const Color(0xFFD6A16C),
            ),
          ],
        ),
      ),
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
      constraints: const BoxConstraints(minWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xEFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x44FFFFFF)),
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
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF4E4B3C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: Tween<double>(begin: 0.9, end: 1).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Text(
                    value,
                    key: ValueKey('$label-$value'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1F2F20),
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
