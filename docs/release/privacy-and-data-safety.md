# Privacy And Data Safety Draft

Last updated: 2026-08-12

## Current App Data Behavior

Current Tik Tak Toe build status:

- No account system
- No login
- Google Mobile Ads SDK added for limited interstitial ads
- Firebase Analytics SDK added with no-op fallback when Firebase Dart defines are missing
- No Crashlytics SDK
- No purchases
- No app-owned backend API
- Internet and network-state permissions are present for ads and analytics SDKs
- No location, contacts, camera, microphone, SMS, call log, files, health, or nearby-device permissions
- Sound and vibration preferences, recent match history, and app-open counters are saved locally with `shared_preferences`
- Current match score is session-only and is not transmitted
- Gameplay, retention, and ad lifecycle events may be transmitted to Firebase Analytics when Firebase is configured
- Ad requests and ad interactions may be processed by Google Mobile Ads when AdMob is configured

Because ads and analytics SDKs are now present, the previous no-data Data safety draft is no longer valid for production builds with Firebase/AdMob configured. Re-check Google Play SDK Index and the current Google Mobile Ads/Firebase Analytics data disclosures before Play submission.

Likely Play Console Data safety areas to review:

- Data collected: app activity, app info and performance, diagnostics, device or other IDs
- Data shared: data processed by Google services for ads, measurement, fraud prevention, and service operation
- Data encrypted in transit: expected yes for Google SDK network traffic, verify in Play SDK disclosures
- Users can request data deletion: no app account exists; verify Firebase/Google requirements for analytics identifiers and reset/opt-out handling
- Ads declaration: yes, the app contains ads if AdMob remains enabled
- Target audience: confirm before serving ads; update policy if child-directed status changes

## Privacy Policy Draft

Publish this at a stable public URL before Play submission.

```text
Privacy Policy for Tik Tak Toe

Effective date: [Add date]

Tik Tak Toe is a tic tac toe game by Childhood.

Data collection
Tik Tak Toe may collect limited app usage, gameplay, device, diagnostics, advertising, and analytics information through Google Mobile Ads and Firebase Analytics when those services are enabled. This information is used to understand app performance, improve gameplay, measure ad impact, and serve ads.

Local settings
The app saves sound and vibration settings, recent match history, and basic app-open counters locally on your device.

Gameplay
Current match scores are kept during your local play session. Completed match summaries are stored on your device. Analytics events may include non-personal gameplay information such as mode, match format, round result, move count, difficulty, and ad lifecycle status.

Children
Tik Tak Toe is not currently configured as a child-directed app. If this changes, this policy and the app's store declarations will be updated before release.

Third-party services
The app may use Google Mobile Ads for advertising and Firebase Analytics for measurement. These services are provided by Google and may process device identifiers, app interactions, diagnostics, and ad interactions according to Google's policies.

Changes
If future versions add purchases, cloud save, login, crash reporting, or online features, this policy will be updated to describe what data is collected and why.

Contact
For privacy questions, contact: [Add support email]
```

## Play Console App Content Draft

- Privacy policy URL: required before production listing and must mention ads/analytics if enabled.
- Ads declaration: Yes if AdMob remains enabled.
- App access: all features are accessible without login.
- Content rating: complete questionnaire in Play Console; likely board/puzzle game with no violence or user-generated content.
- Target audience: confirm before upload. Draft assumes general audience, not child-directed.
- Data safety: update for Google Mobile Ads and Firebase Analytics before upload.
