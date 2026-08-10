# Release Checklist

Last updated: 2026-08-10

## Identity Lock

- [x] App title: `Larder Labels`
- [x] Flutter package name: `larder_labels`
- [x] Android application ID: `com.childhood.larderlabels`
- [x] iOS bundle ID: `com.childhood.larderlabels`
- [x] Android launcher label: `Larder Labels`
- [x] iOS display name: `Larder Labels`
- [ ] Confirm `com.childhood.larderlabels` is final before first Play Console
      upload. Package names cannot be reused for a different app after
      publishing.

## Build Readiness

- [ ] Refresh lockfile and package config after the package rename and
      dependency cleanup.
- [ ] Run formatter after final code edits.
- [ ] Run static analysis.
- [ ] Run unit/widget tests.
- [ ] Build debug APK for smoke testing.
- [ ] Configure real Android release signing. Current release config is
      intentionally unsigned.
- [ ] Build signed release `.aab`.
- [ ] Test on a physical Android phone.
- [ ] Test fresh install after uninstalling older package IDs.
- [ ] Confirm target API level meets the current Google Play requirement before
      upload.

## Store Assets

- [ ] Regenerate Android, iOS, and web launcher icons for Larder Labels.
- [x] Replace Android splash mark with label-tile artwork.
- [ ] Capture final phone screenshots from real Larder Labels gameplay.
- [ ] Create/review feature graphic with only available v1 content.
- [ ] Review screenshots for status bar cleanliness, no debug banners, no
      misleading text, and no removed legacy-game visuals.
- [ ] Add alt text for uploaded screenshots.

## Product Readiness

- [x] One simple offline puzzle mode.
- [x] Five deterministic local levels.
- [x] Pure puzzle engine separated from Flutter UI.
- [x] Tray capacity, triple clearing, covered-tile blocking, win, fail, restart,
      and session-only next-level flow implemented.
- [x] Focused tests added for engine and controller behavior.
- [ ] Run tests after package config is refreshed.
- [ ] Review level difficulty with at least a small tester group.
- [ ] Confirm support email and developer website.
- [ ] Confirm app category and tags.

## Play Console App Content

- [ ] Privacy policy hosted at a stable public URL.
- [ ] Data safety form completed to match actual SDK behavior.
- [ ] Ads declaration completed. Current v1 should declare no ads.
- [ ] Target audience selected.
- [ ] Content rating questionnaire completed.
- [ ] App access declaration completed; no login required.
- [ ] Store listing reviewed against metadata and misleading-claims policies.

## Do Not Ship Until Fixed

- [ ] Any removed legacy-game screenshots/icons remain in store upload assets.
- [ ] Release signing is still unconfigured.
- [ ] Build, analyze, and tests have not been run after the package rename.
- [ ] Screenshots are not captured from actual current gameplay.

## Recommended Track

Use internal testing first. Move to closed testing only after the build,
screenshots, signing, privacy policy, and Play Console app-content checks are
complete.
