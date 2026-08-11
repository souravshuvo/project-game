# Release Checklist

Last updated: 2026-08-11

## Identity Lock

- [x] Android application ID uses the final production namespace.
- [x] Android application ID: `com.childhood.arrowpuzzle`
- [x] iOS bundle ID: `com.childhood.arrowpuzzle`
- [x] Android launcher label: `Arrow Puzzle`
- [x] iOS display name: `Arrow Puzzle`
- [ ] Confirm `com.childhood.arrowpuzzle` is final before first Play Console upload. Package names cannot be reused for a different app after publishing.

## Build Readiness

- [x] `flutter analyze`
- [x] `flutter test`
- [x] `flutter build apk --debug`
- [ ] `flutter build appbundle --release`
- [ ] Configure real Android release signing. Current release config still uses debug signing.
- [ ] Confirm target API level meets current Google Play requirement before upload.
- [ ] Test on physical Android phone.
- [ ] Test fresh install after uninstalling older package IDs.

## Store Assets

- [x] Launcher icons generated for Android and iOS.
- [x] Android splash background/mark added.
- [ ] Recapture final phone screenshots from the current 60-level build.
- [x] Create feature graphic: 1024 x 500 PNG/JPEG, no alpha.
- [x] Run `tool/generate_store_feature_graphic.ps1` and review `store_assets/feature_graphic/feature-graphic.png`.
- [ ] After installing on an emulator, run `tool/capture_store_screenshots.ps1` and review `store_assets/screenshots/phone/`.
- [ ] Review screenshots for status bar cleanliness, no debug banners, no misleading text, and current `0/60` progress copy.
- [ ] Confirm screenshot dimensions are Play-compatible before upload.
- [ ] Add alt text for uploaded screenshots.

## Play Console App Content

- [ ] Privacy policy hosted at public URL.
- [ ] Data safety form completed.
- [ ] Ads declaration completed.
- [ ] Target audience selected.
- [ ] Content rating questionnaire completed.
- [ ] App access declaration completed; no login required.
- [ ] Store listing reviewed against metadata policy.

## Product Readiness

- [ ] Confirm the 60-level v1 pack is enough for internal or closed testing.
- [x] Add no-op telemetry boundary for analytics fallback.
- [x] Add Firebase Analytics adapter behind runtime initialization.
- [x] Add optional rewarded hints without rewarding ad clicks.
- [x] Add production-safe AdMob placements outside active gameplay.
- [x] Add interstitial frequency caps before any level-transition interstitials.
- [ ] Configure real Firebase project and verify Analytics DebugView.
- [ ] Configure real AdMob production app/ad unit IDs before live ads.
- [ ] Confirm support email and developer website.
- [ ] Confirm app category and tags.

## Phase 6 Launch Prep

- [x] Add Android release signing example and secret ignore rules.
- [x] Create Firebase/crash monitoring rollout plan.
- [x] Create monetization plan.
- [x] Create closed testing plan.
- [x] Create post-test learning note template.
- [ ] Configure real Android release signing.
- [ ] Build signed release `.aab`.
- [ ] Upload internal testing release.
- [ ] Collect first tester feedback.

## Official References

- Google Play target API level requirements: https://developer.android.com/google/play/requirements/target-sdk
- Google Play App content page: https://support.google.com/googleplay/android-developer/answer/9859455
- Google Play preview assets: https://support.google.com/googleplay/android-developer/answer/9866151
