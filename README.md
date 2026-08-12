# Dew Bubble Garden

Offline-first Flutter bubble shooter for the Childhood game collection.

## Monetization and Analytics

AdMob and Firebase Analytics are wired for production-safe rollout, but release
credentials are not committed.

- Ads are limited to interstitials at level-result transitions only.
- Ads never show during active aiming, shooting, or bubble resolution.
- Interstitials have a 3 completed-level-result and 3 minute frequency cap.
- Ad requests are configured as child-directed, max rating G, and
  non-personalized.
- Test ad units are used by default.
- Production ad unit IDs must be supplied with dart defines before release:
  `ADMOB_USE_TEST_ADS=false`,
  `ADMOB_ANDROID_INTERSTITIAL_ID=...`, and
  `ADMOB_IOS_INTERSTITIAL_ID=...`.
- Android uses the Google test AdMob app ID by default. Supply the production
  app ID with the Gradle property `-PadmobApplicationId=...` for release.
- iOS uses the Google test AdMob app ID in `ios/Flutter/*.xcconfig`; replace
  `GAD_APPLICATION_IDENTIFIER` with the production app ID before release.
- Firebase Analytics logs aggregate gameplay, difficulty, retention, and ad
  lifecycle events only. The app does not set user IDs or create child profiles.
- Analytics can be disabled with `ANALYTICS_ENABLED=false`.

## Release Config Still Needed

- Run dependency resolution after approving network/package changes.
- Add real Firebase configuration files with FlutterFire before analytics
  verification.
- Replace AdMob app IDs in Android/iOS release configuration before production
  upload.
- Verify Data safety answers for ads, analytics, approximate device identifiers
  collected by SDKs, and child-directed treatment.
