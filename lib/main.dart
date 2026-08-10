import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/farm_loop_app.dart';
import 'features/farm/application/clock.dart';
import 'features/farm/data/farm_save_store.dart';
import 'features/farm/domain/farm_rules.dart';
import 'features/farm/domain/farm_simulation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const rules = FarmRules.mvp;
  const simulation = FarmSimulation(rules);
  const clock = SystemClock();
  final preferences = await SharedPreferences.getInstance();
  final saveStore = FarmSaveStore(
    preferences: preferences,
    rules: rules,
    simulation: simulation,
  );
  final load = await saveStore.load(nowMs: clock.nowMs);

  runApp(
    FarmLoopApp(
      rules: rules,
      simulation: simulation,
      saveStore: saveStore,
      initialState: load.state,
      returnReport: load.returnReport,
      clock: clock,
    ),
  );
}
