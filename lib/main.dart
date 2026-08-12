import 'package:flutter/material.dart';

import 'app/game_services.dart';
import 'app/magnetic_marbles_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await GameServices.initialize();
  runApp(MagneticMarblesApp(services: services));
}
