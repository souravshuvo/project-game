# Monetization Plan

Last updated: 2026-08-02

## Current Decision

Do not add monetization SDKs in the current build.

Reason: the first testing goal is to validate whether the puzzle loop is fun, readable, and replayable. Monetization should not distort early tester feedback.

## Options

| Option | Pros | Risks | Phase 6 Decision |
| --- | --- | --- | --- |
| No ads in v1 | Best user trust and simplest privacy story | No revenue test | Recommended for first internal test |
| Rewarded ads for extra hints | Natural fit with current hint system | Needs AdMob, consent/policy review, pacing design | Consider after first tester feedback |
| Interstitial ads between levels | Easy revenue path | Can hurt retention and reviews in puzzle games | Defer |
| Paid app | Simple product experience | Higher friction for unknown new game | Defer |
| In-app purchase hint packs | Cleaner than forced ads | Needs billing setup, product economy, refund support | Defer |

## Recommended First Monetization Test

If testers like the core loop, test rewarded hints first:

- Keep one free daily hint.
- Offer one optional rewarded hint when hint balance is zero.
- Never show ads after every tap or during active puzzle solving.
- Cap ad prompts so the game still feels calm.

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
