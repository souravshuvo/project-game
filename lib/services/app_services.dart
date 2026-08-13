import 'analytics_service.dart';
import 'ad_service.dart';

class AppServices {
  AppServices._() {
    analytics = GameAnalytics();
    ads = GameAdService(analytics);
  }

  static final AppServices instance = AppServices._();

  late final GameAnalytics analytics;
  late final GameAdService ads;

  Future<void> initialize() async {
    await Future.wait([
      analytics.initialize(),
      ads.initialize(),
    ]);
  }
}
