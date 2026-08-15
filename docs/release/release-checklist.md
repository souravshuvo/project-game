# Release Checklist

Last updated: 2026-08-15

## Identity Lock

- [x] Runtime app title: `Weather Lab Sort`
- [x] Android application ID: `com.childhood.weatherlabsort`
- [x] iOS bundle ID: `com.childhood.weatherlabsort`
- [x] Android launcher label: `Weather Lab Sort`
- [x] iOS display name: `Weather Lab Sort`
- [x] Confirm `com.childhood.weatherlabsort` is final before first Play Console upload. Package names cannot be reused for a different app after publishing.

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
- [x] 50 handcrafted v1 levels.
- [x] Local progress, unlocks, best moves, and best stars.
- [x] Undo and restart.
- [x] Level validation logic and focused test coverage.
- [ ] Manual QA on small and large Android phones.
- [ ] Confirm Level 1 is understandable to a new player.
- [ ] Confirm all v1 levels are fair without hints or boosters.

## Store Assets

- [x] Regenerate Play 512 x 512 icon and iOS AppIcon PNGs for Weather Lab Sort.
- [x] Add Android Weather Lab runtime icon assets.
- [x] Create final phone screenshot upload candidates from real Weather Lab Sort UI.
- [x] Create feature graphic: 1024 x 500 PNG/JPEG, no alpha.
- [x] Create preview video production package.
- [ ] Capture real gameplay preview video and add approved YouTube URL.
- [ ] Final QA feature graphic in Play Console safe areas.
- [x] Review screenshot package for readable text/icons, no debug banners, no misleading text, and no old Arrow Puzzle UI.
- [x] Add alt text for screenshot package.

Final screenshot upload candidates are in `store_assets/screenshots/weather_lab_sort_phone/final_png/`. Do not upload the old `store_assets/screenshots/phone/` files or raw `source_png/` files. The widget capture helper writes source images with `SCREENSHOT_EXIT_AFTER_CAPTURE=true`, but Flutter reports `did not complete` because the process exits after capture; use `store_assets/screenshots/weather_lab_sort_phone/README.md` for exact commands and caveats.

## Play Console App Content

- [ ] Privacy policy hosted at public URL.
- [ ] Data safety form completed.
- [ ] Ads declaration completed as "Yes" for AdMob-enabled builds.
- [ ] Target audience selected.
- [ ] Content rating questionnaire completed.
- [ ] App access declaration completed; no login required.
- [ ] Store listing reviewed against metadata policy.

## Product Readiness

- [ ] Confirm the 50-level v1 pack is fair and readable in internal testing.
- [x] Add Firebase Analytics adapter with no-op fallback.
- [x] Add AdMob level-end interstitial path with test/prod separation.
- [ ] Add real Firebase config files and verify events in DebugView.
- [ ] Replace test AdMob app/ad unit IDs before production upload.
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
