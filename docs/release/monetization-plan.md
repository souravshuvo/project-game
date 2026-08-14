# Monetization Plan

Last updated: 2026-08-14

## Current Decision

AdMob SDK integration is implemented for production-safe testing.

Reason: the puzzle loop now has production-content coverage, so the next test
can validate whether carefully capped level-end ads affect retention or player
trust. Test ads are the default for QA. Live production ads must remain disabled
until real AdMob app IDs, ad units, privacy policy, Data safety, and
target-audience decisions are complete.

## Options

| Option | Pros | Risks | V1 Decision |
| --- | --- | --- | --- |
| No ads in v1 | Best user trust and simplest privacy story | No revenue test | Previous |
| Rewarded undo | Easy to understand and player-friendly | Needs undo stack and ad SDK | Later |
| Rewarded shuffle | Good recovery option | Can make level design less meaningful | Later |
| Rewarded hint | Helps stuck players | Needs good hint logic | Later |
| Rewarded extra tray slot | Strong rescue moment | Balance risk if overused | Later |
| Rewarded continue after fail | Clear value at fail state | Must not feel coercive | Later |
| Interstitials between levels | Simple revenue path | Can hurt retention and reviews | Implemented with strict caps |
| In-app purchases | Cleaner than forced ads | Needs store products and economy | Defer |

## Rewarded Ad Direction Later

If testers like the core loop, test one optional rewarded feature first:

- Start with rewarded continue after tray full or rewarded undo.
- Never show ads during active puzzle solving.
- Never reward ad clicks.
- Never encourage clicking ads.
- Keep all ad choices optional.
- Add frequency caps before live ads.

## Interstitial Placement

Interstitials may be attempted only when the player taps the level-end result
action after a completed level. They must never appear while the board is
playable, on app launch, from pause/settings/help, or after a failed level.

## Test And Production Separation

- Default Dart behavior uses Google sample interstitial ad units.
- Live ads require `--dart-define=ADMOB_USE_PRODUCTION=true`.
- Live Android interstitial unit:
  `--dart-define=ADMOB_ANDROID_INTERSTITIAL_ID=<real unit id>`.
- Live iOS interstitial unit:
  `--dart-define=ADMOB_IOS_INTERSTITIAL_ID=<real unit id>`.
- Android AdMob app ID defaults to Google's sample app ID and can be overridden
  with Gradle property or environment variable `ADMOB_ANDROID_APP_ID`.
- iOS `GADApplicationIdentifier` currently uses Google's sample app ID and must
  be replaced with the real iOS AdMob app ID before a production iOS release.
- `ADMOB_ENABLED=false` disables ad SDK startup for builds that should not load
  ads.

## Frequency Caps

- Rewarded ads: player-initiated only.
- Interstitials: no more than one per 3 completed levels and no more than one
  every 4 minutes.
- No interstitial before Level 4.
- No ad immediately after a failed level.
- Ad load/show failure must continue the level transition immediately.

## Ad SDK Gate

Before using live production ads:

- Real AdMob app IDs and ad unit IDs exist.
- Test ads are verified before any live ad unit is used.
- Privacy policy, Data safety, Ads declaration, and target-audience status are
  updated.
- Child-directed status is confirmed before serving ads.
- Frequency cap telemetry is checked during internal testing.
