# Rooftop Rain Garden

A small Flutter farming game focused on the version 1 loop:
plant, water, grow, harvest, sell, upgrade, save, and return.

Version 1 is intentionally scoped to one farm screen, eight original crops,
six garden levels, nine unlockable plots, short timers, local save data,
production-safe AdMob hooks, and Firebase Analytics hooks.

## Production V1 Scope

- Android package id: `com.childhood.rooftopraingarden`
- App label: `Rain Garden`
- Version: `1.0.0+1`
- Production content: 8 crops, 5 upgrades, 6 garden levels, all 9 plots
- Local save with capped offline progress in version 1
- AdMob uses Google test IDs by default; production ad requests require explicit
  production unit IDs
- Firebase Analytics falls back to no-op until native Firebase config is added
- No account, cloud sync, purchases, town, quests, animals, crafting, or
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
