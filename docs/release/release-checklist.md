# Production V1 Release Checklist

Last updated: 2026-08-12

## Identity Lock

- [x] App name: `Tik Tak Toe`
- [x] Android launcher label: `Tik Tak Toe`
- [x] iOS display name: `Tik Tak Toe`
- [x] Android application ID: `com.childhood.tiktaktoe`
- [x] Android namespace: `com.childhood.tiktaktoe`
- [x] iOS bundle ID: `com.childhood.tiktaktoe`
- [ ] Confirm this package/bundle ID is final before the first Play Console upload. Package names cannot be reused for a different app after publishing.

## Build Readiness

- [ ] Run `dart format` after final edits.
- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Run `flutter pub get` after AdMob/Firebase dependency changes.
- [ ] Build signed release `.aab`.
- [ ] Install and smoke-test release build on a physical Android phone.
- [ ] Confirm Android SDK platform 36 is installed locally.
- [x] Target SDK configured for API 36.
- [x] Release build no longer falls back to debug signing.
- [ ] Configure real Android upload keystore in local `android/key.properties`.

## Gameplay Readiness

- [x] 3x3 board.
- [x] Local two-player mode.
- [x] One balanced AI difficulty.
- [x] Win and draw detection.
- [x] Restart/rematch.
- [x] Current-session score.
- [x] Basic sound and vibration settings.
- [x] Invalid move state has repeatable feedback sequencing.
- [x] Board has safer narrow-screen sizing.
- [x] Cell semantics include row and column.
- [ ] Manual device QA pass.
- [ ] Large text accessibility pass.

## Store Assets

- [x] Asset generation scripts updated for Tik Tak Toe.
- [x] Regenerate launcher icons with `tool/generate_phase4_assets.ps1`.
- [ ] Regenerate feature graphic with `tool/generate_store_feature_graphic.ps1`.
- [ ] Capture real gameplay screenshots with `tool/capture_store_screenshots.ps1`.
- [ ] Review screenshots for actual shipped gameplay only.
- [ ] Add alt text for uploaded screenshots and feature graphic.
- [ ] Do not upload old Arrow Puzzle screenshots or feature graphics.

## Play Console App Content

- [ ] Privacy policy hosted at a public URL.
- [ ] Data safety form completed for Google Mobile Ads and Firebase Analytics if enabled.
- [ ] Ads declaration completed: yes if AdMob remains enabled.
- [ ] App access declaration completed: no login required.
- [ ] Target audience selected.
- [ ] Content rating questionnaire completed.
- [ ] Store listing reviewed against metadata and misleading-claims policy.

## Product Readiness

- [ ] Decide whether to remove unused legacy Arrow Puzzle code before final source freeze.
- [ ] Confirm support email.
- [ ] Confirm developer website or support page.
- [ ] Confirm category: Game / Board or Game / Puzzle.
- [ ] Run internal test before any closed test.
- [ ] Run closed test before production release.

## Do Not Add In V1

- Banner ads
- Rewarded ads
- More aggressive interstitial placements
- Online multiplayer
- Login or cloud sync
- Leaderboards
- Shop, skins, or purchases
- Extra board sizes
- Timed turns
- Tournament mode
