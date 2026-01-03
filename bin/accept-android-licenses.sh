#!/bin/bash
# Helper script to accept Android SDK licenses
# This script helps accept Android SDK licenses for local development.

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Find Android SDK
find_android_sdk() {
    if [ -n "${ANDROID_HOME:-}" ]; then
        echo "${ANDROID_HOME}"
        return 0
    elif [ -n "${ANDROID_SDK_ROOT:-}" ]; then
        echo "${ANDROID_SDK_ROOT}"
        return 0
    elif [ -d "${HOME}/Android/Sdk" ]; then
        echo "${HOME}/Android/Sdk"
        return 0
    elif [ -d "/usr/lib/android-sdk" ]; then
        echo "/usr/lib/android-sdk"
        return 0
    else
        return 1
    fi
}

# Accept licenses using sdkmanager
accept_with_sdkmanager() {
    local sdk_path="$1"
    local sdkmanager=""
    
    # Try to find sdkmanager
    if [ -f "${sdk_path}/cmdline-tools/latest/bin/sdkmanager" ]; then
        sdkmanager="${sdk_path}/cmdline-tools/latest/bin/sdkmanager"
    elif [ -f "${sdk_path}/tools/bin/sdkmanager" ]; then
        sdkmanager="${sdk_path}/tools/bin/sdkmanager"
    else
        return 1
    fi
    
    info "Found sdkmanager at: ${sdkmanager}"
    info "Accepting Android SDK licenses..."
    
    yes | "${sdkmanager}" --licenses
    
    return 0
}

# Accept licenses manually by creating license files
accept_manually() {
    local sdk_path="$1"
    local licenses_dir="${sdk_path}/licenses"
    
    info "Creating license acceptance files manually..."
    
    # Create licenses directory if it doesn't exist
    if [ ! -d "${licenses_dir}" ]; then
        if ! mkdir -p "${licenses_dir}"; then
            error "Cannot create licenses directory: ${licenses_dir}"
            error "You may need to run this script with sudo for system-wide Android SDK"
            return 1
        fi
    fi
    
    # Create license files
    # Standard Android SDK license
    echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" > "${licenses_dir}/android-sdk-license" 2>/dev/null || {
        error "Cannot write to ${licenses_dir}/android-sdk-license"
        error "You may need to run this script with sudo for system-wide Android SDK"
        return 1
    }
    
    # Preview license
    echo "601085b94cd77f0b54ff864069570f3" > "${licenses_dir}/android-sdk-preview-license" 2>/dev/null || true
    
    # Additional licenses
    echo "84831b9409646a918e30573bab4c9c91346d8abd" > "${licenses_dir}/android-sdk-arm-dbt-license" 2>/dev/null || true
    echo "d975f751698a77b662f1254ddbeed3901e976f5a" > "${licenses_dir}/android-googletv-license" 2>/dev/null || true
    echo "33b6a2b64607f11b759f320ef9dff34ae" > "${licenses_dir}/android-sdk-arm-dbt-preview-license" 2>/dev/null || true
    echo "e9acab5b5fbb560a72cfaecce8946896" > "${licenses_dir}/google-gdk-license" 2>/dev/null || true
    
    info "License files created successfully!"
    return 0
}

# Main execution
main() {
    info "Android SDK License Acceptance Helper"
    echo ""
    
    # Find Android SDK
    ANDROID_SDK=$(find_android_sdk) || {
        error "Android SDK not found!"
        error "Please set ANDROID_HOME environment variable or install Android SDK"
        error ""
        error "Common locations:"
        error "  - ${HOME}/Android/Sdk (user installation)"
        error "  - /usr/lib/android-sdk (system installation)"
        exit 1
    }
    
    info "Found Android SDK at: ${ANDROID_SDK}"
    echo ""
    
    # Try to accept licenses using sdkmanager first
    if accept_with_sdkmanager "${ANDROID_SDK}"; then
        info "Licenses accepted successfully using sdkmanager!"
        exit 0
    fi
    
    warn "sdkmanager not found or failed. Trying manual license acceptance..."
    echo ""
    
    # Fall back to manual acceptance
    if accept_manually "${ANDROID_SDK}"; then
        info "Licenses accepted successfully!"
        exit 0
    fi
    
    error "Failed to accept licenses!"
    error ""
    error "If you're using a system-wide Android SDK, try:"
    error "  sudo ${0}"
    error ""
    error "Or manually accept licenses using:"
    error "  sdkmanager --licenses"
    exit 1
}

main "$@"
