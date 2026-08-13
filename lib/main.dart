import 'dart:async';

import 'package:flutter/material.dart';

import 'app/game_app.dart';
import 'services/ads_gateway.dart';
import 'services/analytics_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(AnalyticsService.initialize());
  unawaited(AdsGateway.initialize());
  runApp(const GameApp());
}
