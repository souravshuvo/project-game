import 'package:flutter/material.dart';

import 'features/signal_reef/application/signal_reef_controller.dart';
import 'features/signal_reef/application/signal_reef_telemetry.dart';
import 'features/signal_reef/data/signal_reef_save_store.dart';
import 'features/signal_reef/domain/save_data.dart';
import 'features/signal_reef/presentation/pages/signal_reef_home_page.dart';
import 'features/signal_reef/presentation/pages/signal_reef_play_page.dart';
import 'features/signal_reef/presentation/pages/signal_reef_result_page.dart';
import 'features/signal_reef/presentation/pages/signal_reef_settings_page.dart';
import 'features/signal_reef/presentation/theme/signal_reef_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final saveStore = SharedPreferencesSignalReefSaveStore();
  final initialSave = await saveStore.load();

  runApp(SignalReefApp(saveStore: saveStore, initialSave: initialSave));
}

class SignalReefApp extends StatefulWidget {
  const SignalReefApp({
    super.key,
    required this.saveStore,
    required this.initialSave,
  });

  final SignalReefSaveStore saveStore;
  final SignalReefSaveData initialSave;

  @override
  State<SignalReefApp> createState() => _SignalReefAppState();
}

class _SignalReefAppState extends State<SignalReefApp> {
  late final SignalReefController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignalReefController(
      saveStore: widget.saveStore,
      initialSave: widget.initialSave,
      telemetry: const NoOpSignalReefTelemetry(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'Signal Reef',
          debugShowCheckedModeBanner: false,
          theme: SignalReefTheme.dark(),
          home: _buildHome(),
        );
      },
    );
  }

  Widget _buildHome() {
    return switch (_controller.screen) {
      SignalReefScreen.home => SignalReefHomePage(controller: _controller),
      SignalReefScreen.settings => SignalReefSettingsPage(
        controller: _controller,
      ),
      SignalReefScreen.playing => SignalReefPlayPage(controller: _controller),
      SignalReefScreen.result => SignalReefResultPage(controller: _controller),
    };
  }
}
