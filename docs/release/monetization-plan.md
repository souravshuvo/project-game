# Signal Reef Monetization Plan

Last updated: 2026-08-10

## Current Decision

Do not add monetization SDKs in the current build.

Reason: the first testing goal is to validate whether movement, shooting, waves, damage, and retry are fun. Monetization should not distort early tester feedback.

## Options

| Option | Pros | Risks | Decision |
| --- | --- | --- | --- |
| No ads in v1 | Best user trust and simplest privacy story | No revenue test | Recommended for internal test |
| Rewarded revive | Clear optional value after game over | Needs AdMob, consent/policy review, pacing design | Consider after gameplay feel pass |
| Rewarded temporary booster | User-controlled and pre-run only | Can blur balance if added too early | Defer |
| Interstitial after run | Natural transition point | Can hurt retention and reviews | Defer |
| Paid app or IAP | Cleaner than forced ads | Higher setup and support burden | Defer |

## Recommended First Monetization Test

If testers like the core loop, test one optional rewarded revive:

- Offer only after game over.
- Max once per run.
- Restore 1 hull and restart at the current wave.
- Never show ads during active gameplay, countdown, pause, or immediate retry.
- Add frequency caps before any live ad units.

## AdMob Gate

Only add AdMob after:

- Monetization choice is final for the next update.
- AdMob account and app IDs exist.
- Android and iOS app IDs are added to platform config.
- Test ads are verified before any live ad unit is used.
- Privacy policy, Data safety, and Ads declaration are updated.
- Child-directed status is confirmed before serving ads.

## Official References

- Google Mobile Ads Flutter setup: https://developers.google.com/admob/flutter/quick-start
- Flutter Google Mobile Ads cookbook: https://docs.flutter.dev/cookbook/plugins/google-mobile-ads
- Google Play App content declarations: https://support.google.com/googleplay/android-developer/answer/9859455
