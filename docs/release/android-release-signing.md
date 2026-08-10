# Android Release Signing

Last updated: 2026-08-10

## Current Status

Release signing is wired to use a private upload keystore when `android/key.properties` exists.

Release builds no longer intentionally fall back to debug signing. The real `android/key.properties` and keystore file must stay local and uncommitted.

## One-Time Setup

1. Create an upload keystore.

```powershell
keytool -genkey -v -keystore android/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias pocket-observatory
```

2. Copy the example config.

```powershell
Copy-Item android/key.properties.example android/key.properties
```

3. Update `android/key.properties` with the real passwords and keystore path.

4. Build a signed release `.aab` only after confirming the package name is final.

## Before First Upload

- Keep the upload keystore backed up in a private password manager or secure drive.
- Do not commit `android/key.properties`, `.jks`, or `.keystore` files.
- Build and upload an Android App Bundle, not only an APK.
- Confirm the Play Console package name is `com.childhood.pocketobservatory`.
- Confirm target SDK API 36 is acceptable for the intended release date.

## Build Command

```powershell
flutter build appbundle --release
```
