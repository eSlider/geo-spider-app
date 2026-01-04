# Contributing to Geo Spider App

Thank you for your interest in contributing to Geo Spider App! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Coding Guidelines](#coding-guidelines)
- [Building and Testing](#building-and-testing)
- [Version Management](#version-management)
- [Submitting Changes](#submitting-changes)
- [Pull Request Process](#pull-request-process)
- [Commit Message Guidelines](#commit-message-guidelines)

> **Note**: Please review our [Code of Conduct](CODE_OF_CONDUCT.md) before contributing.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/geo-spider-app.git
   cd geo-spider-app
   ```
3. **Add the upstream repository**:
   ```bash
   git remote add upstream https://github.com/eSlider/geo-spider-app.git
   ```

## Development Setup

### Prerequisites

- **Android Studio**: Hedgehog (2023.1.1) or later
- **JDK**: 17 or later
- **Android SDK**: API level 21+ (Android 5.0+)
- **Gradle**: 8.0+ (included via wrapper)
- **Git**: Latest version

### Initial Setup

1. **Install Android SDK**:
   - Download and install Android Studio
   - Install Android SDK Platform 35
   - Install Android SDK Build-Tools 35.0.0

2. **Configure Android SDK**:
   - Set `ANDROID_HOME` environment variable:
     ```bash
     export ANDROID_HOME=$HOME/Android/Sdk
     export ANDROID_SDK_ROOT=$HOME/Android/Sdk
     ```
   - Or create `local.properties` file:
     ```properties
     sdk.dir=/path/to/android/sdk
     ```

3. **Accept Android SDK Licenses**:
   ```bash
   ./bin/accept-android-licenses.sh
   ```

4. **Verify Setup**:
   ```bash
   ./gradlew :androidApp:assembleDebug
   ```

## Project Structure

```
geo-spider-app/
├── shared/                    # Kotlin Multiplatform shared module
│   ├── src/
│   │   ├── commonMain/        # Common business logic, data models, interfaces
│   │   └── androidMain/       # Android-specific implementations
│   └── build.gradle.kts
├── androidApp/                # Android application module
│   ├── src/main/              # Android app code (Compose UI)
│   └── build.gradle.kts
bin/                           # Build and utility scripts
var/logs/                      # Build logs (gitignored)
docs/                          # Documentation
.github/workflows/             # CI/CD workflows
```

## Coding Guidelines

### General Principles

- **Follow TDD**: Write tests first, then implement
- **DRY**: Don't Repeat Yourself
- **KISS**: Keep It Simple, Stupid
- **YAGNI**: You Aren't Gonna Need It
- **Use strict types**: Avoid `Any`, `Unit` when specific types are available
- **Functional over OOP**: Prefer functional programming when appropriate
- **Clean functions**: No hidden changes, no in-place mutations

### Kotlin Style

- Follow [Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html)
- Use PascalCase for files: `LocationService.kt`
- Use camelCase for variables and functions
- Use UPPER_SNAKE_CASE for constants
- Prefer `suspend` functions for async operations
- Use coroutines over callbacks
- Use data classes for models
- Use sealed classes/interfaces for state management

### Android Guidelines

- **Use Jetpack Compose** for UI (no XML layouts)
- Follow Material Design 3 guidelines
- Use ViewModel for state management
- Implement proper lifecycle awareness
- Request permissions at runtime
- Handle location services gracefully
- Support dark theme
- Make components reusable and composable

### Architecture

- Follow clean architecture principles
- Separate business logic (shared module) from platform-specific code
- Use interfaces for platform abstractions
- Keep UI components simple and composable
- Use dependency injection (consider Koin or manual DI)

### Error Handling

- Use Result types or sealed classes for error handling
- Never silently fail - log errors appropriately
- Provide user-friendly error messages
- Handle network errors gracefully
- Validate location data (latitude/longitude ranges)

### Comments

- Write comments **ONLY in English**
- Document public APIs
- Add comments for complex logic
- Keep comments up-to-date with code changes

## Building and Testing

### Build APK

**Using build script (recommended):**
```bash
./bin/build-apk.sh
```

**Using Gradle directly:**
```bash
./gradlew :androidApp:assembleRelease
```

**Build with specific version:**
```bash
./gradlew :androidApp:assembleRelease \
  -PVERSION_NAME="1.0.1" \
  -PVERSION_CODE="2"
```

### Build Debug APK

```bash
./gradlew :androidApp:assembleDebug
```

### Install on Device

```bash
./gradlew :androidApp:installDebug
```

### Running Tests

```bash
# Run all tests
./gradlew test

# Run tests for specific module
./gradlew :shared:test
./gradlew :androidApp:test
```

### Build Logs

Build logs are automatically saved to `var/logs/` with timestamps:
- Format: `build_YYYYMMDD_HHMMSS.log`
- Logs are gitignored (not committed)

## Version Management

### Automatic Versioning (CI/CD)

- **No manual updates needed** for CI/CD builds
- Version is automatically calculated from git tags
- Each build increments the patch version (e.g., `1.0.0` → `1.0.1`)
- Version is passed to Gradle build and used for releases

### Local Development

For local builds, you can:

1. **Use gradle.properties**:
   ```properties
   VERSION_NAME=1.0.0
   VERSION_CODE=1
   ```

2. **Pass version via command line**:
   ```bash
   ./gradlew :androidApp:assembleRelease \
     -PVERSION_NAME="1.0.1" \
     -PVERSION_CODE="2"
   ```

### Version Priority

1. Build parameters (`-P`) - highest priority
2. `gradle.properties` - fallback
3. Default (`1.0.0`, code `1`) - if nothing is set

## Submitting Changes

### Workflow

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

2. **Make your changes**:
   - Write tests first (TDD)
   - Implement the feature
   - Ensure all tests pass
   - Update documentation if needed

3. **Test your changes**:
   ```bash
   ./gradlew test
   ./gradlew :androidApp:assembleDebug
   ```

4. **Commit your changes** (see [Commit Message Guidelines](#commit-message-guidelines))

5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request** on GitHub

### Before Submitting

- [ ] All tests pass
- [ ] Code follows project style guidelines
- [ ] Documentation is updated (if needed)
- [ ] No build warnings or errors
- [ ] Commit messages follow guidelines
- [ ] Changes are focused and minimal

## Pull Request Process

### PR Requirements

1. **Clear description** of what the PR does
2. **Reference issues** if applicable (e.g., "Fixes #123")
3. **Screenshots** for UI changes
4. **Test coverage** for new features
5. **Documentation updates** if needed

### PR Review

- Maintainers will review your PR
- Address review comments promptly
- Keep PRs focused and small when possible
- Rebase on latest `main` if requested

### After Approval

- Maintainers will merge your PR
- CI/CD will automatically build and test
- If merged to `main`, a new release will be created automatically

## Commit Message Guidelines

Follow [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `build`: Build system changes
- `ci`: CI/CD changes

### Examples

```
feat(location): add GPS accuracy filtering

Add filtering for GPS locations based on accuracy threshold.
Locations with accuracy worse than 50 meters are now filtered out.

Fixes #123
```

```
fix(ui): correct dark theme colors

Update Material Design 3 color scheme for better dark theme support.
```

```
docs: update README with build instructions

Add detailed instructions for building the APK locally.
```

### Best Practices

- Use imperative mood ("add" not "added" or "adds")
- Keep subject line under 50 characters
- Capitalize first letter of subject
- No period at end of subject
- Reference issues in footer: `Fixes #123` or `Closes #456`

## Development Tips

### Debugging

- Use Android Studio's debugger
- Check build logs in `var/logs/`
- Use `adb logcat` for runtime logs:
  ```bash
  adb logcat | grep GeoSpider
  ```

### Code Quality

- Run linter: `./gradlew lint`
- Format code: Use Android Studio's auto-format (Ctrl+Alt+L / Cmd+Option+L)
- Check for unused imports and code

### Performance

- Minimize battery usage for background location tracking
- Batch location updates when possible
- Use appropriate update intervals
- Cache location data locally before syncing

### Testing

- Write unit tests for business logic
- Test location services with mock data
- Test error scenarios
- Use descriptive test names
- Aim for high test coverage

## Getting Help

- **Issues**: Open an issue on GitHub for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions
- **Documentation**: Check `README.md` and `docs/` directory

## Additional Resources

- [Code of Conduct](CODE_OF_CONDUCT.md) - Community guidelines and standards
- [README.md](README.md) - Project overview and setup instructions
- [.cursorrules](.cursorrules) - Detailed coding guidelines and best practices

## License

By contributing, you agree that your contributions will be licensed under the MIT License (see [LICENSE](LICENSE) file).

---

Thank you for contributing to Geo Spider App! 🕷️

