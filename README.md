# KidsLand

KidsLand is a preschool mini-games app with tracing, logic, memory, drawing, and simple touch-play activities.

## App Identity

- Display name: `KidsLand`
- Android application ID: `com.childhood.kidsland`
- iOS bundle ID: `com.childhood.kidsland`

## AdMob

AdMob is wired through a production-safe controller:

- Home footer banner only, outside active gameplay.
- Interstitial opportunities only after a completed game returns to Home.
- No app-open ads, rewarded ads, or ads over active gameplay.
- Interstitial cap: 2 completed games before the first interstitial, 2 completed games between interstitials, 4 minutes minimum between shows, and 3 interstitials max per app session.
- Ad load/show failure is non-blocking.

Debug/test mode uses Google sample ad unit IDs. Release builds disable ads if `ADMOB_MODE` is left as `test`.

Production ad units require Dart defines:

```powershell
--dart-define=ADMOB_MODE=production
--dart-define=ADMOB_ANDROID_BANNER_ID=<android-banner-unit>
--dart-define=ADMOB_ANDROID_INTERSTITIAL_ID=<android-interstitial-unit>
--dart-define=ADMOB_IOS_BANNER_ID=<ios-banner-unit>
--dart-define=ADMOB_IOS_INTERSTITIAL_ID=<ios-interstitial-unit>
```

Android production builds should also provide the AdMob app ID through `ADMOB_ANDROID_APP_ID` as a Gradle property or environment variable. iOS currently contains the Google sample app ID in `ios/Runner/Info.plist`; replace it with the real iOS AdMob app ID before any production iOS upload.

## Analytics

Firebase Analytics is wrapped behind `GameAnalytics`. If Firebase is not configured, startup falls back to no-op analytics and gameplay continues.

Tracked event areas:

- Session and lifecycle: app session start, pause/resume/dispose.
- Gameplay: game start, game completion, game exit duration.
- Content/difficulty: tracing content start/complete for each letter/number, plus valid/invalid/reward/win feedback events across games.
- Parent/settings: parent gate result, settings open/change, progress reset.
- Ad impact: ad opportunities, load/show/impression/click/dismiss/error.

Do not log names, child profiles, raw touch coordinates, drawings, free text, precise timestamps, location, camera, microphone, or account identifiers.

Firebase consent defaults deny ad storage, ad personalization signals, and ad user data while allowing analytics storage for the configured gameplay events.

## Data Safety Notes

Before Play Store upload, update the privacy policy and Play Data safety form for:

- Google Mobile Ads SDK.
- Firebase Core and Firebase Analytics.
- Android network permissions: `INTERNET` and `ACCESS_NETWORK_STATE`.
- App interactions/gameplay events.
- Ad performance and diagnostics events.
- Any identifiers or diagnostics collected by Google SDKs under the final configuration.

Firebase configuration files are not included in this repository yet.
