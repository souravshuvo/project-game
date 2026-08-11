# Android Studio Flutter Project Repair

Use this when Android Studio shows any of these symptoms:

- Dart support is not enabled yet.
- No module selected.
- Code insight unavailable because the related Gradle project is not linked.
- Gradle sync fails after copying or renaming a Flutter project.

## Common Fix

Close Android Studio first, then run this from the Flutter project root, the folder that contains `pubspec.yaml`:

```powershell
flutter pub get
powershell -ExecutionPolicy Bypass -File .\tool\repair_android_studio_flutter_project.ps1
```

Then reopen the Flutter project root in Android Studio and run:

```text
File > Sync Project with Gradle Files
```

Open the root folder, not the `android` folder.

## For Every Project

Do not copy `.idea` or `*.iml` files between Flutter projects. They contain machine-local module paths, SDK paths, and run configurations. This repository ignores those files, so each machine should regenerate them locally.

If Android Studio still shows stale module errors after the script runs:

1. Close Android Studio.
2. Reopen the folder that contains `pubspec.yaml`.
3. Select the `main.dart` Flutter run configuration.
4. Run `File > Invalidate Caches / Restart`.

## Windows Plugin Build Error

If Gradle says plugin build files have different roots, such as `D:\project\build\google_mobile_ads` and `C:\Users\...\Pub\Cache\...\google_mobile_ads`, the Android Gradle build file must not force external Pub Cache plugins to build inside the app repo. This project keeps shared build output only for project-local modules.
