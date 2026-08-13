import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rules')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sixteen Breed',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Offline Sholo Guti / 16 Beads on a validated 37-point board.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              const _RuleLine(
                icon: Icons.group_rounded,
                text: 'Each player starts with 16 beads.',
              ),
              const _RuleLine(
                icon: Icons.radio_button_checked_rounded,
                text: 'Green highlighted points are normal moves.',
              ),
              const _RuleLine(
                icon: Icons.bolt_rounded,
                text:
                    'Amber highlighted jumps capture by leaping over one '
                    'opponent bead.',
              ),
              const _RuleLine(
                icon: Icons.check_rounded,
                text:
                    'Captures and multi-captures are optional in this version.',
              ),
              const _RuleLine(
                icon: Icons.swap_vert_rounded,
                text: 'Backward moves and captures are allowed.',
              ),
              const _RuleLine(
                icon: Icons.emoji_events_rounded,
                text:
                    'Win by capturing all opponent beads or blocking the '
                    'opponent.',
              ),
              const _RuleLine(
                icon: Icons.smart_toy_rounded,
                text:
                    'Player vs Bot uses the same legal move and capture rules.',
              ),
              const SizedBox(height: 12),
              const _HighlightLegend(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuleLine extends StatelessWidget {
  const _RuleLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class _HighlightLegend extends StatelessWidget {
  const _HighlightLegend();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegendRow(color: Color(0xFF2E7D32), text: 'Move target'),
            SizedBox(height: 10),
            _LegendRow(color: Color(0xFFC77800), text: 'Capture target'),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black26),
          ),
        ),
        const SizedBox(width: 10),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
