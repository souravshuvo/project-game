# Privacy And Data Safety

Reviewed against Google Play policy help pages on August 12, 2026:

- Data safety form:
  https://support.google.com/googleplay/android-developer/answer/10787469
- User Data policy:
  https://support.google.com/googleplay/android-developer/answer/10144311

Google Play requires accurate Data safety declarations for apps on closed,
open, and production tracks. Apps that do not collect user data still need a
completed Data safety form and a privacy policy. Google Play also requires a
privacy policy in Play Console and a privacy policy link or text inside the app.

## Version 1 Data Practices

Rooftop Rain Garden version 1 keeps game progress local, but now includes
production-safe Google Mobile Ads and Firebase Analytics hooks.

| Area | V1 behavior |
| --- | --- |
| Account | No account creation or login |
| Network | Main Android manifest declares internet and network-state permissions for ads and analytics |
| Ads | Google Mobile Ads SDK; Google test IDs by default, production IDs required for live ads |
| Analytics | Firebase Analytics wrapper; falls back to no-op if native Firebase config is absent or initialization fails |
| Purchases | No in-app purchases |
| Cloud sync | None |
| Save data | Local device storage through SharedPreferences |
| Personal data | No account/profile collection by the game itself |
| Data sharing | Google Ads/Firebase SDK data handling must be declared from the final release artifact |

AdMob interstitials are capped and requested only at natural transitions outside
active gameplay. Ad loading failure must not block the farm loop.

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

For the current v1 codebase, the expected declaration direction must account
for Google Mobile Ads and Firebase Analytics in the final build:

- Data collected/shared: verify against the exact Google SDK versions,
  Firebase configuration, AdMob account settings, consent settings, and Play
  SDK guidance before submission
- Likely SDK-related areas to review: app activity, ad interactions, diagnostics,
  device or other identifiers, approximate device information, and performance
  data
- Data encrypted in transit: verify for SDK network traffic in the final build
- Users can request game-save deletion by deleting the app; any Google
  ad/analytics controls must be described in the hosted privacy policy

The developer is still responsible for checking the final release artifact and
all included SDKs before submitting the Play form.

## Changes That Require A Privacy/Data Safety Update

- Changing AdMob mediation, ad personalization, consent, or frequency behavior
- Changing Firebase Analytics, Crashlytics, Sentry, PostHog, or remote logging
- Adding accounts, login, cloud save, social, leaderboards, or multiplayer
- Adding purchases or subscriptions
- Adding location, contacts, photos, microphone, camera, notifications, or other
  user/device data permissions
- Adding webviews or external network calls
