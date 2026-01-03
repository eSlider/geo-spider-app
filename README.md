# Geo Spider App - Kotlin Multiplatform

A sophisticated GPS/GLONASS location tracking Android application built with Kotlin Multiplatform and Jetpack Compose.

## Project Status

### Current Implementation
- ✅ Kotlin Multiplatform project structure
- ✅ Android app with Jetpack Compose UI
- ✅ Shared common code for business logic
- ✅ Location data models and services
- ✅ Modern Material Design 3 UI
- ✅ Automated CI/CD with GitHub Actions
- ✅ Semantic versioning and automated releases
- ✅ Build logging and artifact management

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

- **Android Studio**: Hedgehog (2023.1.1) or later
- **JDK**: 17 or later
- **Android SDK**: API level 21+ (Android 5.0+)
- **Gradle**: 8.0+

## Building

### Build APK (Recommended)

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

## Version Management

The project uses **Semantic Versioning** (MAJOR.MINOR.PATCH).

### Version Configuration

Version is managed in `gradle.properties`:
```properties
VERSION_NAME=1.0.0
VERSION_CODE=1
```

- **VERSION_NAME**: Semantic version (e.g., `1.0.0`)
- **VERSION_CODE**: Integer that increments with each build

### Version Updates

1. Update `VERSION_NAME` in `gradle.properties` for semantic changes
2. Increment `VERSION_CODE` for each build
3. The version is automatically used in the APK build
4. Git tags are created as `v{VERSION_NAME}` (e.g., `v1.0.0`)

### Automated Releases

On successful builds to the `main` branch:
- ✅ Git tag is created: `v{VERSION_NAME}`
- ✅ GitHub release is created with the APK attached
- ✅ Build logs are uploaded as artifacts
- ✅ Release notes are automatically generated

## CI/CD

### GitHub Actions

The project uses GitHub Actions for automated builds and releases.

**Workflow**: `.github/workflows/build-android-apk.yml`

**Triggers**:
- Push to `main` or `develop` branches
- Pull requests to `main`
- Manual workflow dispatch

**What it does**:
1. Sets up JDK 17 and Android SDK
2. Caches Gradle dependencies
3. Builds the release APK
4. Uploads build logs (7 days retention)
5. Uploads APK artifact (30 days retention)
6. Creates git tag (main branch only)
7. Creates GitHub release (main branch only)

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

### Project Structure

- **shared/commonMain**: Shared business logic, data models, interfaces
- **shared/androidMain**: Android-specific implementations (location provider, etc.)
- **androidApp**: Android application with Compose UI

### Key Components

- `LocationData`: Location data model with validation
- `AppConfig`: Application configuration
- `LocationService`: Location service interface and implementation
- `AndroidLocationProvider`: Android-specific location provider

## Configuration

Configuration is currently hardcoded in the app. Future versions will support:
- YAML configuration files
- Runtime configuration updates
- Server endpoint configuration

## Development

### Project Structure

- **shared/src/commonMain**: Shared business logic, data models, interfaces
- **shared/src/androidMain**: Android-specific implementations (location provider, etc.)
- **androidApp**: Android application with Compose UI

### Key Components

- `LocationData`: Location data model with validation
- `AppConfig`: Application configuration
- `LocationService`: Location service interface and implementation
- `AndroidLocationProvider`: Android-specific location provider

### Code Style

See [.cursorrules](.cursorrules) for detailed coding guidelines and best practices.

### Building Locally

1. Ensure prerequisites are met (see Prerequisites section)
2. Set up Android SDK (set `ANDROID_HOME` or create `local.properties`)
3. Accept Android SDK licenses: `./bin/accept-android-licenses.sh`
4. Build: `./bin/build-apk.sh`

### Troubleshooting

**Build fails with "SDK licenses not accepted"**:
```bash
./bin/accept-android-licenses.sh
```

**Build fails with "Android SDK not found"**:
- Set `ANDROID_HOME` environment variable
- Or create `local.properties` with: `sdk.dir=/path/to/android/sdk`

**APK not found after build**:
- Check build logs in `var/logs/`
- Verify Android SDK is properly configured
- Check GitHub Actions logs for CI/CD builds

## Contributing

1. Follow the coding guidelines in `.cursorrules`
2. Write tests for new features
3. Update documentation as needed
4. Ensure builds pass before submitting PRs

## License

MIT License - see [LICENSE](LICENSE) file for details.
