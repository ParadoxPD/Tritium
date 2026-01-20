import com.android.build.gradle.internal.api.ApkVariantOutputImpl
import java.text.SimpleDateFormat
import java.util.Date

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.tritium.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.tritium.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    applicationVariants.all {
        val variant = this
        variant.outputs.all {
            if (this is ApkVariantOutputImpl) {
                // Get current date and time for a unique build identifier
                val sdf = SimpleDateFormat("yyyyMMdd_HHmmss")
                val currentDateAndTime = sdf.format(Date())

                // Construct the desired output file name
                val appName = "tritium" // Replace with your app name or retrieve from libs.versions
                val versionName = variant.versionName
                val versionCode = variant.versionCode
                val buildType = variant.buildType.name

                // Example format: MyApp-release-1.0.0-100-20250120_181615.apk
                outputFileName = "${appName}-${buildType}-${versionName}-${versionCode}-${currentDateAndTime}.apk"
            }
        }
    }

}

flutter {
    source = "../.."
}
