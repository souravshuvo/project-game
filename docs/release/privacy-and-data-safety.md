# Privacy And Data Safety Draft

Last updated: 2026-08-14

## Current App Data Behavior

Current Weather Lab Sort build status:

- No account system
- No login
- AdMob SDK added for capped level-end interstitials
- Firebase Analytics SDK added for gameplay/ad measurement
- No purchases
- No custom backend API
- No location, contacts, camera, microphone, SMS, call log, files, health, or nearby-device permissions
- Local progress is saved on-device with `shared_preferences`
- Analytics disables itself if Firebase is not configured
- Ads use official test IDs by default and must use real AdMob IDs before production upload

Because the app now includes ads and analytics SDKs, the Play Console Data safety draft must be updated after the final Firebase/AdMob configuration is verified. Expected impact:

- Ads declaration: Yes, for AdMob-enabled builds.
- Data collected: Yes, if Firebase Analytics and/or AdMob are enabled.
- Data shared: Review Google/Firebase SDK disclosures before final submission.
- Data encrypted in transit: Yes, for SDK network traffic where applicable.
- Users can request data deletion: no account/server-side app profile exists, but privacy policy must explain SDK data handling.

This must be rechecked before release if Crashlytics, purchases, cloud save, login, personalized ads, consent SDKs, or additional SDKs are added.

## Privacy Policy Draft

Publish this at a stable public URL before Play submission.

```text
Privacy Policy for Weather Lab Sort

Effective date: [Add date]

Weather Lab Sort is a puzzle game by Childhood.

Data collection
Weather Lab Sort uses Firebase Analytics to measure gameplay events such as level starts, level completions, restarts, invalid moves, undo use, and ad delivery events. We do not ask for your name, email address, contacts, photos, precise location, or free-text personal information.

Local game progress
The app saves gameplay progress, unlocked levels, best moves, best stars, sound settings, and haptic settings locally on your device. This information stays on your device and is not sent to us.

Children
Weather Lab Sort is not currently configured as a child-directed app. If this changes, this policy and the app's store declarations will be updated before release.

Third-party services
Weather Lab Sort uses Google AdMob for ads and Firebase Analytics for app measurement. Ads are not shown during active puzzle play. The current version does not include account login, payment, cloud sync, or a custom backend.

Changes
If future versions add personalized ads, purchases, cloud save, login, or online features, this policy will be updated to describe what data is collected and why.

Contact
For privacy questions, contact: [Add support email]
```

## Play Console App Content Draft

- Privacy policy URL: required before production listing.
- Ads declaration: Yes, for AdMob-enabled builds.
- App access: All features are accessible without login.
- Content rating: Complete questionnaire in Play Console; likely puzzle/casual with no violence or user-generated content.
- Target audience: Confirm before upload. Draft assumes general audience, not child-directed.
- Data safety: Complete using the final Firebase Analytics and AdMob SDK disclosures.

## Official References

- Google Play Data safety requirements: https://support.google.com/googleplay/android-developer/answer/10787469
- Google Play App content and privacy policy guidance: https://support.google.com/googleplay/android-developer/answer/9859455
