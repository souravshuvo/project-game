# Phase 6 Launch Plan

Last updated: 2026-08-14

## Goal

Prepare Weather Lab Sort for internal and closed testing with production-safe ads and analytics plumbing, while blocking production release until real account/config values are verified.

## Current Phase 6 Decisions

- Keep ads out of active gameplay.
- Use capped, non-personalized level-end interstitials only.
- Use official test ads by default and require real production IDs before production upload.
- Use Firebase Analytics through the game telemetry boundary, with a no-op fallback for tests.
- Do not add Crashlytics until the Firebase project is created, release handlers are added, and a test crash can be verified.
- Use internal testing first, then closed testing, then production.

## Completion Map

| Area | Status | Next Gate |
| --- | --- | --- |
| Release signing | Prepared | Create private keystore and wire Gradle release signing |
| Analytics events | SDK adapter added | Add real Firebase config and verify DebugView |
| Crash monitoring | Planned | Add Crashlytics after Firebase setup |
| Monetization | SDK path added | Replace test AdMob IDs and verify test/live separation |
| Internal testing | Pending | Upload signed `.aab` to Play internal testing |
| Closed testing | Pending | Recruit testers and collect structured feedback |
| Production release | Pending | Only after stability, retention, and policy checks |
| Monitoring loop | Planned | Review crashes, funnel, retention, ratings, and revenue weekly |

## Phase 6 Exit Criteria

- Signed release `.aab` builds successfully.
- Privacy policy is hosted and matches actual SDK behavior.
- Firebase Analytics is configured or explicitly disabled for the test build.
- Crashlytics is either implemented or explicitly deferred.
- Monetization behavior is configured with test ads or explicitly disabled for the test build.
- Internal test release is available to testers.
- Closed testing plan has tester list, tasks, and feedback form.
- Learning note is filled after first tester feedback.

## Recommended Order

1. Configure Android release signing.
2. Build release `.aab`.
3. Create Firebase project and run `flutterfire configure` for package `com.childhood.weatherlabsort`.
4. Create AdMob app and replace sample IDs only after test ads are verified.
5. Complete Play Console app content, Ads, and Data safety forms.
6. Run internal testing.
7. Run closed testing.
8. Review data, ad impact, crashes, and human feedback.
9. Decide production release or next update.

## Official References

- Firebase Flutter setup: https://firebase.google.com/docs/flutter/setup
- Firebase Crashlytics for Flutter: https://firebase.google.com/docs/crashlytics/flutter/get-started
- Google Mobile Ads Flutter setup: https://developers.google.com/admob/flutter/quick-start
- Play testing tracks: https://support.google.com/googleplay/android-developer/answer/9845334
