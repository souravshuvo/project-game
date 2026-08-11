# Monetization Plan

Last updated: 2026-08-11

## Current Decision

AdMob is implemented for a production-safe v1 monetization test.

The app defaults to Google test ads. Do not switch to production ad units until AdMob app IDs, privacy policy, Play Console Data safety, and manual ad QA are complete.

## Implemented Placements

- Banner: home screen bottom, placement `home_bottom`.
- Banner: level-complete screen, placement `level_complete`.
- Interstitial: only after tapping Continue on the level-complete screen, never during active puzzle play.
- Rewarded: optional one-hint reward from home and level-complete screens. The hint is granted only from the rewarded-ad completion callback, not from ad click or ad start.

## Frequency Caps

Interstitial ads are capped in `MobileGameAds`:

- Minimum level interval: every 4th cleared level only.
- Per-session cap: 5 interstitials.
- Cooldown: 2 minutes between interstitials.
- Per-level guard: at most one interstitial for the same level number.
- Failure behavior: load/show failure is logged and gameplay proceeds.

## Test And Production Separation

Default runtime:

- `ARROW_PUZZLE_ADS_ENV=test`
- Android AdMob app ID default: `ca-app-pub-3940256099942544~3347511713`
- iOS AdMob app ID default: `ca-app-pub-3940256099942544~1458002511`
- Google demo banner, interstitial, and rewarded unit IDs are used in test mode.

Production runtime requires:

- `--dart-define=ARROW_PUZZLE_ADS_ENV=production`
- `--dart-define=ADMOB_ANDROID_BANNER_UNIT_ID=...`
- `--dart-define=ADMOB_ANDROID_INTERSTITIAL_UNIT_ID=...`
- `--dart-define=ADMOB_ANDROID_REWARDED_UNIT_ID=...`
- iOS equivalents when iOS is in scope.
- Android Gradle property `ADMOB_ANDROID_APP_ID=...` for the real AdMob app ID.
- iOS `ADMOB_IOS_APP_ID=...` in xcconfig or CI build settings.

Use `--dart-define=ARROW_PUZZLE_ADS_ENABLED=false` to disable ads completely for QA builds.

## Production Gate

Before live ads:

- Verify Google demo ads show in an internal test build.
- Confirm no ads appear on the active puzzle screen.
- Confirm interstitials appear only from the level-complete Continue action.
- Confirm ad failure/offline mode still allows Continue, Replay, Level Select, and Home.
- Update hosted privacy policy, Play Console Data safety, and Ads declaration.
- Confirm target audience/child-directed settings before serving ads.

## Official References

- Google Mobile Ads Flutter setup: https://developers.google.com/admob/flutter/quick-start
- Flutter Google Mobile Ads cookbook: https://docs.flutter.dev/cookbook/plugins/google-mobile-ads
- Google Play App content declarations: https://support.google.com/googleplay/android-developer/answer/9859455
