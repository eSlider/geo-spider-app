# Geo Spider App - Kotlin Multiplatform

A sophisticated GPS/GLONASS location tracking Android application built with Kotlin Multiplatform and Jetpack Compose.

## Project Status

### Current Implementation
- ✅ Kotlin Multiplatform project structure
- ✅ Android app with Jetpack Compose UI
- ✅ Shared common code for business logic
- ✅ Location data models and services
- ✅ Modern Material Design 3 UI

### Architecture

```
geo-spider-app/
├── shared/              # Shared Kotlin Multiplatform module
│   ├── commonMain/      # Common business logic
│   └── androidMain/     # Android-specific implementations
└── androidApp/          # Android application module
    └── src/main/        # Android app code
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

### Build APK

```bash
./gradlew :androidApp:assembleRelease
```

The APK will be generated at:
`geo-spider-app/androidApp/build/outputs/apk/release/androidApp-release.apk`

### Build Debug APK

```bash
./gradlew :androidApp:assembleDebug
```

### Install on Device

```bash
./gradlew :androidApp:installDebug
```

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

## License

MIT License - see [LICENSE](LICENSE) file for details.
