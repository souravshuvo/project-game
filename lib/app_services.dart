import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import 'features/trail_arena/data/local_save_store.dart';
import 'features/trail_arena/services/ad_mob_service.dart';
import 'features/trail_arena/services/analytics_sink.dart';

class AppServices {
  const AppServices({required this.analytics, required this.ads});

  final AnalyticsSink analytics;
  final AdMobService ads;

  static Future<AppServices> initialize() async {
    final analytics = await _initializeAnalytics();
    final ads = AdMobService(analytics: analytics, saveStore: LocalSaveStore());
    unawaited(ads.initialize());

    analytics.log('app_open', {
      'ads_enabled': 1,
      'ad_mode': AdMobConfig.modeName,
    });

    return AppServices(analytics: analytics, ads: ads);
  }

  static Future<AnalyticsSink> _initializeAnalytics() async {
    try {
      await Firebase.initializeApp();
      return FirebaseAnalyticsSink(FirebaseAnalytics.instance);
    } catch (_) {
      return const NoOpAnalyticsSink();
    }
  }
}
