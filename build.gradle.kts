// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    id("com.android.application") version "8.8.0" apply false
    id("com.android.library") version "8.8.0" apply false
    id("org.jetbrains.kotlin.multiplatform") version "2.0.21" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.0.21" apply false
}

// Configure Java toolchain for all projects
allprojects {
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "21"
        targetCompatibility = "21"
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.layout.buildDirectory)
}
