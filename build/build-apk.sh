#!/bin/bash

# Geo Spider App - APK Build Script
# This script builds the Android APK for the Geo Spider MAUI application

set -e  # Exit on any error

echo "Geo Spider App - APK Build Script"
echo "=================================="

# Configuration
PROJECT_NAME="GeoSpiderApp"
CONFIGURATION="Release"
OUTPUT_DIR="bin/Release/net9.0-android"
APK_OUTPUT_DIR="build/apk"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."

    # Check if dotnet is installed
    if ! command -v dotnet &> /dev/null; then
        print_error "dotnet CLI is not installed. Please install .NET 9.0 SDK."
        exit 1
    fi

    # Check dotnet version
    DOTNET_VERSION=$(dotnet --version)
    print_status "Found .NET version: $DOTNET_VERSION"

    # Check if MAUI workload is installed
    if ! dotnet workload list | grep -q maui; then
        print_warning "MAUI workload not found. Installing..."
        dotnet workload install maui
    fi

    # Check if Android SDK is available (this would be checked in a real MAUI environment)
    print_status "Prerequisites check completed."
}

# Clean previous builds
clean_build() {
    print_status "Cleaning previous builds..."
    rm -rf "$OUTPUT_DIR"
    rm -rf "$APK_OUTPUT_DIR"
    dotnet clean
}

# Restore packages
restore_packages() {
    print_status "Restoring NuGet packages..."
    dotnet restore
}

# Build the project
build_project() {
    print_status "Building project in $CONFIGURATION configuration..."

    # Build for Android
    dotnet build \
        --configuration $CONFIGURATION \
        --framework net9.0-android \
        --verbosity normal

    if [ $? -eq 0 ]; then
        print_status "Build completed successfully."
    else
        print_error "Build failed."
        exit 1
    fi
}

# Build APK
build_apk() {
    print_status "Building APK..."

    # Create output directory
    mkdir -p "$APK_OUTPUT_DIR"

    # Publish for Android with APK
    dotnet publish \
        --configuration $CONFIGURATION \
        --framework net9.0-android \
        --output "$APK_OUTPUT_DIR" \
        /p:AndroidPackageFormat=apk \
        /p:AndroidSigningKeyStore="$ANDROID_KEYSTORE" \
        /p:AndroidSigningKeyAlias="$ANDROID_KEY_ALIAS" \
        /p:AndroidSigningKeyPass="$ANDROID_KEY_PASS" \
        /p:AndroidSigningStorePass="$ANDROID_STORE_PASS"

    if [ $? -eq 0 ]; then
        print_status "APK build completed successfully."

        # Find the generated APK
        APK_FILE=$(find "$APK_OUTPUT_DIR" -name "*.apk" | head -1)
        if [ -n "$APK_FILE" ]; then
            print_status "APK generated: $APK_FILE"
            ls -la "$APK_FILE"
        else
            print_warning "APK file not found in output directory."
        fi
    else
        print_error "APK build failed."
        exit 1
    fi
}

# Run tests before building
run_tests() {
    print_status "Running tests..."

    dotnet test --verbosity normal

    if [ $? -eq 0 ]; then
        print_status "All tests passed."
    else
        print_error "Tests failed. Aborting build."
        exit 1
    fi
}

# Show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Build Geo Spider MAUI Android APK"
    echo ""
    echo "Options:"
    echo "  -c, --clean          Clean before building"
    echo "  -t, --test           Run tests before building"
    echo "  -s, --skip-tests     Skip running tests"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Environment variables:"
    echo "  ANDROID_KEYSTORE     Path to Android keystore file"
    echo "  ANDROID_KEY_ALIAS    Key alias in keystore"
    echo "  ANDROID_KEY_PASS     Key password"
    echo "  ANDROID_STORE_PASS   Keystore password"
}

# Parse command line arguments
CLEAN=false
RUN_TESTS=true
SKIP_TESTS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -t|--test)
            RUN_TESTS=true
            SKIP_TESTS=false
            shift
            ;;
        -s|--skip-tests)
            SKIP_TESTS=true
            RUN_TESTS=false
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    check_prerequisites

    if [ "$CLEAN" = true ]; then
        clean_build
    fi

    if [ "$RUN_TESTS" = true ] && [ "$SKIP_TESTS" = false ]; then
        run_tests
    fi

    restore_packages
    build_project
    build_apk

    print_status "Build process completed successfully!"
    print_status "Check the $APK_OUTPUT_DIR directory for the generated APK."
}

# Run main function
main "$@"