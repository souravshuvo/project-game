# AdMob And Analytics QA

Last updated: 2026-08-12

## Ad Placement

- Placement: `post_match`
- Format: interstitial
- First eligible show: after 3 completed matches in the current app session
- Minimum interval: 6 minutes
- Maximum shown per app session: 3
- Never show during active rounds, AI thinking, setup, settings, help, launch, or app exit

## Manual Ad QA

- Install a debug or internal test build using demo IDs.
- Complete two matches and confirm no interstitial appears.
- Complete the third match and confirm the interstitial appears only after the result state.
- Tap New Match quickly after a match and confirm the ad is skipped if a new round has started.
- Turn airplane mode on and confirm ad failure does not block restart or mode selection.
- Confirm every visible ad is marked as test/demo before any local clicking.
- For production IDs, use AdMob test devices or test app mode; do not click live production ads.

## Analytics QA

- Build once without Firebase Dart defines and confirm gameplay still starts.
- Build once with Firebase Dart defines and confirm Firebase DebugView receives:
  - `app_session_started`
  - `mode_selected`
  - `round_started`
  - `round_ended`
  - `match_completed`
  - `ad_skipped` or ad lifecycle events
- Confirm events do not include names, emails, free text, precise location, contacts, or unrelated device data.

## Production Build Inputs

Android Gradle property:

```text
ADMOB_ANDROID_APP_ID=ca-app-pub-...~...
```

Dart defines:

```text
--dart-define=ADMOB_ANDROID_INTERSTITIAL_ID=ca-app-pub-.../...
--dart-define=ADMOB_IOS_INTERSTITIAL_ID=ca-app-pub-.../...
--dart-define=FIREBASE_API_KEY=...
--dart-define=FIREBASE_PROJECT_ID=...
--dart-define=FIREBASE_MESSAGING_SENDER_ID=...
--dart-define=FIREBASE_ANDROID_APP_ID=...
--dart-define=FIREBASE_IOS_APP_ID=...
```
