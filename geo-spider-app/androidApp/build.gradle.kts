plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    id("org.jetbrains.kotlin.plugin.compose") version "2.0.21"
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

android {
    namespace = "com.geospider.android"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.geospider.android"
        minSdk = 21
        targetSdk = 35
        // Version priority: Build parameter (-P) > gradle.properties > default
        // Build parameters are passed via -PVERSION_NAME and -PVERSION_CODE
        // project.findProperty() reads from both -P parameters and gradle.properties
        versionCode = project.findProperty("VERSION_CODE")?.toString()?.toIntOrNull() ?: 1
        versionName = project.findProperty("VERSION_NAME")?.toString() ?: "1.0.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }
    
    kotlinOptions {
        jvmTarget = "21"
        freeCompilerArgs += listOf(
            "-opt-in=kotlin.RequiresOptIn",
            "-Xjvm-default=all"
        )
    }
    
    buildFeatures {
        compose = true
    }
    
    lint {
        checkReleaseBuilds = false
        abortOnError = false
    }
}

dependencies {
    implementation(project(":shared"))
    
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)
    
    implementation(platform(libs.compose.bom))
    implementation(libs.bundles.compose)
    // Ensure compose runtime is on classpath for compiler
    implementation("androidx.compose.runtime:runtime")
    
    implementation(libs.coroutines.android)
    
    debugImplementation(libs.compose.ui.tooling)
}
