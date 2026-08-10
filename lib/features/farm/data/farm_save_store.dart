import 'package:shared_preferences/shared_preferences.dart';

import '../domain/farm_return_report.dart';
import '../domain/farm_rules.dart';
import '../domain/farm_simulation.dart';
import '../domain/farm_state.dart';
import 'farm_load_result.dart';
import 'farm_save_codec.dart';

class FarmSaveStore {
  FarmSaveStore({
    required this.preferences,
    required this.rules,
    required this.simulation,
  }) : codec = FarmSaveCodec(rules);

  static const saveKey = 'farm_loop_save_v1';

  final SharedPreferences preferences;
  final FarmRules rules;
  final FarmSimulation simulation;
  final FarmSaveCodec codec;

  Future<FarmLoadResult> load({required int nowMs}) async {
    final raw = preferences.getString(saveKey);
    if (raw == null) {
      return FarmLoadResult(
        state: rules.initialState(nowMs),
        returnReport: const FarmReturnReport(),
      );
    }

    try {
      final restored = codec.decode(raw, nowMs: nowMs);
      final offline = simulation.applyOfflineProgress(restored, nowMs);
      return FarmLoadResult(state: offline.state, returnReport: offline.report);
    } on FormatException {
      return FarmLoadResult(
        state: rules.initialState(nowMs),
        returnReport: const FarmReturnReport(saveWasReset: true),
      );
    } on StateError {
      return FarmLoadResult(
        state: rules.initialState(nowMs),
        returnReport: const FarmReturnReport(saveWasReset: true),
      );
    }
  }

  Future<void> save(FarmState state) {
    return preferences.setString(saveKey, codec.encode(state));
  }
}
