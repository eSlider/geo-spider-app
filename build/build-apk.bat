@echo off
REM Geo Spider App - APK Build Script (Windows)
REM This script builds the Android APK for the Geo Spider MAUI application

echo Geo Spider App - APK Build Script
echo ==================================

REM Configuration
set PROJECT_NAME=GeoSpiderApp
set CONFIGURATION=Release
set OUTPUT_DIR=bin\Release\net9.0-android
set APK_OUTPUT_DIR=build\apk

REM Check prerequisites
echo [INFO] Checking prerequisites...

REM Check if dotnet is installed
dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] dotnet CLI is not installed. Please install .NET 9.0 SDK.
    exit /b 1
)

REM Get dotnet version
for /f "tokens=*" %%i in ('dotnet --version') do set DOTNET_VERSION=%%i
echo [INFO] Found .NET version: %DOTNET_VERSION%

REM Check if MAUI workload is installed
dotnet workload list | findstr /C:"maui" >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] MAUI workload not found. Installing...
    dotnet workload install maui
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install MAUI workload.
        exit /b 1
    )
)

echo [INFO] Prerequisites check completed.

REM Clean previous builds
if "%1"=="--clean" (
    echo [INFO] Cleaning previous builds...
    rmdir /s /q "%OUTPUT_DIR%" 2>nul
    rmdir /s /q "%APK_OUTPUT_DIR%" 2>nul
    dotnet clean
)

REM Run tests if not skipped
if not "%1"=="--skip-tests" (
    echo [INFO] Running tests...
    dotnet test --verbosity normal
    if %errorlevel% neq 0 (
        echo [ERROR] Tests failed. Aborting build.
        exit /b 1
    )
    echo [INFO] All tests passed.
)

REM Restore packages
echo [INFO] Restoring NuGet packages...
dotnet restore
if %errorlevel% neq 0 (
    echo [ERROR] Package restore failed.
    exit /b 1
)

REM Build the project
echo [INFO] Building project in %CONFIGURATION% configuration...
dotnet build --configuration %CONFIGURATION% --framework net9.0-android --verbosity normal
if %errorlevel% neq 0 (
    echo [ERROR] Build failed.
    exit /b 1
)
echo [INFO] Build completed successfully.

REM Build APK
echo [INFO] Building APK...
mkdir "%APK_OUTPUT_DIR%" 2>nul

dotnet publish --configuration %CONFIGURATION% --framework net9.0-android --output "%APK_OUTPUT_DIR%" /p:AndroidPackageFormat=apk /p:AndroidSigningKeyStore="%ANDROID_KEYSTORE%" /p:AndroidSigningKeyAlias="%ANDROID_KEY_ALIAS%" /p:AndroidSigningKeyPass="%ANDROID_KEY_PASS%" /p:AndroidSigningStorePass="%ANDROID_STORE_PASS%"
if %errorlevel% neq 0 (
    echo [ERROR] APK build failed.
    exit /b 1
)
echo [INFO] APK build completed successfully.

REM Find the generated APK
for %%f in ("%APK_OUTPUT_DIR%\*.apk") do (
    echo [INFO] APK generated: %%f
    dir "%%f"
    goto :found_apk
)

echo [WARNING] APK file not found in output directory.
goto :end

:found_apk
echo [INFO] Build process completed successfully!
echo [INFO] Check the %APK_OUTPUT_DIR% directory for the generated APK.

:end