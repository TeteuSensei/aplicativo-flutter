plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "br.com.teteusensei.consultoria_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "26.1.10909125" // <- fix

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_11.toString() }

    defaultConfig {
        applicationId = "br.com.teteusensei.consultoria_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release { signingConfig = signingConfigs.getByName("debug") }
    }

    // opcional (plano B)
    // packaging { jniLibs { keepDebugSymbols += setOf("**/*.so") } }
}

flutter { source = "../.." }
