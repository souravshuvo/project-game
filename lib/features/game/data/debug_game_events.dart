import 'package:flutter/foundation.dart';

void debugGameEventSink(String name, Map<String, Object?> properties) {
  assert(() {
    debugPrint('game_event $name $properties');
    return true;
  }());
}
