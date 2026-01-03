# Scripts Directory

This directory contains utility scripts for the Geo Spider App project.

## Available Scripts

### `build-apk.sh`

Builds the Android APK for the Kotlin Multiplatform application. This script is designed to work both locally and in CI/CD pipelines (GitHub Actions).

**Usage:**
```bash
./bin/build-apk.sh
```

**Requirements:**
- JDK 17 or later
- Android SDK (for local builds)
- Gradle wrapper (automatically used if available)
- Android SDK licenses accepted (see `accept-android-licenses.sh`)

**What it does:**
1. Checks prerequisites (Java version, Gradle wrapper, Android SDK)
2. Creates/updates `local.properties` with Android SDK path
3. Attempts to accept Android SDK licenses automatically
4. Cleans previous builds
5. Builds the release APK using Gradle
6. Displays APK location and size
7. Provides installation instructions (for local builds)
8. Outputs APK path for CI/CD artifact upload

**Output:**
- APK file: `geo-spider-app/androidApp/build/outputs/apk/release/*.apk`

**CI/CD Integration:**
The script automatically detects CI/CD environments and adjusts output accordingly. It's used by the GitHub Actions workflow (`.github/workflows/build-android-apk.yml`).

**Troubleshooting:**
- If build fails due to license issues, run `./bin/accept-android-licenses.sh` first
- If Android SDK is not found, set `ANDROID_HOME` environment variable
- For system-wide Android SDK installations, you may need sudo to accept licenses

### `accept-android-licenses.sh`

Helper script to accept Android SDK licenses for local development.

**Usage:**
```bash
./bin/accept-android-licenses.sh
```

For system-wide Android SDK installations:
```bash
sudo ./bin/accept-android-licenses.sh
```

**What it does:**
1. Automatically finds Android SDK location
2. Attempts to accept licenses using `sdkmanager` if available
3. Falls back to manual license file creation if `sdkmanager` is not found
4. Creates necessary license acceptance files

**Note:**
This script is primarily for local development. CI/CD pipelines (like GitHub Actions) handle license acceptance automatically through their Android SDK setup actions.
