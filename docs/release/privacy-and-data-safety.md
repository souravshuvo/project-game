# Signal Reef Privacy And Data Safety Draft

Last updated: 2026-08-14

## Current App Data Behavior

Current build status:

- No account system
- No login
- Google Mobile Ads SDK added for banners and capped result-screen interstitials
- Firebase Analytics adapter added, but disabled unless Firebase dart-defines are configured
- No crash-reporting SDK
- No purchases
- No backend API owned by this app
- No location, contacts, camera, microphone, SMS, call log, files, health, or nearby-device permissions
- Local best score, best wave reached, runs played, sound settings, and haptic settings are saved on-device with `shared_preferences`

Because AdMob is now included, the Play Console Data safety draft must be reviewed for Google Mobile Ads data collection before release. Do not keep the previous "Data collected: No" answer without checking SDK behavior and the final production configuration.

## Privacy Policy Draft

Publish this at a stable public URL before Play submission.

```text
Privacy Policy for Signal Reef

Effective date: [Add date]

Signal Reef is an arcade space shooter game by Childhood.

Local game progress
The app saves best score, best wave reached, runs played, sound settings, and haptic settings locally on your device.

Advertising
Signal Reef uses Google Mobile Ads to show ads on non-gameplay screens. Ads are not shown during active gameplay. Google Mobile Ads may collect or use device identifiers, advertising data, diagnostics, and related information as described by Google.

Analytics
Signal Reef may use Firebase Analytics to understand gameplay balance, session length, ad performance, and retention. Analytics events do not include names, emails, precise location, contacts, photos, or free-text personal content.

Children
Signal Reef is not currently configured as a child-directed app. If this changes, this policy and the app's store declarations will be updated before release.

Changes
If future versions add purchases, cloud save, login, crash reporting, or online features, this policy will be updated to describe what data is collected and why.

Contact
For privacy questions, contact: [Add support email]
```

## Play Console App Content Draft

- Privacy policy URL: required before production listing.
- Ads declaration: Yes, if AdMob remains enabled in the release build.
- App access: All features are accessible without login.
- Content rating: Complete questionnaire in Play Console; likely arcade shooter/fantasy space combat with no graphic violence or user-generated content.
- Target audience: Confirm before upload. Draft assumes general audience, not child-directed.
- Data safety: Update for Google Mobile Ads and Firebase Analytics if analytics is enabled.
- Consent: Add or verify Google UMP consent handling before serving live ads in regions that require consent.

## Official References

- Google Play Data safety requirements: https://support.google.com/googleplay/android-developer/answer/10787469
- Google Play App content and privacy policy guidance: https://support.google.com/googleplay/android-developer/answer/9859455
