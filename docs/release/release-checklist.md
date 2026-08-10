# Release Checklist

Last updated: 2026-08-10

## Identity Lock

- [x] Runtime app title: `Weather Lab Sort`
- [x] Android application ID: `com.childhood.weatherlabsort`
- [x] iOS bundle ID: `com.childhood.weatherlabsort`
- [x] Android launcher label: `Weather Lab Sort`
- [x] iOS display name: `Weather Lab Sort`
- [ ] Confirm `com.childhood.weatherlabsort` is final before first Play Console upload. Package names cannot be reused for a different app after publishing.

## Build Readiness

- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Run `flutter build apk --debug`.
- [ ] Run `flutter build appbundle --release`.
- [ ] Configure real Android release signing. Current release config still uses debug signing.
- [ ] Confirm target API level meets current Google Play requirement before upload.
- [ ] Test on physical Android phone.
- [ ] Test fresh install after uninstalling older package IDs.

## Gameplay Readiness

- [x] One offline water-sort mode.
- [x] 10 handcrafted v1 levels.
- [x] Local progress, unlocks, best moves, and best stars.
- [x] Undo and restart.
- [x] Level validation logic and focused test coverage.
- [ ] Manual QA on small and large Android phones.
- [ ] Confirm Level 1 is understandable to a new player.
- [ ] Confirm all v1 levels are fair without hints or boosters.

## Store Assets

- [ ] Regenerate Weather Lab Sort launcher icons.
- [ ] Capture final phone screenshots from real Weather Lab Sort gameplay.
- [ ] Create feature graphic: 1024 x 500 PNG/JPEG, no alpha.
- [ ] Review screenshots for status bar cleanliness, no debug banners, no misleading text.
- [ ] Add alt text for uploaded screenshots.

Existing `store_assets/` files may be stale from the earlier Arrow Puzzle prototype and must not be uploaded until regenerated from the current app.

## Play Console App Content

- [ ] Privacy policy hosted at public URL.
- [ ] Data safety form completed.
- [ ] Ads declaration completed as "No" for the current build.
- [ ] Target audience selected.
- [ ] Content rating questionnaire completed.
- [ ] App access declaration completed; no login required.
- [ ] Store listing reviewed against metadata policy.

## Product Readiness

- [ ] Confirm first 10 levels are enough for internal testing.
- [x] Add no-op telemetry boundary for future analytics.
- [x] Keep ads and analytics SDKs out of v1.
- [ ] Confirm support email and developer website.
- [ ] Confirm app category and tags.

## Launch Prep

- [x] Add Android release signing notes.
- [x] Create crash monitoring rollout plan.
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
