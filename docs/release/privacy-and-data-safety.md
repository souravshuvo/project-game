# Privacy And Data Safety Draft

Last updated: 2026-08-14

## Current App Data Behavior

Current v1 code status:

- No account system
- No login
- Google Mobile Ads SDK declared in `pubspec.yaml`
- Firebase Analytics SDK declared in `pubspec.yaml`
- No crash-reporting SDK
- No purchases
- No backend API
- No cloud sync
- No location, contacts, camera, microphone, SMS, call log, files, health, or
  nearby-device permissions
- No local storage dependency in `pubspec.yaml`
- Built-in Flutter restoration stores current level, highest unlocked level, and
  completed level IDs on device
- Firebase Analytics adapter exists and falls back to no-op if Firebase config is
  missing or analytics is disabled
- AdMob interstitial adapter exists and defaults to Google test ads

The lockfile and generated package config still need to be refreshed after this
dependency update. Current v1 progress storage is local-only Flutter restoration
state.

Because ads and analytics SDKs are now declared, the Play Console Data safety
draft must be reviewed against the exact Google SDK behavior and final app
configuration before release. Do not keep the previous "no data collected" draft
without review. Likely areas to check include:

- Device or other IDs, including advertising ID where applicable
- App interactions and gameplay analytics events
- Diagnostics or SDK operational data
- Advertising or marketing data uses

This must be updated before release if ads, analytics, crash reporting,
purchases, cloud save, login, or any SDK that collects identifiers is added.

## Privacy Policy Draft

Publish this at a stable public URL before Play submission.

```text
Privacy Policy for Larder Labels

Effective date: [Add date]

Larder Labels is a puzzle game by Childhood.

Data collection
Larder Labels may use Google Mobile Ads and Firebase Analytics after release to
show ads between completed puzzle levels and understand gameplay difficulty. The
game does not require an account, name, email address, contacts, photos, precise
location, microphone, camera, or file access.

Local gameplay
The current version may keep puzzle progress on the device using Flutter's
built-in restoration state.

Ads and analytics
When enabled and configured, Google Mobile Ads and Firebase Analytics may process
app interaction, advertising, device, and diagnostic data as described in
Google's SDK and privacy documentation. Ads are not shown during active puzzle
play.

Children
Larder Labels is not currently configured as a child-directed app. If this
changes, this policy and the app's store declarations will be updated before
release.

Third-party services
The current version includes SDK integration for advertising and analytics. It
does not include crash reporting, account login, payment, or cloud-sync services.

Changes
If future versions add purchases, crash reporting, cloud save, or online
features, this policy will be updated to describe what data is collected and why.

Contact
For privacy questions, contact: [Add support email]
```

## Play Console App Content Draft

- Privacy policy URL: required before production listing.
- Ads declaration: Yes, if AdMob remains enabled for release.
- App access: All features are accessible without login.
- Content rating: Complete questionnaire in Play Console; likely puzzle/casual
  with no violence or user-generated content.
- Target audience: Confirm before upload. Draft assumes general audience, not
  child-directed.
- Data safety: Must be completed for Google Mobile Ads and Firebase Analytics
  before release.
