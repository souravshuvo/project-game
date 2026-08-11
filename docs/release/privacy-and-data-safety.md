# Privacy And Data Safety Draft

Last updated: 2026-08-11

## Current App Data Behavior

Current build status:

- No account system
- No login
- No purchases
- No backend API controlled by the app
- No location, contacts, camera, microphone, SMS, call log, files, health, or nearby-device permissions
- Local progress is saved on-device with `shared_preferences`
- AdMob SDK is installed and defaults to Google test ads
- Firebase Analytics and Crashlytics packages are installed behind runtime initialization with no-op fallback
- The app requests non-personalized ads from the AdMob runtime adapter

Because AdMob, Firebase Analytics, and Crashlytics are now present, the previous "Data collected: No" draft is no longer safe for production. The final Play Console Data safety form and hosted privacy policy must be completed against the final SDK configuration before upload.

## Likely Data Safety Areas To Review

Verify final disclosures against Google/Firebase SDK behavior for the exact release build:

- App activity for gameplay analytics such as level starts, completions, retries, hints, settings toggles, and screen views.
- App diagnostics for crash reports and runtime errors.
- Device or other IDs used by advertising, analytics, and crash reporting SDKs.
- Advertising data for AdMob requests, impressions, failures, and ad interactions.
- Data sharing with Google services for ads, analytics, and crash monitoring.
- Encryption in transit for SDK network traffic.
- Data deletion language, noting there is no app account but users may clear local app storage and can contact support for privacy questions.

## Local-Only Data

The app stores the following locally on the device:

- Current level
- Unlocked levels
- Completed level IDs
- Best move counts
- Hint count
- Daily hint date
- Daily completion date and streak
- Sound and haptics settings

This local progress is not sent by app code directly. Analytics events may include aggregated gameplay properties such as level number, move count, hint count, and completion timing.

## Privacy Policy Draft

Publish this at a stable public URL before Play submission.

```text
Privacy Policy for Arrow Puzzle

Effective date: [Add date]

Arrow Puzzle is a puzzle game by Childhood.

Data we process
Arrow Puzzle saves gameplay progress and settings locally on your device. This includes unlocked levels, completed levels, best moves, hint count, daily streak, sound settings, and haptic settings.

Analytics and diagnostics
Arrow Puzzle may use Firebase Analytics to understand gameplay performance, level difficulty, retention, and feature usage. Arrow Puzzle may use Firebase Crashlytics to collect crash reports and diagnostics so we can fix reliability issues. We do not use these tools to collect names, email addresses, contacts, photos, precise location, or free-text messages.

Advertising
Arrow Puzzle may use Google AdMob to show ads. Ads are not shown during active puzzle play. Rewarded ads may grant an optional hint only after the rewarded ad is completed. AdMob and Google services may process device identifiers, advertising data, and app activity according to their own policies and the app's final consent and targeting settings.

Children
Arrow Puzzle is not currently configured as a child-directed app. If this changes, this policy, ad settings, and store declarations will be updated before release.

Your choices
You can clear local game progress by clearing the app's storage or uninstalling the app. For privacy questions, contact us at [Add support email].

Changes
If future versions add login, purchases, cloud save, or online features, this policy will be updated to describe what data is collected and why.

Contact
For privacy questions, contact: [Add support email]
```

## Play Console App Content Draft

- Privacy policy URL: required before production listing.
- Ads declaration: Yes, if AdMob remains enabled in the submitted build.
- App access: All features are accessible without login.
- Content rating: Complete questionnaire in Play Console; likely puzzle/casual with no violence or user-generated content.
- Target audience: Confirm before upload. Draft assumes general audience, not child-directed.
- Data safety: Must disclose final AdMob/Firebase behavior.

## Official References

- Google Play Data safety requirements: https://support.google.com/googleplay/android-developer/answer/10787469
- Google Play App content and privacy policy guidance: https://support.google.com/googleplay/android-developer/answer/9859455
