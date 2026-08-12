# Rooftop Curve

An original Flutter football puzzle game about one-shot rooftop free kicks.

## Current v1 Scope

- One offline challenge mode.
- Thirty original rooftop shot challenges.
- Drag-to-aim, power, and curve controls.
- Goal, saved, missed, blocked, and too-weak results.
- Retry, next challenge, attempts, and in-session stars.
- Menu-only banner ad slot and capped interstitials after safe challenge transitions.
- No online play, no shop, no official teams, no real players, and no real leagues.

## AdMob and Analytics Configuration

The app defaults to AdMob test IDs. Production ad units must be supplied at build
time and ads are never shown during aiming, ball movement, or shot resolution.

- Android AdMob app ID: Gradle property `ADMOB_ANDROID_APP_ID`.
- iOS AdMob app ID: override `GAD_APPLICATION_IDENTIFIER`.
- Runtime flag: `--dart-define=ADMOB_USE_TEST_ADS=false`.
- Production ad units:
  - `--dart-define=ADMOB_ANDROID_BANNER_AD_UNIT_ID=...`
  - `--dart-define=ADMOB_ANDROID_INTERSTITIAL_AD_UNIT_ID=...`
  - `--dart-define=ADMOB_IOS_BANNER_AD_UNIT_ID=...`
  - `--dart-define=ADMOB_IOS_INTERSTITIAL_AD_UNIT_ID=...`

Firebase Analytics is optional and disabled remotely until runtime Firebase
defines are supplied:

- `--dart-define=FIREBASE_API_KEY=...`
- `--dart-define=FIREBASE_PROJECT_ID=...`
- `--dart-define=FIREBASE_MESSAGING_SENDER_ID=...`
- `--dart-define=FIREBASE_ANDROID_APP_ID=...`
- `--dart-define=FIREBASE_IOS_APP_ID=...`

## Manual QA Focus

- Confirm every challenge is scoreable.
- Confirm the help panel does not block drag input.
- Confirm result messages match the actual outcome.
- Confirm small phone screens keep the ball, goal, HUD, and buttons readable.
- Confirm no ad appears during active aiming, shooting, or ball movement.
- Confirm interstitials respect caps and failure never blocks next challenge.
