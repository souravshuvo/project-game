# Android Release Signing

Last updated: 2026-08-10

## Current Status

Release signing is not configured yet.

The repository includes `android/key.properties.example`, but the real
`android/key.properties` and keystore file must stay local and uncommitted.
Current Gradle release config is intentionally unsigned and must be wired to a
real upload keystore before production upload.

## One-Time Setup

1. Create an upload keystore.

```powershell
keytool -genkey -v -keystore android/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias larder-labels
```

2. Copy the example config.

```powershell
Copy-Item android/key.properties.example android/key.properties
```

3. Update `android/key.properties` with the real passwords and keystore path.

4. Update `android/app/build.gradle.kts` to use the release signing config
   before building a production `.aab`.

## Before First Upload

- Keep the upload keystore backed up in a private password manager or secure
  drive.
- Do not commit `android/key.properties`, `.jks`, or `.keystore` files.
- Build and upload an Android App Bundle, not only an APK.
- Confirm the Play Console package name is `com.childhood.larderlabels`.

## Build Command For Later

```powershell
flutter build appbundle --release
```
