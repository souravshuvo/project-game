# Phase 6 Launch Plan

Last updated: 2026-08-02

## Goal

Prepare Arrow Puzzle for internal and closed testing without rushing SDKs, ads, or production release before the app has real account/config values.

## Current Phase 6 Decisions

- Keep the current build privacy-light: no network SDKs yet.
- Add a no-op telemetry boundary in code so Firebase Analytics can be connected later without changing gameplay logic.
- Do not add Crashlytics until the Firebase project is created and `flutterfire configure` can be run with the real app IDs.
- Do not add AdMob until the monetization decision is final and real test ad flow is verified.
- Use internal testing first, then closed testing, then production.

## Completion Map

| Area | Status | Next Gate |
| --- | --- | --- |
| Release signing | Prepared | Create private keystore and wire Gradle release signing |
| Analytics events | Prepared | Add Firebase Analytics adapter after Firebase setup |
| Crash monitoring | Planned | Add Crashlytics after Firebase setup |
| Monetization | Planned | Choose no ads, rewarded hints, interstitials, or IAP |
| Internal testing | Pending | Upload signed `.aab` to Play internal testing |
| Closed testing | Pending | Recruit testers and collect structured feedback |
| Production release | Pending | Only after stability, retention, and policy checks |
| Monitoring loop | Planned | Review crashes, funnel, retention, ratings, and revenue weekly |

## Phase 6 Exit Criteria

- Signed release `.aab` builds successfully.
- Privacy policy is hosted and matches actual SDK behavior.
- Firebase/Crashlytics decision is either implemented or explicitly deferred.
- Monetization decision is recorded.
- Internal test release is available to testers.
- Closed testing plan has tester list, tasks, and feedback form.
- Learning note is filled after first tester feedback.

## Recommended Order

1. Configure Android release signing.
2. Build release `.aab`.
3. Create Firebase project only if analytics/crash monitoring is approved.
4. Create AdMob app only if ads are approved.
5. Complete Play Console app content forms.
6. Run internal testing.
7. Run closed testing.
8. Review data and human feedback.
9. Decide production release or next update.

## Official References

- Firebase Flutter setup: https://firebase.google.com/docs/flutter/setup
- Firebase Crashlytics for Flutter: https://firebase.google.com/docs/crashlytics/flutter/get-started
- Google Mobile Ads Flutter setup: https://developers.google.com/admob/flutter/quick-start
- Play testing tracks: https://support.google.com/googleplay/android-developer/answer/9845334
