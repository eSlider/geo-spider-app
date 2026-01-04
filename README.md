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
1. Sets up JDK 17 and Android SDK (with caching for faster builds)
2. Caches Gradle dependencies and Android SDK components
3. Calculates next version from git tags
4. Builds the release APK with calculated version
5. Uploads build logs (7 days retention)
6. Uploads APK artifact (30 days retention)
7. Creates git tag (main branch only)
8. Creates GitHub release (main branch only)

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

### Configuration

Configuration is currently hardcoded in the app. Future versions will support:
- YAML configuration files
- Runtime configuration updates
- Server endpoint configuration

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

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to this project.

**Quick start:**
1. Fork the repository
2. Create a feature branch
3. Make your changes following the [coding guidelines](.cursorrules)
4. Write tests for new features
5. Submit a pull request

For detailed contribution guidelines, including development setup, coding standards, and pull request process, see [CONTRIBUTING.md](CONTRIBUTING.md).

**Code of Conduct**: Please review our [Code of Conduct](CODE_OF_CONDUCT.md) before contributing.

## License

MIT License - see [LICENSE](LICENSE) file for details.
