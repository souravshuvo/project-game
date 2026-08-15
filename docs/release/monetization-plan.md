# Monetization Plan

Last updated: 2026-08-14

## Current Decision

Use production-safe AdMob plumbing with non-personalized level-end interstitials only. Ads must never appear during active puzzle play, must fail open, and must be disabled unless app/ad unit IDs are valid for the selected build environment.

Configured Android production IDs:

- App ID: `ca-app-pub-1358699173061266~8502526686`
- Level-end interstitial: `ca-app-pub-1358699173061266/1193410127`

The app-open, banner, native, rewarded, and rewarded-interstitial units exist in AdMob but are deliberately not requested by this version. They need a separately approved placement and UX design first.

## Options

| Option | Pros | Risks | Phase 6 Decision |
| --- | --- | --- | --- |
| No ads in v1 | Best user trust and simplest privacy story | No revenue test | Still available with `WEATHER_SORT_ADS_ENABLED=false` |
| Rewarded ads for extra hints | Natural fit after a real hint system exists | Needs hint design and balance | Defer |
| Interstitial ads between levels | Easy revenue path | Can hurt retention and reviews in puzzle games | Implement only at capped level-end transitions |
| Paid app | Simple product experience | Higher friction for unknown new game | Defer |
| In-app purchase hint packs | Cleaner than forced ads | Needs billing setup, product economy, refund support | Defer |

## Recommended First Monetization Test

The first monetization test is capped level-end interstitials:

- Placement: after level complete, before entering the next level.
- Frequency cap: first opportunity after 3 completed transitions, then at least 3 completed transitions and 3 minutes between ads.
- Session cap: maximum 4 interstitials per session.
- Request type: non-personalized ads.
- Failure behavior: skip the ad and continue gameplay.

## AdMob Gate

Production upload still requires:

- Android production app ID and level-end interstitial ID are configured.
- A production build must explicitly use `--dart-define=WEATHER_SORT_ADS_ENV=production`; all other builds use official test ad units.
- iOS `GAD_APPLICATION_IDENTIFIER` changed from the sample ID to the real iOS AdMob app ID.
- Test ads verified before any live ad unit is used.
- Privacy policy, Data safety, and Ads declaration are updated.
- Child-directed status is confirmed before serving ads.

## Official References

- Google Mobile Ads Flutter setup: https://developers.google.com/admob/flutter/quick-start
- Flutter Google Mobile Ads cookbook: https://docs.flutter.dev/cookbook/plugins/google-mobile-ads
- Google Play App content declarations: https://support.google.com/googleplay/android-developer/answer/9859455
