plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase 플러그인
}
android {
    namespace = "com.example.hahaha"
    compileSdk = 36             // 직접 숫자로 지정
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.hahaha"
        minSdk = 23
        targetSdk = 36
        versionCode = 1 
        versionName = "1.0.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
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
