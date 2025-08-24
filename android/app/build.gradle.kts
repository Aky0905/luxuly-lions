plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase 플러그인
}

android {
    namespace = "com.example.hahaha"
    compileSdk = 35             // 직접 숫자로 지정
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.hahaha"
        minSdk = 23
        targetSdk = 33
        versionCode = 1 
        versionName = "1.0.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.4.0"))
    implementation("com.google.firebase:firebase-analytics")
}

flutter {
    source = "../.."
}
