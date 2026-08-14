import java.io.FileInputStream
import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val releaseKeystoreConfigured =
    hasReleaseKeystore &&
        listOf("keyAlias", "keyPassword", "storeFile", "storePassword").all { key ->
            !keystoreProperties.getProperty(key).isNullOrBlank()
        }

check(!hasReleaseKeystore || releaseKeystoreConfigured) {
    "android/key.properties exists but is missing one or more required values: " +
        "keyAlias, keyPassword, storeFile, storePassword."
}

val adMobAndroidAppId = providers.gradleProperty("ADMOB_ANDROID_APP_ID")
    .orElse("ca-app-pub-3940256099942544~3347511713")
    .get()

android {
    namespace = "com.childhood.dotsandboxes"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.childhood.dotsandboxes"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["adMobApplicationId"] = adMobAndroidAppId
    }

    signingConfigs {
        create("release") {
            if (releaseKeystoreConfigured) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            if (releaseKeystoreConfigured) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

flutter {
    source = "../.."
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}
