# Android Release Signing

Rooftop Rain Garden must not ship with debug signing. The Gradle release block
now uses a release signing config only when `android/key.properties` exists.

## Required Local Files

Create these locally and do not commit them:

- `android/key.properties`
- `android/upload-keystore.jks`

`android/key.properties` should match this shape:

```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=rooftop-rain-garden-upload
storeFile=../upload-keystore.jks
```

The root `.gitignore` and `android/.gitignore` already ignore key properties
and keystore files.

## Before First Play Upload

- Confirm the final application id is `com.rooftopraingarden.app`.
- Enroll in Play App Signing and keep the upload key private.
- Keep a secure backup of the upload keystore and passwords.
- Do not reuse debug keys or sample credentials.
- Do not commit signing secrets, generated app bundles, or release APKs.

## Verification Required Later

This document does not prove release readiness by itself. A signed release
artifact still needs to be built, installed, opened, and manually tested before
internal, closed, or production release.
