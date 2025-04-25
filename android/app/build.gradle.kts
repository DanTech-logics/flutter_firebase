plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Correct way to apply the plugin in Kotlin DSL
}

android {
    namespace = "com.fluttersample.demo"
    compileSdk = 35 // Update to SDK 35

    ndkVersion = "27.0.12077973" // Update NDK version to 27.0.12077973

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.fluttersample.demo"
        minSdk = 23
        targetSdk = 35 // Update targetSdk to SDK 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation("com.google.android.gms:play-services-auth:19.2.0")
}

flutter {
    source = "../.."
}
