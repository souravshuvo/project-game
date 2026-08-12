import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerSettings extends ChangeNotifier {
  PlayerSettings({required SharedPreferences preferences})
    : _preferences = preferences,
      _soundEnabled = preferences.getBool(_soundKey) ?? true,
      _hapticsEnabled = preferences.getBool(_hapticsKey) ?? true,
      _showHints = preferences.getBool(_showHintsKey) ?? true;

  static const _soundKey = 'player_settings_sound_enabled';
  static const _hapticsKey = 'player_settings_haptics_enabled';
  static const _showHintsKey = 'player_settings_show_hints';

  final SharedPreferences _preferences;

  bool _soundEnabled;
  bool _hapticsEnabled;
  bool _showHints;

  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get showHints => _showHints;

  Future<void> setSoundEnabled(bool value) async {
    if (_soundEnabled == value) {
      return;
    }
    _soundEnabled = value;
    notifyListeners();
    await _preferences.setBool(_soundKey, value);
  }

  Future<void> setHapticsEnabled(bool value) async {
    if (_hapticsEnabled == value) {
      return;
    }
    _hapticsEnabled = value;
    notifyListeners();
    await _preferences.setBool(_hapticsKey, value);
  }

  Future<void> setShowHints(bool value) async {
    if (_showHints == value) {
      return;
    }
    _showHints = value;
    notifyListeners();
    await _preferences.setBool(_showHintsKey, value);
  }
}
