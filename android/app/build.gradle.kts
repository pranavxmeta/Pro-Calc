plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    ndkVersion = "29.0.14206865"
    namespace = "com.example.myapp"
    compileSdk = flutter.compileSdkVersion
    // ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21)
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.myapp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 31
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // buildTypes {
    //     release {
    //         // TODO: Add your own signing config for the release build.
    //         // Signing with the debug keys for now, so `flutter run --release` works.
    //         // signingConfig = signingConfigs.getByName("debug")
    //     }
    // }

    //signingConfigs {
        //create("release") {
      //      // Only configure signing if not in CI
            //if (System.getenv("CI") != "true") {
               // val storeFilePath = System.getenv("ANDROID_STORE_FILE") ?: project.property("MYAPP_RELEASE_STORE_FILE").toString()
                //println("Store file path: $storeFilePath")
                //storeFile = file(storeFilePath)
              //  storePassword = System.getenv("ANDROID_STORE_PASSWORD") ?: project.property("MYAPP_RELEASE_STORE_PASSWORD").toString()
           ///     keyAlias = System.getenv("ANDROID_KEY_ALIAS") ?: project.property("MYAPP_RELEASE_KEY_ALIAS").toString()
         //       keyPassword = System.getenv("ANDROID_KEY_PASSWORD") ?: project.property("MYAPP_RELEASE_KEY_PASSWORD").toString()
       //     }
     //   }
    // }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            // signingConfig = if (System.getenv("CI") == "true") null else signingConfigs.getByName("release")
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

}

flutter {
    source = "../.."
}
