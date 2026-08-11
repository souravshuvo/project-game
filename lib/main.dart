import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/game/domain/board_validator.dart';

void main() {
  BoardValidator.validate().throwIfInvalid();
  runApp(const SholoGutiApp());
}
