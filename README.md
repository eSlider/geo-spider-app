# Geo Spider App - Kotlin Multiplatform

[![Build Status](https://github.com/eSlider/geo-spider-app/workflows/Build%20Android%20APK/badge.svg)](https://github.com/eSlider/geo-spider-app/actions/workflows/build-android-apk.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Kotlin](https://img.shields.io/badge/Kotlin-2.0.21-blue.svg)](https://kotlinlang.org)
[![Kotlin Multiplatform](https://img.shields.io/badge/Kotlin%20Multiplatform-2.0.21-purple.svg)](https://kotlinlang.org/docs/multiplatform.html)
[![Android](https://img.shields.io/badge/Android-5.0%2B-green.svg)](https://www.android.com)
[![Jetpack Compose](https://img.shields.io/badge/Jetpack%20Compose-1.7-blue.svg)](https://developer.android.com/jetpack/compose)
[![Gradle](https://img.shields.io/badge/Gradle-8.9-blue.svg)](https://gradle.org)
[![JDK](https://img.shields.io/badge/JDK-21-orange.svg)](https://adoptium.net)
[![Latest Release](https://img.shields.io/github/v/release/eSlider/geo-spider-app?include_prereleases&sort=semver)](https://github.com/eSlider/geo-spider-app/releases/latest)
[![GitHub Issues](https://img.shields.io/github/issues/eSlider/geo-spider-app)](https://github.com/eSlider/geo-spider-app/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/eSlider/geo-spider-app)](https://github.com/eSlider/geo-spider-app/pulls)
[![GitHub Stars](https://img.shields.io/github/stars/eSlider/geo-spider-app?style=social)](https://github.com/eSlider/geo-spider-app/stargazers)

A sophisticated GPS/GLONASS location tracking Android application built with Kotlin Multiplatform and Jetpack Compose.

## Project Status

### Current Implementation
- Kotlin Multiplatform project structure
- Android app with Jetpack Compose UI
- Shared common code for business logic
- Location data models and services
- Modern Material Design 3 UI
- Automated CI/CD with GitHub Actions
- Semantic versioning and automated releases
- Build logging and artifact management

### Architecture

```
geo-spider-app/
├── shared/                    # Shared Kotlin Multiplatform module
│   ├── src/
│   │   ├── commonMain/        # Common business logic, data models, interfaces
│   │   └── androidMain/       # Android-specific implementations
│   └── build.gradle.kts
├── androidApp/                # Android application module
│   ├── src/main/              # Android app code (Compose UI)
│   └── build.gradle.kts
bin/                           # Build and utility scripts
│   ├── build-apk.sh          # Main build script
│   └── monitor-workflow.sh    # GitHub Actions monitoring
var/logs/                      # Build logs (gitignored)
docs/                          # Documentation
.github/workflows/             # CI/CD workflows
```

## Features

### Core Functionality
- GPS/GLONASS location tracking
- Background location service
- Offline data accumulation
- Automatic synchronization
- Configurable intervals

### Modern UI
- Jetpack Compose
- Material Design 3
- Dark theme support
- Real-time status updates

## Prerequisites

### Option 1: Docker (Recommended for CI/CD and Consistent Builds)

- **Docker**: 20.10+ (for containerized builds)
- **Docker Compose**: 2.0+ (optional, for local development)

### Option 2: Local Development Environment

- **Android Studio**: Hedgehog (2023.1.1) or later
- **JDK**: 21 (LTS, recommended) or 17+
- **Android SDK**: API level 21+ (Android 5.0+)
- **Gradle**: 8.0+

## Building

### Build APK with Docker (Recommended)

Use Docker for consistent, reproducible builds:

```bash
./bin/build-docker.sh
```

This script uses the [budtmo/docker-android](https://github.com/budtmo/docker-android) Docker image which contains:
- Android SDK with command-line tools
- Gradle 8.2
- Android SDK platforms and build tools
- All necessary dependencies

The script will:
- Pull the pre-built Docker image (cached after first use)
- Accept Android SDK licenses automatically
- Install additional SDK components if needed (API 35, build-tools 35.0.0)
- Build the release APK inside the container
- Save build logs to `var/logs/`
- Copy APK to `build-outputs/` directory
- Display APK information

**Benefits of Docker builds:**
- Consistent build environment across all machines
- No need to install Android SDK locally
- Isolated build environment
- Faster CI/CD pipelines (uses pre-built image)
- Well-maintained and actively updated Docker image (13.9k+ stars)

### Build APK Locally (Without Docker)

Use the build script which handles prerequisites, logging, and versioning:

```bash
./bin/build-apk.sh
```

The script will:
- Check prerequisites (Java, Gradle, Android SDK)
- Accept Android SDK licenses
- Clean previous builds
- Build the release APK
- Save build logs to `var/logs/`
- Display APK information

The APK will be generated at:
`geo-spider-app/androidApp/build/outputs/apk/release/androidApp-release-unsigned.apk`

### Build with Gradle Directly

```bash
./gradlew :androidApp:assembleRelease
```

### Build Debug APK

```bash
./gradlew :androidApp:assembleDebug
```

### Install on Device

```bash
./gradlew :androidApp:installDebug
```

### Docker Compose (Alternative)

For interactive development with Docker:

```bash
# Start container
docker-compose up -d

# Execute commands inside container
docker-compose exec android-builder ./gradlew :androidApp:assembleRelease

# Stop container
docker-compose down
```

## Version Management

The project uses **Semantic Versioning** (MAJOR.MINOR.PATCH) with **automatic version calculation from git tags**.

### Automatic Version Calculation

**In CI/CD (GitHub Actions):**
- The workflow automatically calculates the next version from existing git tags
- Finds the latest tag (e.g., `v1.0.0`)
- Increments the patch version (e.g., `1.0.0` → `1.0.1`)
- Uses this version for the Gradle build and GitHub release
- Creates a new tag with the calculated version

**Version Priority:**
1. **Build parameters** (`-PVERSION_NAME`, `-PVERSION_CODE`) - highest priority
2. **gradle.properties** - fallback for local builds
3. **Default** (`1.0.0`, code `1`) - if nothing else is set

### Version Configuration

For **local builds**, you can set version in `gradle.properties`:
```properties
VERSION_NAME=1.0.0
VERSION_CODE=1
```

Or pass it directly to Gradle:
```bash
./gradlew :androidApp:assembleRelease -PVERSION_NAME="1.0.1" -PVERSION_CODE="2"
```

### Version Updates

**Automatic (CI/CD):**
- No manual updates needed!
- Each successful build to `main` automatically:
  1. Calculates next version from latest git tag
  2. Builds APK with that version
  3. Creates git tag `v{VERSION_NAME}`
  4. Creates GitHub release with the version

**Manual (Local):**
- Update `VERSION_NAME` in `gradle.properties` for local testing
- Or use `-P` parameters when building

### Automated Releases

On successful builds to the `main` branch:
- Git tag is created: `v{VERSION_NAME}`
- GitHub release is created with the APK attached
- Build logs are uploaded as artifacts
- Release notes are automatically generated

## CI/CD

### GitHub Actions with Docker

The project uses GitHub Actions with Docker for automated builds and releases.

**Workflow**: `.github/workflows/build-android-apk.yml`

**Triggers**:
- Push to `main` or `develop` branches
- Pull requests to `main`
- Manual workflow dispatch

**What it does**:
1. Builds Docker image with Android SDK and build tools (cached for faster builds)
2. Calculates next version from git tags
3. Builds the release APK inside Docker container with calculated version
4. Uploads build logs (7 days retention)
5. Uploads APK artifact (30 days retention)
6. Creates git tag (main branch only)
7. Creates GitHub release (main branch only)

**Docker-based CI/CD Benefits**:
- Consistent build environment across all runs
- Faster builds using pre-built [budtmo/docker-android](https://github.com/budtmo/docker-android)
- Isolated build environment
- Easy to reproduce builds locally
- No need to manage Android SDK versions in CI
- Well-maintained Docker image with regular updates

### Monitoring Workflows

Monitor workflow status:

```bash
./bin/monitor-workflow.sh
```

Or manually check:
- [GitHub Actions](https://github.com/eSlider/geo-spider-app/actions)
- [Releases](https://github.com/eSlider/geo-spider-app/releases)

### Build Logs

Build logs are automatically saved to `var/logs/` with timestamps:
- Format: `build_YYYYMMDD_HHMMSS.log`
- Logs are gitignored (not committed)
- Available as artifacts in GitHub Actions

## Releases

### Download Releases

1. Go to [Releases](https://github.com/eSlider/geo-spider-app/releases)
2. Download the APK from the latest release
3. Install on your Android device

### Release Process

Releases are **automatically created** on successful builds to `main`:
- Tag format: `v1.0.0` (semantic version)
- Release includes:
  - APK file
  - Build logs
  - Automatic release notes
  - Commit information

### Manual Release

To create a release manually:
1. Update version in `gradle.properties`
2. Commit and push to `main`
3. GitHub Actions will automatically create the release

## Development

For detailed development information, setup instructions, coding guidelines, and troubleshooting, please see [CONTRIBUTING.md](CONTRIBUTING.md).

### Quick Start for Developers

1. **Fork and clone** the repository
2. **Set up development environment** (see [CONTRIBUTING.md](CONTRIBUTING.md#development-setup))
3. **Build the project**:
   ```bash
   ./bin/build-apk.sh
   ```
4. **Read the guidelines** in [CONTRIBUTING.md](CONTRIBUTING.md) before making changes

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines on how to contribute to this project, including development setup, coding standards, and pull request process.

Please review our [Code of Conduct](CODE_OF_CONDUCT.md) before contributing.

## License

MIT License - see [LICENSE](LICENSE) file for details.
