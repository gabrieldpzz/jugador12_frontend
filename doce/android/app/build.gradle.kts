plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")           // corrige alias de Kotlin para KTS
    id("dev.flutter.flutter-gradle-plugin")      // Flutter plugin (mantener después de Android/Kotlin)
    id("com.google.gms.google-services")         // <-- Google Services plugin ACTIVADO aquí
}

android {
    namespace = "com.jugador.doce"

    // Usa los valores que expone el plugin de Flutter para compileSdk/targetSdk/ndk
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.jugador.doce"
        // Firebase requiere minSdk 23. Sube explícitamente.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
            // Firma de debug para poder ejecutar release localmente
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // (Opcional pero recomendado) BoM de Firebase para alinear versiones si agregas SDKs nativos
    implementation(platform("com.google.firebase:firebase-bom:34.4.0"))

    // (Opcional) Ejemplo de SDK nativo si quisieras Analytics:
    // implementation("com.google.firebase:firebase-analytics")

    // NOTA: Si usas FlutterFire (firebase_core, firebase_auth), sus plugins ya traen
    // sus dependencias nativas. No es obligatorio listarlas aquí.
}
