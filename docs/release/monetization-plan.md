# Signal Reef Monetization Plan

Last updated: 2026-08-14

## Current Decision

AdMob is implemented for production-safe testing, with test ads as the default.

Current placements:

- Home banner: non-gameplay screen only.
- Result banner: after a run ends.
- Result interstitial: natural result transition only, never during active gameplay.

## Test And Production Separation

Default behavior uses Google Mobile Ads sample IDs:

- Android app ID fallback: configured through `admobApplicationId` in Gradle.
- iOS app ID fallback: configured through `GAD_APPLICATION_IDENTIFIER` in xcconfig.
- Runtime ad units default to Google test ad unit IDs.

Production ads require explicit build configuration:

- `SIGNAL_REEF_USE_PRODUCTION_ADS=true`
- `SIGNAL_REEF_ANDROID_BANNER_AD_UNIT_ID`
- `SIGNAL_REEF_ANDROID_INTERSTITIAL_AD_UNIT_ID`
- `SIGNAL_REEF_IOS_BANNER_AD_UNIT_ID`
- `SIGNAL_REEF_IOS_INTERSTITIAL_AD_UNIT_ID`
- Android Gradle property `ADMOB_ANDROID_APP_ID`
- iOS `GAD_APPLICATION_IDENTIFIER`

If production unit IDs are incomplete, runtime ad units fall back to test IDs.

## Frequency Caps

Interstitials:

- Only considered on the result screen.
- Never shown during active gameplay, ready state, pause menu, retry tap, or countdown.
- Minimum 3 completed runs between interstitial attempts.
- Minimum 2 minutes between shown interstitials.
- Failure to load or show is non-blocking.

Rewarded ads:

- Not implemented in the current version.
- Do not add rewarded revive until tester feedback confirms the core loop can support it.

## Analytics

Ad events are sent through the Signal Reef telemetry boundary:

- `ad_sdk_initialized`
- `ad_sdk_failed`
- `ad_load_start`
- `ad_loaded`
- `ad_load_failed`
- `ad_showed`
- `ad_dismissed`
- `ad_show_failed`
- `ad_skipped`

Each ad event includes placement and ad environment.

## Release Requirements

Before Play submission:

- Verify test ads on a physical device.
- Replace app IDs and ad unit IDs with real AdMob IDs.
- Add or verify Google UMP consent handling before serving live ads in regions that require consent.
- Confirm no live ads are used during development testing.
- Update Play Console Ads declaration.
- Update Data safety and privacy policy for Google Mobile Ads data collection.
- Confirm target audience and child-directed status before serving ads.

## Official References

- Google Mobile Ads Flutter setup: https://developers.google.com/admob/flutter/quick-start
- Flutter Google Mobile Ads cookbook: https://docs.flutter.dev/cookbook/plugins/google-mobile-ads
- Google Play App content declarations: https://support.google.com/googleplay/android-developer/answer/9859455
