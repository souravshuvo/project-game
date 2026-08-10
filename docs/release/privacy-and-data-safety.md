# Privacy And Data Safety Draft

Last updated: 2026-08-10

## Current App Data Behavior

Current v1 code status:

- No account system
- No login
- No ads SDK
- No analytics SDK
- No crash-reporting SDK
- No purchases
- No backend API
- No cloud sync
- No location, contacts, camera, microphone, SMS, call log, files, health, or
  nearby-device permissions
- No local storage dependency in `pubspec.yaml`
- No current gameplay progress store in active code
- No telemetry boundary in active code

The lockfile and generated package config still need to be refreshed after this
dependency cleanup, but no active v1 code writes local gameplay progress.

Because the current app does not transmit user data off the device, the initial
Play Console Data safety draft should be:

- Data collected: No
- Data shared: No
- Data encrypted in transit: Not applicable while no data leaves the device
- Users can request data deletion: Not applicable while no account/server-side
  data exists

This must be updated before release if ads, analytics, crash reporting,
purchases, cloud save, login, or any SDK that collects identifiers is added.

## Privacy Policy Draft

Publish this at a stable public URL before Play submission.

```text
Privacy Policy for Larder Labels

Effective date: [Add date]

Larder Labels is a puzzle game by Childhood.

Data collection
Larder Labels does not currently collect, transmit, sell, or share personal data.

Local gameplay
The current version keeps puzzle progress only in the active app session. It does
not currently send gameplay data to us or to third-party services.

Children
Larder Labels is not currently configured as a child-directed app. If this
changes, this policy and the app's store declarations will be updated before
release.

Third-party services
The current version does not include advertising, analytics, crash reporting,
account login, payment, or cloud-sync services.

Changes
If future versions add ads, analytics, purchases, crash reporting, cloud save, or
online features, this policy will be updated to describe what data is collected
and why.

Contact
For privacy questions, contact: [Add support email]
```

## Play Console App Content Draft

- Privacy policy URL: required before production listing.
- Ads declaration: No, for current v1.
- App access: All features are accessible without login.
- Content rating: Complete questionnaire in Play Console; likely puzzle/casual
  with no violence or user-generated content.
- Target audience: Confirm before upload. Draft assumes general audience, not
  child-directed.
- Data safety: Complete even if no data is collected.
