# Production V1 Launch Plan

Last updated: 2026-08-12

## Goal

Prepare Tik Tak Toe for internal and closed testing without rushing production release before the app has real signing, store assets, SDK QA, and tester evidence.

## Current Decisions

- Keep v1 monetization light: only capped post-match interstitials if AdMob remains enabled.
- Keep analytics privacy-scoped: Firebase events only when real Firebase config is supplied, with no personal input collected.
- Use one balanced AI difficulty.
- Do not add variants before polish and QA.
- Use internal testing first, then closed testing, then production.

## Completion Map

| Area | Status | Next Gate |
| --- | --- | --- |
| Release signing | Wired, secrets missing | Create private keystore and local key.properties |
| Android target SDK | Configured for 36 | Confirm local SDK and successful release build |
| Analytics events | Firebase-capable boundary | Verify DebugView with real Firebase config |
| Crash monitoring | Deferred | Add after Firebase setup, if approved |
| Monetization | Capped post-match interstitials | Keep test ads until AdMob QA and Data safety are complete |
| Store assets | Scripts updated | Regenerate and review real gameplay assets |
| Internal testing | Pending | Upload signed `.aab` |
| Closed testing | Pending | Recruit testers and collect structured feedback |
| Production release | Pending | Only after stability, QA, and policy checks |

## V1 Exit Criteria

- `flutter analyze` passes.
- `flutter test` passes.
- Signed release `.aab` builds successfully.
- Release build installs on a physical Android phone.
- Privacy policy is hosted and matches actual SDK behavior.
- Real tic tac toe screenshots and feature graphic are uploaded.
- Play Console app content forms are complete.
- Internal testing shows no launch/blocking gameplay issues.
- Closed testing confirms gameplay is understandable and stable.

## Recommended Order

1. Run formatting, analysis, and tests.
2. Generate Tik Tak Toe icons and feature graphic.
3. Capture real gameplay screenshots.
4. Configure Android release signing secrets locally.
5. Build signed release `.aab`.
6. Complete Play Console app content forms.
7. Run internal testing.
8. Run closed testing.
9. Review feedback and decide production release or next update.
