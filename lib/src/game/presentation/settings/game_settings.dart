import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class GameSettingsController extends ChangeNotifier {
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;

  void setSoundEnabled(bool value) {
    if (_soundEnabled == value) {
      return;
    }
    _soundEnabled = value;
    notifyListeners();
  }

  void setHapticsEnabled(bool value) {
    if (_hapticsEnabled == value) {
      return;
    }
    _hapticsEnabled = value;
    notifyListeners();
  }
}

class GameSettingsScope extends InheritedNotifier<GameSettingsController> {
  const GameSettingsScope({
    super.key,
    required GameSettingsController controller,
    required super.child,
  }) : super(notifier: controller);

  static GameSettingsController watch(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<GameSettingsScope>();
    assert(scope != null, 'GameSettingsScope is missing from the widget tree.');
    return scope!.notifier!;
  }

  static GameSettingsController read(BuildContext context) {
    final inherited = context
        .getElementForInheritedWidgetOfExactType<GameSettingsScope>()
        ?.widget;
    final scope = inherited as GameSettingsScope?;
    assert(scope != null, 'GameSettingsScope is missing from the widget tree.');
    return scope!.notifier!;
  }
}
