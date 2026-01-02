# Geo Spider App - Build Scripts

This directory contains build scripts for creating Android APK files for the Geo Spider MAUI application.

## Prerequisites

Before running the build scripts, ensure you have the following installed:

1. **.NET 9.0 SDK** - Download from [Microsoft .NET](https://dotnet.microsoft.com/download)
2. **MAUI Workload** - Install with: `dotnet workload install maui`
3. **Android SDK** - Required for Android builds (installed automatically with MAUI)
4. **Java JDK** - Required for Android builds

## Build Scripts

### Linux/macOS (`build-apk.sh`)

```bash
# Make the script executable
chmod +x build/build-apk.sh

# Build with default options (runs tests)
./build/build-apk.sh

# Clean and build
./build/build-apk.sh --clean

# Skip tests
./build/build-apk.sh --skip-tests

# Show help
./build/build-apk.sh --help
```

### Windows (`build-apk.bat`)

```cmd
REM Build with default options (runs tests)
build\build-apk.bat

REM Clean and build
build\build-apk.bat --clean

REM Skip tests
build\build-apk.bat --skip-tests
```

## Signing Configuration

For release builds, you need to configure Android signing. Set the following environment variables:

### Linux/macOS
```bash
export ANDROID_KEYSTORE="/path/to/your/keystore.jks"
export ANDROID_KEY_ALIAS="your_key_alias"
export ANDROID_KEY_PASS="your_key_password"
export ANDROID_STORE_PASS="your_keystore_password"
```

### Windows
```cmd
set ANDROID_KEYSTORE=C:\path\to\your\keystore.jks
set ANDROID_KEY_ALIAS=your_key_alias
set ANDROID_KEY_PASS=your_key_password
set ANDROID_STORE_PASS=your_keystore_password
```

## Build Output

The APK files will be generated in the `build/apk/` directory.

## Troubleshooting

### MAUI Workload Issues
If you get errors about MAUI not being installed:
```bash
dotnet workload install maui
dotnet workload list  # Verify installation
```

### Android SDK Issues
Ensure Android SDK is properly configured. You may need to:
1. Install Android Studio
2. Configure SDK location in environment variables
3. Accept Android SDK licenses

### Build Failures
- Ensure all NuGet packages are restored: `dotnet restore`
- Clean the solution: `dotnet clean`
- Check that all tests pass: `dotnet test`

## CI/CD Integration

These scripts can be integrated into CI/CD pipelines. For example, in GitHub Actions:

```yaml
- name: Build APK
  run: ./build/build-apk.sh --skip-tests
  env:
    ANDROID_KEYSTORE: ${{ secrets.ANDROID_KEYSTORE }}
    ANDROID_KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
    ANDROID_KEY_PASS: ${{ secrets.ANDROID_KEY_PASS }}
    ANDROID_STORE_PASS: ${{ secrets.ANDROID_STORE_PASS }}
```