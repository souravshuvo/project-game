# Signal Reef Android Release Signing

Last updated: 2026-08-10

## Current Status

The Gradle release config reads `android/key.properties` when it exists and uses that upload signing config for release builds.

If `android/key.properties` is missing, the release build falls back to debug signing so local release-mode runs can still work. Do not upload a debug-signed artifact to Play.

## One-Time Setup

The repository includes `android/key.properties.example`, but the real `android/key.properties` and keystore file must stay local and uncommitted.

1. Create an upload keystore.

```powershell
keytool -genkey -v -keystore android/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias signal-reef
```

2. Copy the example file.

```powershell
Copy-Item android/key.properties.example android/key.properties
```

3. Update `android/key.properties` with the real passwords and keystore path.

4. Build the app bundle.

```powershell
flutter build appbundle --release
```

5. Confirm the Play Console package name is `com.childhood.signalreef`.

## Keep Private

- Keep the upload keystore backed up in a private password manager or secure drive.
- Do not commit `android/key.properties`, `.jks`, or `.keystore` files.
- Do not reuse passwords from other projects.
