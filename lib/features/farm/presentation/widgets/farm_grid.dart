import 'package:flutter/material.dart';

import '../../domain/farm_plot.dart';
import '../../domain/farm_rules.dart';
import '../../domain/farm_state.dart';

class FarmGrid extends StatelessWidget {
  const FarmGrid({
    super.key,
    required this.state,
    required this.rules,
    required this.selectedPlot,
    required this.nowMs,
    required this.onSelect,
  });

  final FarmState state;
  final FarmRules rules;
  final int selectedPlot;
  final int nowMs;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rules.plotCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final unlocked = rules.isPlotUnlocked(state, index);
          return _PlotTile(
            state: state,
            rules: rules,
            index: index,
            nowMs: nowMs,
            unlocked: unlocked,
            selected: selectedPlot == index,
            onTap: unlocked ? () => onSelect(index) : null,
          );
        },
      ),
    );
  }
}

class _PlotTile extends StatelessWidget {
  const _PlotTile({
    required this.state,
    required this.rules,
    required this.index,
    required this.nowMs,
    required this.unlocked,
    required this.selected,
    required this.onTap,
  });

  final FarmState state;
  final FarmRules rules;
  final int index;
  final int nowMs;
  final bool unlocked;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = _PlotVisuals.from(state, rules, index, nowMs);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: style.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? const Color(0xFF263D2A)
                  : const Color(0xFFB49A78),
              width: selected ? 3 : 1.4,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      blurRadius: 12,
                      offset: Offset(0, 4),
                      color: Color(0x1F000000),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(style.icon, color: style.iconColor, size: 36),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  style.label,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: style.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Plot ${index + 1}',
                  maxLines: 1,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: style.textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlotVisuals {
  const _PlotVisuals({
    required this.background,
    required this.iconColor,
    required this.textColor,
    required this.icon,
    required this.label,
  });

  final Color background;
  final Color iconColor;
  final Color textColor;
  final IconData icon;
  final String label;

  factory _PlotVisuals.from(
    FarmState state,
    FarmRules rules,
    int index,
    int nowMs,
  ) {
    final status = rules.plotStatus(state, index, nowMs);
    final plot = state.plots[index];
    final cropName = plot.cropId == null
        ? null
        : rules.cropById(plot.cropId!).name;

    return switch (status) {
      PlotStatus.locked => const _PlotVisuals(
        background: Color(0xFFE7E0D4),
        iconColor: Color(0xFF7A6B58),
        textColor: Color(0xFF6A5E4D),
        icon: Icons.lock_outline,
        label: 'Locked',
      ),
      PlotStatus.empty => const _PlotVisuals(
        background: Color(0xFFF2D8B8),
        iconColor: Color(0xFF8A5C38),
        textColor: Color(0xFF4C3626),
        icon: Icons.add_circle_outline,
        label: 'Empty',
      ),
      PlotStatus.plantedDry => _PlotVisuals(
        background: const Color(0xFFD5B27F),
        iconColor: const Color(0xFF49692E),
        textColor: const Color(0xFF3A2B1E),
        icon: Icons.spa_outlined,
        label: cropName ?? 'Dry',
      ),
      PlotStatus.growing => _PlotVisuals(
        background: const Color(0xFFBFD8B8),
        iconColor: const Color(0xFF24705A),
        textColor: const Color(0xFF183F35),
        icon: Icons.grass_outlined,
        label: '${rules.remainingGrowth(plot, nowMs).inSeconds + 1}s',
      ),
      PlotStatus.ready => _PlotVisuals(
        background: const Color(0xFFCBE7A2),
        iconColor: const Color(0xFF256D38),
        textColor: const Color(0xFF183F23),
        icon: Icons.eco_outlined,
        label: 'Ready',
      ),
    };
  }
}
