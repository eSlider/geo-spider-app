#!/bin/bash
# Development script to run Android app in emulator
# This script starts an Android emulator, builds, installs, and launches the app.

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Get Android SDK path
get_android_sdk() {
    if [ -n "${ANDROID_HOME:-}" ]; then
        echo "${ANDROID_HOME}"
    elif [ -n "${ANDROID_SDK_ROOT:-}" ]; then
        echo "${ANDROID_SDK_ROOT}"
    elif [ -f "${PROJECT_ROOT}/local.properties" ]; then
        SDK_DIR=$(grep "^sdk.dir=" "${PROJECT_ROOT}/local.properties" | cut -d'=' -f2 | tr -d ' ' || echo "")
        if [ -n "${SDK_DIR}" ]; then
            echo "${SDK_DIR}"
        fi
    elif [ -d "${HOME}/Android/Sdk" ]; then
        echo "${HOME}/Android/Sdk"
    elif [ -d "/usr/lib/android-sdk" ]; then
        echo "/usr/lib/android-sdk"
    else
        echo ""
    fi
}

# Find emulator executable
find_emulator() {
    ANDROID_SDK=$(get_android_sdk)
    
    if [ -z "${ANDROID_SDK}" ]; then
        error "Android SDK not found. Please set ANDROID_HOME or configure local.properties"
        exit 1
    fi
    
    # Try common emulator locations
    EMULATOR_PATHS=(
        "${ANDROID_SDK}/emulator/emulator"
        "${HOME}/projects/nai/curasoft/android-sdk/emulator/emulator"
        "$(find "${HOME}" -name "emulator" -type f -executable 2>/dev/null | grep -E "(android|sdk)" | head -1)"
    )
    
    for EMULATOR_PATH in "${EMULATOR_PATHS[@]}"; do
        if [ -n "${EMULATOR_PATH}" ] && [ -f "${EMULATOR_PATH}" ] && [ -x "${EMULATOR_PATH}" ]; then
            echo "${EMULATOR_PATH}"
            return 0
        fi
    done
    
    error "Emulator executable not found. Please install Android emulator."
    exit 1
}

# Find ADB executable
find_adb() {
    ANDROID_SDK=$(get_android_sdk)
    
    if [ -z "${ANDROID_SDK}" ]; then
        error "Android SDK not found."
        exit 1
    fi
    
    ADB_PATH="${ANDROID_SDK}/platform-tools/adb"
    
    if [ -f "${ADB_PATH}" ] && [ -x "${ADB_PATH}" ]; then
        echo "${ADB_PATH}"
        return 0
    fi
    
    # Try to find adb in PATH
    if command -v adb &> /dev/null; then
        command -v adb
        return 0
    fi
    
    error "ADB not found. Please install Android platform-tools."
    exit 1
}

# List available AVDs
list_avds() {
    EMULATOR=$(find_emulator)
    
    if [ -z "${EMULATOR}" ]; then
        return 1
    fi
    
    AVD_DIR="${HOME}/.android/avd"
    if [ ! -d "${AVD_DIR}" ]; then
        warn "No AVD directory found at ${AVD_DIR}"
        return 1
    fi
    
    # List AVDs from .ini files
    find "${AVD_DIR}" -name "*.ini" -type f 2>/dev/null | while read -r ini_file; do
        basename "${ini_file}" .ini
    done
}

# Check if emulator is already running
is_emulator_running() {
    ADB=$(find_adb)
    
    if [ -z "${ADB}" ]; then
        return 1
    fi
    
    DEVICES=$("${ADB}" devices 2>/dev/null | grep -E "emulator|device$" | grep -v "List of devices" | wc -l)
    
    if [ "${DEVICES}" -gt 0 ]; then
        return 0
    else
        return 1
    fi
}

# Start emulator
start_emulator() {
    if is_emulator_running; then
        info "Emulator is already running"
        return 0
    fi
    
    EMULATOR=$(find_emulator)
    AVD_NAME="${1:-}"
    
    if [ -z "${AVD_NAME}" ]; then
        # Try to find an available AVD
        AVAILABLE_AVDS=($(list_avds))
        
        if [ ${#AVAILABLE_AVDS[@]} -eq 0 ]; then
            error "No AVDs found. Please create an AVD using Android Studio."
            exit 1
        fi
        
        # Prefer common AVD names
        for PREFERRED in "gotour_emulator" "Pixel" "Nexus"; do
            for AVD in "${AVAILABLE_AVDS[@]}"; do
                if [[ "${AVD}" == *"${PREFERRED}"* ]]; then
                    AVD_NAME="${AVD}"
                    break 2
                fi
            done
        done
        
        # Fall back to first available
        if [ -z "${AVD_NAME}" ]; then
            AVD_NAME="${AVAILABLE_AVDS[0]}"
        fi
    fi
    
    info "Starting emulator: ${AVD_NAME}"
    info "This may take a minute..."
    
    # Start emulator in background
    "${EMULATOR}" -avd "${AVD_NAME}" -no-snapshot-load > /dev/null 2>&1 &
    EMULATOR_PID=$!
    
    # Wait for emulator to be ready
    ADB=$(find_adb)
    info "Waiting for emulator to boot..."
    
    TIMEOUT=120
    ELAPSED=0
    while [ ${ELAPSED} -lt ${TIMEOUT} ]; do
        if "${ADB}" wait-for-device shell getprop sys.boot_completed 2>/dev/null | grep -q "1"; then
            info "Emulator is ready!"
            return 0
        fi
        sleep 2
        ELAPSED=$((ELAPSED + 2))
        if [ $((ELAPSED % 10)) -eq 0 ]; then
            debug "Still waiting... (${ELAPSED}s/${TIMEOUT}s)"
        fi
    done
    
    error "Emulator failed to start within ${TIMEOUT} seconds"
    kill "${EMULATOR_PID}" 2>/dev/null || true
    exit 1
}

# Build and install app
build_and_install() {
    info "Building and installing debug APK..."
    
    if [ ! -f "${PROJECT_ROOT}/gradlew" ]; then
        error "Gradle wrapper not found"
        exit 1
    fi
    
    chmod +x "${PROJECT_ROOT}/gradlew"
    
    "${PROJECT_ROOT}/gradlew" :androidApp:installDebug --no-daemon || {
        error "Build or installation failed"
        exit 1
    }
    
    info "App installed successfully"
}

# Launch app
launch_app() {
    ADB=$(find_adb)
    PACKAGE_NAME="com.geospider.android"
    
    info "Launching app..."
    
    "${ADB}" shell monkey -p "${PACKAGE_NAME}" -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1 || {
        warn "Failed to launch app using monkey, trying alternative method..."
        "${ADB}" shell am start -n "${PACKAGE_NAME}/.MainActivity" > /dev/null 2>&1 || {
            error "Failed to launch app"
            exit 1
        }
    }
    
    info "App launched successfully"
}

# Main execution
main() {
    info "Starting development environment..."
    echo ""
    
    # Check if AVD name is provided as argument
    AVD_NAME="${1:-}"
    
    start_emulator "${AVD_NAME}"
    echo ""
    
    build_and_install
    echo ""
    
    launch_app
    echo ""
    
    info "Development environment is ready!"
    info "Emulator is running. Use './bin/stop.sh' to stop it."
}

# Run main function
main "$@"

