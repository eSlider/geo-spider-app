#!/bin/bash
# Stop Android emulator script
# This script stops all running Android emulators.

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

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
    else
        echo ""
    fi
}

# Find ADB executable
find_adb() {
    ANDROID_SDK=$(get_android_sdk)
    
    if [ -z "${ANDROID_SDK}" ]; then
        # Try to find adb in PATH
        if command -v adb &> /dev/null; then
            command -v adb
            return 0
        fi
        return 1
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
    
    return 1
}

# Check if emulator is running
is_emulator_running() {
    ADB=$(find_adb 2>/dev/null || echo "")
    
    if [ -z "${ADB}" ]; then
        # Check for emulator processes instead
        if pgrep -f "emulator" > /dev/null; then
            return 0
        fi
        return 1
    fi
    
    DEVICES=$("${ADB}" devices 2>/dev/null | grep -E "emulator|device$" | grep -v "List of devices" | wc -l)
    
    if [ "${DEVICES}" -gt 0 ]; then
        return 0
    else
        return 1
    fi
}

# Stop emulator via ADB
stop_via_adb() {
    ADB=$(find_adb)
    
    if [ -z "${ADB}" ]; then
        return 1
    fi
    
    # Get list of emulator devices
    DEVICES=$("${ADB}" devices 2>/dev/null | grep "emulator" | cut -f1)
    
    if [ -z "${DEVICES}" ]; then
        return 1
    fi
    
    for DEVICE in ${DEVICES}; do
        info "Stopping emulator: ${DEVICE}"
        "${ADB}" -s "${DEVICE}" emu kill 2>/dev/null || true
    done
    
    return 0
}

# Stop emulator via process kill
stop_via_process() {
    EMULATOR_PIDS=$(pgrep -f "emulator" || echo "")
    
    if [ -z "${EMULATOR_PIDS}" ]; then
        return 1
    fi
    
    for PID in ${EMULATOR_PIDS}; do
        info "Stopping emulator process: ${PID}"
        kill "${PID}" 2>/dev/null || true
    done
    
    # Wait a bit and force kill if still running
    sleep 2
    for PID in ${EMULATOR_PIDS}; do
        if kill -0 "${PID}" 2>/dev/null; then
            warn "Force killing emulator process: ${PID}"
            kill -9 "${PID}" 2>/dev/null || true
        fi
    done
    
    return 0
}

# Main execution
main() {
    info "Stopping Android emulator..."
    
    if ! is_emulator_running; then
        info "No emulator is currently running"
        return 0
    fi
    
    # Try to stop via ADB first (cleaner)
    if stop_via_adb; then
        info "Emulator stopped via ADB"
        sleep 2
    fi
    
    # Also try to stop via process kill (fallback)
    if is_emulator_running; then
        if stop_via_process; then
            info "Emulator processes terminated"
        fi
    fi
    
    # Final check
    if is_emulator_running; then
        warn "Some emulator processes may still be running"
        warn "You may need to manually close the emulator window"
    else
        info "All emulators stopped successfully"
    fi
}

# Run main function
main "$@"

