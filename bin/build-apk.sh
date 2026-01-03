#!/bin/bash
# Build script for Android APK
# This script builds the release APK for the Geo Spider Android application.
# It can be used both locally and in CI/CD pipelines.

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_ROOT}"

# Function to print colored messages
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."
    
    # Check Java
    if ! command -v java &> /dev/null; then
        error "Java is not installed. Please install JDK 17 or later."
        exit 1
    fi
    
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "${JAVA_VERSION}" -lt 17 ]; then
        error "Java 17 or later is required. Found: ${JAVA_VERSION}"
        exit 1
    fi
    info "Java version: $(java -version 2>&1 | head -n 1)"
    
    # Check Gradle wrapper
    if [ ! -f "${PROJECT_ROOT}/gradlew" ]; then
        error "Gradle wrapper (gradlew) not found in project root."
        exit 1
    fi
    
    # Make gradlew executable
    chmod +x "${PROJECT_ROOT}/gradlew"
    
    # Check Android SDK
    if [ -z "${ANDROID_HOME:-}" ] && [ -z "${ANDROID_SDK_ROOT:-}" ]; then
        # Try to find Android SDK in common locations
        if [ -d "${HOME}/Android/Sdk" ]; then
            export ANDROID_HOME="${HOME}/Android/Sdk"
            export ANDROID_SDK_ROOT="${HOME}/Android/Sdk"
            info "Found Android SDK at: ${ANDROID_HOME}"
        elif [ -d "/usr/lib/android-sdk" ]; then
            export ANDROID_HOME="/usr/lib/android-sdk"
            export ANDROID_SDK_ROOT="/usr/lib/android-sdk"
            info "Found Android SDK at: ${ANDROID_HOME}"
        else
            warn "ANDROID_HOME not set and Android SDK not found in common locations."
            warn "Please set ANDROID_HOME environment variable or create local.properties file."
        fi
    else
        if [ -n "${ANDROID_HOME:-}" ]; then
            info "Using Android SDK: ${ANDROID_HOME}"
        elif [ -n "${ANDROID_SDK_ROOT:-}" ]; then
            export ANDROID_HOME="${ANDROID_SDK_ROOT}"
            info "Using Android SDK: ${ANDROID_HOME}"
        fi
    fi
    
    # Create or update local.properties if Android SDK is found
    if [ -n "${ANDROID_HOME:-}" ] && [ ! -f "${PROJECT_ROOT}/local.properties" ]; then
        info "Creating local.properties file..."
        echo "sdk.dir=${ANDROID_HOME}" > "${PROJECT_ROOT}/local.properties"
    elif [ -n "${ANDROID_HOME:-}" ] && [ -f "${PROJECT_ROOT}/local.properties" ]; then
        # Update local.properties if ANDROID_HOME is set and different
        CURRENT_SDK=$(grep "^sdk.dir=" "${PROJECT_ROOT}/local.properties" | cut -d'=' -f2 || echo "")
        if [ "${CURRENT_SDK}" != "${ANDROID_HOME}" ]; then
            info "Updating local.properties with Android SDK path..."
            sed -i "s|^sdk.dir=.*|sdk.dir=${ANDROID_HOME}|" "${PROJECT_ROOT}/local.properties"
        fi
    fi
}

# Accept Android SDK licenses (for local builds)
accept_licenses() {
    if [ -z "${ANDROID_HOME:-}" ]; then
        return 0
    fi
    
    info "Checking Android SDK licenses..."
    
    LICENSES_DIR="${ANDROID_HOME}/licenses"
    
    # Try to create licenses directory and files
    if [ ! -d "${LICENSES_DIR}" ]; then
        if mkdir -p "${LICENSES_DIR}" 2>/dev/null; then
            info "Created licenses directory: ${LICENSES_DIR}"
        else
            warn "Cannot create licenses directory (may need sudo). Trying user directory..."
            # Try user's .android/licenses directory
            USER_LICENSES_DIR="${HOME}/.android/licenses"
            mkdir -p "${USER_LICENSES_DIR}" 2>/dev/null || true
            if [ -d "${USER_LICENSES_DIR}" ]; then
                # Create license files in user directory
                echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" > "${USER_LICENSES_DIR}/android-sdk-license" 2>/dev/null || true
                echo "601085b94cd77f0b54ff864069570f3" > "${USER_LICENSES_DIR}/android-sdk-preview-license" 2>/dev/null || true
                info "Created license files in user directory: ${USER_LICENSES_DIR}"
            fi
            return 0
        fi
    fi
    
    # Check if licenses are already accepted
    if [ -f "${LICENSES_DIR}/android-sdk-license" ]; then
        info "Android SDK licenses appear to be accepted."
        return 0
    fi
    
    # Try to create license files
    if [ -w "${LICENSES_DIR}" ]; then
        info "Creating license acceptance files..."
        echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" > "${LICENSES_DIR}/android-sdk-license" 2>/dev/null || {
            warn "Could not write license file. May need sudo."
        }
        echo "601085b94cd77f0b54ff864069570f3" > "${LICENSES_DIR}/android-sdk-preview-license" 2>/dev/null || true
        if [ -f "${LICENSES_DIR}/android-sdk-license" ]; then
            info "License files created successfully."
            return 0
        fi
    fi
    
    # Try to accept licenses using sdkmanager if available
    SDKMANAGER=""
    if [ -f "${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager" ]; then
        SDKMANAGER="${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager"
    elif [ -f "${ANDROID_HOME}/tools/bin/sdkmanager" ]; then
        SDKMANAGER="${ANDROID_HOME}/tools/bin/sdkmanager"
    fi
    
    if [ -n "${SDKMANAGER}" ]; then
        info "Accepting Android SDK licenses using sdkmanager..."
        yes | "${SDKMANAGER}" --licenses > /dev/null 2>&1 || {
            warn "Could not automatically accept licenses. You may need to run: ${SDKMANAGER} --licenses"
        }
    else
        warn "sdkmanager not found and cannot create license files."
        warn "If build fails due to licenses, run: sudo ./bin/accept-android-licenses.sh"
    fi
}

# Clean previous builds
clean_build() {
    info "Cleaning previous builds..."
    "${PROJECT_ROOT}/gradlew" clean --no-daemon || {
        warn "Clean failed, continuing with build..."
    }
}

# Build the APK
build_apk() {
    info "Building release APK..."
    
    BUILD_CMD=(
        "${PROJECT_ROOT}/gradlew"
        ":androidApp:assembleRelease"
        "--no-daemon"
        "--stacktrace"
    )
    
    # In CI/CD, we might want to suppress some output
    if [ "${CI:-false}" = "true" ]; then
        BUILD_CMD+=("--quiet")
    fi
    
    if ! "${BUILD_CMD[@]}"; then
        error "Build failed!"
        error "Common issues:"
        error "  1. Android SDK licenses not accepted - run: sdkmanager --licenses"
        error "  2. Missing Android SDK components - install via Android Studio SDK Manager"
        error "  3. Insufficient permissions - check Android SDK directory permissions"
        exit 1
    fi
    
    info "Build completed successfully!"
}

# Find and display APK information
display_apk_info() {
    APK_DIR="${PROJECT_ROOT}/geo-spider-app/androidApp/build/outputs/apk/release"
    
    if [ ! -d "${APK_DIR}" ]; then
        error "APK output directory not found: ${APK_DIR}"
        exit 1
    fi
    
    APK_FILE=$(find "${APK_DIR}" -name "*.apk" -type f | head -1)
    
    if [ -z "${APK_FILE}" ]; then
        error "APK file not found in ${APK_DIR}"
        exit 1
    fi
    
    APK_SIZE=$(du -h "${APK_FILE}" | cut -f1)
    
    info "APK built successfully!"
    echo ""
    echo "  Location: ${APK_FILE}"
    echo "  Size: ${APK_SIZE}"
    echo ""
    
    # In CI/CD, output the path for artifact upload
    if [ "${CI:-false}" = "true" ] && [ -n "${GITHUB_OUTPUT:-}" ]; then
        echo "apk-path=${APK_FILE}" >> "${GITHUB_OUTPUT}"
    elif [ "${CI:-false}" = "true" ]; then
        # Fallback: output to stdout in a format that can be parsed
        echo "::set-output name=apk-path::${APK_FILE}"
    fi
    
    # Installation instructions for local builds
    if [ "${CI:-false}" != "true" ]; then
        info "To install on a connected device:"
        echo "  adb install ${APK_FILE}"
        echo ""
        info "Or use Gradle:"
        echo "  ./gradlew :androidApp:installRelease"
    fi
}

# Main execution
main() {
    info "Starting APK build process..."
    echo ""
    
    check_prerequisites
    echo ""
    
    accept_licenses
    echo ""
    
    clean_build
    echo ""
    
    build_apk
    echo ""
    
    display_apk_info
}

# Run main function
main "$@"
