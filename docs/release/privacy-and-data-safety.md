# Privacy And Data Safety Draft

Last updated: 2026-08-02

## Current App Data Behavior

Current build status:

- No account system
- No login
- No ads SDK
- No analytics SDK
- No purchases
- No backend API
- No location, contacts, camera, microphone, SMS, call log, files, health, or nearby-device permissions
- Local progress is saved on-device with `shared_preferences`
- No-op telemetry hooks exist in code, but no telemetry data is transmitted in the current build

Because the current app does not transmit user data off the device, the initial Play Console Data safety draft should be:

- Data collected: No
- Data shared: No
- Data encrypted in transit: Not applicable while no data leaves the device
- Users can request data deletion: Not applicable while no account/server-side data exists

This must be updated before release if ads, analytics, crash reporting, purchases, cloud save, login, or any SDK that collects identifiers is added.

## Privacy Policy Draft

Publish this at a stable public URL before Play submission.

```text
Privacy Policy for Arrow Puzzle

Effective date: [Add date]

Arrow Puzzle is a puzzle game by Childhood.

Data collection
Arrow Puzzle does not currently collect, transmit, sell, or share personal data.

Local game progress
The app saves gameplay progress, unlocked levels, best moves, hint count, sound settings, and haptic settings locally on your device. This information stays on your device and is not sent to us.

Children
Arrow Puzzle is not currently configured as a child-directed app. If this changes, this policy and the app's store declarations will be updated before release.

Third-party services
The current version does not include advertising, analytics, account login, payment, or cloud-sync services.

Changes
If future versions add ads, analytics, purchases, cloud save, or online features, this policy will be updated to describe what data is collected and why.

Contact
For privacy questions, contact: [Add support email]
```

## Play Console App Content Draft

- Privacy policy URL: required before production listing.
- Ads declaration: No, for the current build.
- App access: All features are accessible without login.
- Content rating: Complete questionnaire in Play Console; likely puzzle/casual with no violence or user-generated content.
- Target audience: Confirm before upload. Draft assumes general audience, not child-directed.
- Data safety: Complete even if no data is collected.

## Official References

- Google Play Data safety requirements: https://support.google.com/googleplay/android-developer/answer/10787469
- Google Play App content and privacy policy guidance: https://support.google.com/googleplay/android-developer/answer/9859455
