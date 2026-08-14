plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val admobAndroidAppId: String =
    (project.findProperty("ADMOB_ANDROID_APP_ID") as String?)
        ?: System.getenv("ADMOB_ANDROID_APP_ID")
        // Google sample AdMob app ID. Override before production Android ads.
        ?: "ca-app-pub-3940256099942544~3347511713"

android {
    namespace = "com.childhood.larderlabels"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.childhood.larderlabels"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["admobApplicationId"] = admobAndroidAppId
    }

    buildTypes {
        release {
            // Production release signing must be configured before Play upload.
            // Keep release unsigned until a real upload keystore is wired here.
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
