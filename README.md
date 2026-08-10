# Rooftop Rain Garden

A small offline Flutter farming game focused on the version 1 loop:
plant, water, grow, harvest, sell, upgrade, save, and return.

Version 1 is intentionally scoped to one farm screen, three original crops,
short timers, simple resources, local save data, and no ads.

## Production V1 Scope

- Android package id: `com.rooftopraingarden.app`
- App label: `Rain Garden`
- Version: `1.0.0+1`
- Offline-only local save in version 1
- No account, cloud sync, ads, purchases, town, quests, animals, crafting, or
  live events

## Release Notes

Release signing is configured to use `android/key.properties` and an upload
keystore. Debug signing is not used for release builds. Copy
`android/key.properties.example` to `android/key.properties`, fill in real
upload-key values, and keep the keystore and properties file out of source
control.

This pass did not run build, run, pub get, emulator, or install commands. Run
the release checklist in `docs/release/release-checklist.md` before uploading
to any Play testing or production track.
