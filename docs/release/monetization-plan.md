# Monetization Plan

Last updated: 2026-08-12

## Current Decision

Use limited AdMob interstitials only after completed matches.

Reason: tic tac toe sessions are short, so ads must stay rare, delayed until natural breaks, and easy to remove if closed-test feedback says they hurt replay.

## V1 Policy

- No banner ads.
- Interstitial ads may appear only after a completed match result, never during an active round.
- No rewarded ads.
- No in-app purchases.
- No shop or skins.

## Current Placement

| Placement | Format | Status | Rule |
| --- | --- | --- | --- |
| Post-match result | Interstitial | Implemented | Eligible only after the third completed match in the current app session |

## Frequency Caps

- First interstitial: not before 3 completed matches in the current app session.
- Minimum interval: 6 minutes between shown interstitials.
- Session cap: maximum 3 shown interstitials per app session.
- Skip if the user has already started another round, changed screens, or the ad is not loaded.
- Ad load/show failure must be logged and must not block play.

## Test And Production Separation

- Android AdMob app ID defaults to Google's demo app ID through `ADMOB_ANDROID_APP_ID` manifest placeholder.
- Android production app ID should be supplied with Gradle property `ADMOB_ANDROID_APP_ID`.
- iOS `GADApplicationIdentifier` defaults to Google's demo app ID through `ADMOB_IOS_APP_ID` in xcconfig.
- Interstitial ad units default to Google demo units.
- Production ad unit IDs must be supplied with:
  - `--dart-define=ADMOB_ANDROID_INTERSTITIAL_ID=...`
  - `--dart-define=ADMOB_IOS_INTERSTITIAL_ID=...`
- Before publishing, confirm no production build intended for monetization is still using demo IDs.

## Later Options

| Option | Pros | Risks | Decision |
| --- | --- | --- | --- |
| Stay ad-free | Best user trust and simplest privacy story | No revenue test | Keep as fallback if ads hurt replay |
| Supporter upgrade | Friendly, optional | Requires billing setup | Consider later |
| Rewarded cosmetic preview | User-initiated | Needs AdMob and clear reward design | Defer |
| Interstitial between completed rounds | Easy revenue path | High annoyance risk in short sessions | Do not add; current placement waits for completed matches only |

## Ad QA Gate

Keep ads disabled or in test mode until:

- Gameplay polish issues are resolved.
- Closed test feedback supports monetization.
- AdMob account and app IDs exist.
- Test ads are verified.
- Privacy policy, Data safety, and Ads declaration are updated.
- Child-directed status is confirmed before serving ads.

Ads must never appear during an active round, immediately after a move, during AI thinking, during win/draw animation, on app launch, or on app exit.
