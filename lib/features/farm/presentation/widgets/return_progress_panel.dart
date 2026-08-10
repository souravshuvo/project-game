import 'package:flutter/material.dart';

import '../../domain/farm_return_report.dart';

class ReturnProgressPanel extends StatelessWidget {
  const ReturnProgressPanel({
    super.key,
    required this.report,
    required this.onDismiss,
  });

  final FarmReturnReport report;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (report.saveWasReset) 'Fresh save started',
      if (report.readyPlots > 0) '${report.readyPlots} ready',
      if (report.waterRestored > 0) '+${report.waterRestored} water',
      if (report.awaySeconds >= 6) 'Away ${report.awaySeconds}s',
      if (report.wasCapped) 'Progress capped',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2CC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE4BF62)),
      ),
      child: Row(
        children: [
          const Icon(Icons.history_toggle_off, color: Color(0xFF8A5C12)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              parts.join(' / '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
            tooltip: 'Dismiss',
            onPressed: onDismiss,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
