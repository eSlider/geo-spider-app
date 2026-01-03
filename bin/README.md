# Scripts Directory

This directory contains utility scripts for the Geo Spider App project.

## Available Scripts

### `build-apk.sh`

Builds the Android APK for the Kotlin Multiplatform application.

**Usage:**
```bash
./bin/build-apk.sh
```

**Requirements:**
- JDK 17 or later
- Android SDK (for local builds)
- Gradle wrapper (automatically used if available)

**What it does:**
1. Checks prerequisites (Java, Gradle)
2. Cleans previous builds
3. Builds the release APK using Gradle
4. Displays APK location and size
5. Provides installation instructions

**Output:**
- APK file: `geo-spider-app/androidApp/build/outputs/apk/release/*.apk`
