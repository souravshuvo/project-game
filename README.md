# Cloud Courier Climb

Cloud Courier Climb is a small Flutter vertical arcade jumper. The player steers a placeholder courier left and right while it auto-jumps upward across floating weather pads.

## MVP controls

- Tap `START RUN` from the main menu.
- Hold `LEFT` or `RIGHT` to steer in the air.
- Land on pads to auto-jump.
- Avoid red warning sparks and falling below the camera.
- Restart from the game-over screen.

## Version 1 scope

- One endless offline mode.
- Height score and locally saved best score.
- Placeholder visuals drawn in Flutter.
- Production-safe AdMob and Firebase Analytics integration points with test IDs by default.
- No shop, skins, leaderboard, login, cloud sync, or copied assets.
- Portrait-first phone gameplay.

## Project structure

- `lib/app`: Flutter app shell and overlays.
- `lib/game`: game loop, world spawning, components, systems, and models.
- `lib/services`: local save, analytics, feedback, AdMob gateway, and ad frequency caps.
- `test/game` and `test/services`: focused tests for game rules and platform services.

## Manual test

Run the app with Flutter, start a run, steer onto platforms, intentionally hit a spark or fall, confirm game over appears, restart, and confirm best score remains after closing and reopening the app.

## Production v1 checklist

- Create `android/key.properties` from `android/key.properties.example`.
- Keep the upload keystore out of git.
- Capture real gameplay screenshots from the final build.
- Replace iOS app icon PNGs before App Store submission.
- Review `docs/privacy_data_safety.md` before store submission.
