import 'farm_state.dart';

class FarmActionResult {
  const FarmActionResult({
    required this.state,
    required this.message,
    required this.changed,
  });

  final FarmState state;
  final String message;
  final bool changed;
}
