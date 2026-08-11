import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rules')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _RuleTile(
            title: 'Board',
            body:
                'This prototype uses the approved 37-intersection board with 16 beads per player.',
          ),
          _RuleTile(
            title: 'Move',
            body:
                'Move one bead to an adjacent empty point connected by a board line.',
          ),
          _RuleTile(
            title: 'Capture',
            body:
                'Jump over one adjacent opponent bead and land on the empty point directly beyond it.',
          ),
          _RuleTile(
            title: 'Chains',
            body:
                'Multi-captures are allowed but optional. Only the bead that just captured may continue.',
          ),
          _RuleTile(
            title: 'Hint',
            body:
                'Hints preview one legal move or capture. They never move a bead for you.',
          ),
          _RuleTile(
            title: 'Undo',
            body:
                'Undo returns to the start of the previous completed turn before game over.',
          ),
          _RuleTile(
            title: 'Bot',
            body:
                'Bot matches are offline and use the same legal moves as local play.',
          ),
          _RuleTile(
            title: 'Win',
            body:
                'Win by capturing every opposing bead or by blocking the player whose turn is next.',
          ),
        ],
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  const _RuleTile({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(body),
        ],
      ),
    );
  }
}
