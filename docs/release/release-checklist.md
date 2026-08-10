# Signal Reef Release Checklist

Last updated: 2026-08-10

## Identity Lock

- [x] Android application ID uses the intended Signal Reef namespace.
- [x] Android application ID: `com.childhood.signalreef`
- [x] iOS bundle ID: `com.childhood.signalreef`
- [x] Android launcher label: `Signal Reef`
- [x] iOS display name: `Signal Reef`
- [ ] Confirm `com.childhood.signalreef` is final before first Play Console upload. Package names cannot be reused for a different app after publishing.

## Build Readiness

- [x] `flutter analyze`
- [x] `flutter test`
- [ ] `flutter build appbundle --release`
- [ ] Add real `android/key.properties` and private upload keystore.
- [ ] Confirm release build uses upload signing, not debug fallback.
- [x] Current Flutter SDK defaults target Android API 36.
- [ ] Test on physical Android phone.
- [ ] Test fresh install after uninstalling older package IDs.

## Store Assets

- [x] Signal Reef launcher icon generator updated.
- [x] Android splash mark updated.
- [x] Feature graphic generator updated for Signal Reef.
- [ ] Run `tool/generate_phase4_assets.ps1` and review generated launcher icons.
- [ ] Run `tool/generate_store_feature_graphic.ps1` and review `store_assets/feature_graphic/feature-graphic.png`.
- [ ] Install the app on an emulator/device and run `tool/capture_store_screenshots.ps1`.
- [ ] Capture and review real Signal Reef gameplay screenshots.
- [ ] Review screenshots for no debug banners, no misleading content, and real implemented gameplay only.
- [ ] Add alt text for uploaded screenshots.

## Play Console App Content

- [ ] Privacy policy hosted at public URL.
- [ ] Data safety form completed.
- [ ] Ads declaration completed.
- [ ] Target audience selected.
- [ ] Content rating questionnaire completed.
- [ ] App access declaration completed; no login required.
- [ ] Store listing reviewed against metadata and misleading-claims policies.

## Product Readiness

- [x] First playable prototype exists: 3 waves, player, enemies, bullets, score, hull, pause/retry/result.
- [ ] Complete feel pass: drag offset, hit flash, bounce spark, damage feedback.
- [ ] Run internal test with 5-10 real players.
- [ ] Fill `docs/release/post-test-learning-note.md`.
- [ ] Decide whether analytics/crash reporting is needed after internal test.
- [ ] Confirm support email and developer website.
- [ ] Confirm app category and tags.

## Track Order

1. Local QA.
2. Play internal testing.
3. Closed testing.
4. Production only after internal/closed issues are resolved.

## Official References

- Google Play target API level requirements: https://developer.android.com/google/play/requirements/target-sdk
- Google Play App content page: https://support.google.com/googleplay/android-developer/answer/9859455
- Google Play preview assets: https://support.google.com/googleplay/android-developer/answer/9866151
