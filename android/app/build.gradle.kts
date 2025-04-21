plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter Gradle Plugin
}

android {
    namespace = "com.example.projects"
    compileSdk = 35

    ndkVersion = "27.0.12077973" // Correction de la version NDK

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.projects"
        minSdk = 21 // Min SDK recommandé pour Flutter
        targetSdk = 34 // Target SDK mis à jour pour Android 14
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true // Ajout de MultiDex
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            // Supprimer la ligne signingConfig = signingConfigs.getByName("debug") si non nécessaire
        }
    }

    packagingOptions {
        resources.excludes.add("META-INF/DEPENDENCIES")
    }
}

dependencies {
    implementation("com.google.android.material:material:1.9.0") // Ajout de Material Components
    implementation("androidx.core:core-ktx:1.10.1") // Ajout de core-ktx pour compatibilité avec les plugins modernes
}

flutter {
    source = "../.."
}
