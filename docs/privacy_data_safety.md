# Privacy and Data Safety Notes

Cloud Courier Climb now has production-safe integration points for Google Mobile Ads and Firebase Analytics. The app must still be reviewed in Play Console before publishing because the actual disclosure depends on the final Firebase and AdMob account settings.

## Current ad placements

- Rewarded ad: optional revive from the game-over screen only.
- Interstitial ad: game-over transition only, capped to every fourth completed run after at least two runs, with a three-minute minimum gap.
- No ads are requested or shown during active gameplay.

## Test and production separation

- Dart ad unit IDs default to Google's AdMob test IDs.
- Production ad unit IDs require `--dart-define=USE_PRODUCTION_ADS=true` plus platform-specific `ADMOB_*` unit IDs.
- Android app ID defaults to Google's test app ID and may be overridden with the `ADMOB_ANDROID_APP_ID` Gradle property.
- iOS app ID is read from `GAD_APPLICATION_IDENTIFIER` in xcconfig, currently set to Google's test app ID.

## Analytics events

Firebase Analytics events cover app readiness, run start/end, route completion, pause/resume/home/help/settings, feedback setting changes, interstitial outcomes, and rewarded revive outcomes.

## Play Data safety review

Before release, review and disclose any data collected by Firebase Analytics and Google Mobile Ads, including app interactions, diagnostics, device identifiers, advertising identifiers, and approximate location if enabled by Google services or consent configuration.

## Production checklist

- Add real Firebase app config files for Android and iOS.
- Add a privacy policy URL before store submission.
- Configure consent handling if targeting regions or users that require consent.
- Register test devices before QA with live SDKs.
- Confirm production AdMob IDs are not committed directly unless the release process explicitly allows it.
