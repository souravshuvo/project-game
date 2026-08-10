import '../domain/farm_return_report.dart';
import '../domain/farm_state.dart';

class FarmLoadResult {
  const FarmLoadResult({required this.state, required this.returnReport});

  final FarmState state;
  final FarmReturnReport returnReport;
}
