import 'package:flutter/material.dart';

import '../../domain/models.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.history});

  final List<MatchRecord> history;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match History')),
      body: history.isEmpty
          ? const Center(child: Text('No completed matches yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final record = history[index];
                final difficulty = record.botDifficulty;
                return ListTile(
                  leading: const Icon(Icons.flag_rounded),
                  title: Text('${record.winner.label} won'),
                  subtitle: Text(
                    '${record.mode.label}'
                    '${difficulty == null ? '' : ' (${difficulty.label})'}'
                    ' - ${record.turnCount} turns'
                    ' - ${record.captureCount} captures',
                  ),
                  trailing: Text(
                    '${record.player1Beads}-${record.player2Beads}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                );
              },
            ),
    );
  }
}
