# V1 Launch Readiness Plan

Last updated: 2026-08-10

## Goal

Prepare Larder Labels for internal and closed testing without rushing SDKs, ads,
or production release before the app has real signing, screenshots, policy, and
test evidence.

## Current Decisions

- Keep v1 offline and privacy-light.
- Do not add Firebase, Crashlytics, AdMob, purchases, login, cloud sync, map
  progression, story, shop, skins, or live events.
- Use one simple triple-match puzzle mode.
- Use five deterministic local levels for first testing.
- Use internal testing first, then closed testing, then production only after
  blockers are resolved.

## Completion Map

| Area | Status | Next Gate |
| --- | --- | --- |
| Gameplay loop | Implemented | Run tests and manual QA |
| Level pack | Implemented | Tester difficulty review |
| Release identity | Updated | Confirm package is final |
| Store screenshots | Pending | Capture from real current gameplay |
| Launcher icons | Pending | Regenerate Larder Labels icons |
| Release signing | Pending | Create private keystore and wire Gradle |
| Analytics | Deferred | Add only after privacy decision |
| Crash monitoring | Deferred | Add only after real project/config |
| Monetization | Deferred | Add only after gameplay is stable |
| Internal testing | Pending | Upload signed `.aab` |
| Closed testing | Pending | Recruit testers and collect feedback |
| Production release | Pending | Only after stability and policy checks |

## Exit Criteria

- Package config is refreshed after package rename.
- Static analysis and tests pass.
- Signed release `.aab` builds successfully.
- Privacy policy is hosted and matches actual SDK behavior.
- Store screenshots and feature graphic show only real/current v1 content.
- Play Console app-content forms are complete.
- Internal test has no blocking crash or install issue.
- Closed test feedback does not show major correctness or fairness issues.

## Recommended Order

1. Refresh packages and run verification.
2. Regenerate launcher icons.
3. Configure Android release signing.
4. Build a signed internal-test `.aab`.
5. Capture current real gameplay screenshots.
6. Complete Play Console app-content forms.
7. Run internal testing.
8. Run closed testing.
9. Review feedback and decide production release or another small update.
