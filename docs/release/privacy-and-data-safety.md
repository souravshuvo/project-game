# Privacy And Data Safety

Reviewed against Google Play policy help pages on August 10, 2026:

- Data safety form:
  https://support.google.com/googleplay/android-developer/answer/10787469
- User Data policy:
  https://support.google.com/googleplay/android-developer/answer/10144311

Google Play requires accurate Data safety declarations for apps on closed,
open, and production tracks. Apps that do not collect user data still need a
completed Data safety form and a privacy policy. Google Play also requires a
privacy policy in Play Console and a privacy policy link or text inside the app.

## Version 1 Data Practices

Rooftop Rain Garden version 1 is designed as an offline game.

| Area | V1 behavior |
| --- | --- |
| Account | No account creation or login |
| Network | No internet permission in the main Android manifest |
| Ads | No ad SDK and no ad display |
| Analytics | No external analytics SDK; current analytics implementation is no-op |
| Purchases | No in-app purchases |
| Cloud sync | None |
| Save data | Local device storage through SharedPreferences |
| Personal data | No intentional collection of personal information |
| Data sharing | No intentional sharing from the app |

Debug and profile Android manifests may include internet permission for Flutter
development tooling. The release/main manifest does not declare it.

## Local Save Data

The app stores gameplay state locally:

- coins
- water
- seeds
- harvested crate counts
- farm level
- plot crop ids
- planted/watered timestamps
- last saved timestamp

This data is used only to restore the farm and calculate capped offline
progress. Deleting the app may delete local progress.

## Data Safety Draft Direction

For the current v1 codebase, the expected declaration direction is:

- Data collected: no, if no SDK or build variant transmits user data off device
- Data shared: no
- Data encrypted in transit: not applicable for offline-only v1
- Users can request data deletion: not applicable for no-account local-only data

The developer is still responsible for checking the final release artifact and
all included SDKs before submitting the Play form.

## Changes That Require A Privacy/Data Safety Update

- Adding AdMob or any ad mediation SDK
- Adding analytics, Crashlytics, Sentry, PostHog, Firebase, or remote logging
- Adding accounts, login, cloud save, social, leaderboards, or multiplayer
- Adding purchases or subscriptions
- Adding location, contacts, photos, microphone, camera, notifications, or other
  user/device data permissions
- Adding webviews or external network calls
