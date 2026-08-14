# Signal Reef Launch Prep Plan

Last updated: 2026-08-10

## Goal

Prepare Signal Reef for internal and closed testing with production-safe ads and analytics configured carefully before any Play release.

## Decisions

- AdMob is implemented with test defaults and non-gameplay placements only.
- Firebase Analytics is implemented behind dart-define configuration; no real Firebase IDs are stored in source.
- Do not add Crashlytics until the Firebase project is created and a test crash can be verified.
- Use internal testing first, then closed testing, then production.

## Readiness Table

| Area | Status | Next Action |
| --- | --- | --- |
| App identity | Mostly prepared | Confirm package ID before first Play upload |
| Release signing | Config prepared | Create private keystore and `android/key.properties` |
| Store assets | Partially prepared | Regenerate icons/feature graphic; recapture real Signal Reef screenshots |
| Privacy/Data safety | Needs update | Include AdMob and any enabled Firebase Analytics collection |
| Analytics | Gated | Supply Firebase dart-defines and verify DebugView |
| Crash monitoring | Planned | Add Crashlytics after Firebase setup |
| Monetization | Implemented safely | Verify test ads, caps, and non-gameplay placements |
| Internal testing | Pending | Upload signed `.aab` to Play internal testing |
| Closed testing | Pending | Recruit testers and collect structured feedback |
| Production release | Pending | Only after stability, retention, and policy checks |

## Internal Test Exit Criteria

- Signed release `.aab` builds successfully.
- Fresh install works on at least one physical Android phone.
- No known launch-blocking crashes.
- Main menu, gameplay, pause, game over/win, retry, and best-score save work.
- Real Signal Reef screenshots and feature graphic are uploaded.
- Internal testers confirm movement and damage feedback are understandable.

## Next Steps

1. Configure Android release signing.
2. Generate launcher icons and feature graphic.
3. Build release `.aab`.
4. Install/test locally or through Play internal testing.
5. Capture real gameplay screenshots.
6. Complete Play App content declarations.
7. Verify AdMob test ads and Firebase Analytics DebugView, if analytics is enabled.
8. Run internal testing.
9. Review feedback and crash/performance notes.
10. Run closed testing.
11. Decide production release or next update.

## Official References

- Google Play App content: https://support.google.com/googleplay/android-developer/answer/9859455
- Play testing tracks: https://support.google.com/googleplay/android-developer/answer/9845334
- Firebase Crashlytics for Flutter: https://firebase.google.com/docs/crashlytics/flutter/get-started
