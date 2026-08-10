# Privacy And Data Safety Draft

Last updated: 2026-08-10

## Current App Data Behavior

Current Pocket Observatory XO build status:

- No account system
- No login
- No ads SDK
- No analytics SDK
- No Firebase or Crashlytics SDK
- No purchases
- No backend API
- No location, contacts, camera, microphone, SMS, call log, files, health, or nearby-device permissions
- Sound and vibration preferences are saved locally with `shared_preferences`
- Current match score is session-only and is not transmitted
- No-op telemetry hooks exist in code, but no telemetry data is transmitted

Because the current app does not transmit user data off the device, the initial Play Console Data safety draft should be:

- Data collected: No
- Data shared: No
- Data encrypted in transit: Not applicable while no data leaves the device
- Users can request data deletion: Not applicable while no account or server-side data exists

Update this document before release if ads, analytics, crash reporting, purchases, cloud save, login, or any SDK that collects identifiers is added.

## Privacy Policy Draft

Publish this at a stable public URL before Play submission.

```text
Privacy Policy for Pocket Observatory XO

Effective date: [Add date]

Pocket Observatory XO is a tic tac toe game by Childhood.

Data collection
Pocket Observatory XO does not currently collect, transmit, sell, or share personal data.

Local settings
The app saves sound and vibration settings locally on your device. This information stays on your device and is not sent to us.

Gameplay
Current match scores are kept only during your local play session. They are not sent to us.

Children
Pocket Observatory XO is not currently configured as a child-directed app. If this changes, this policy and the app's store declarations will be updated before release.

Third-party services
The current version does not include advertising, analytics, account login, payment, crash reporting, or cloud-sync services.

Changes
If future versions add ads, analytics, purchases, cloud save, crash reporting, or online features, this policy will be updated to describe what data is collected and why.

Contact
For privacy questions, contact: [Add support email]
```

## Play Console App Content Draft

- Privacy policy URL: required before production listing.
- Ads declaration: No, for v1.
- App access: all features are accessible without login.
- Content rating: complete questionnaire in Play Console; likely board/puzzle game with no violence or user-generated content.
- Target audience: confirm before upload. Draft assumes general audience, not child-directed.
- Data safety: complete even if no data is collected.
