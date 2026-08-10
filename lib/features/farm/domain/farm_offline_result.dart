import 'farm_return_report.dart';
import 'farm_state.dart';

class FarmOfflineResult {
  const FarmOfflineResult({required this.state, required this.report});

  final FarmState state;
  final FarmReturnReport report;
}
