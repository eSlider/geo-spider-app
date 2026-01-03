#!/bin/bash

# Geo Spider App - APK Build Script (Kotlin Multiplatform)
# Compatible with Linux, macOS, and Windows (via WSL/Git Bash)

set -e

echo "🕷️ Geo Spider App - APK Builder (Kotlin)"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

# Check prerequisites
print_step "Checking prerequisites..."

# Check Java
if ! command -v java &> /dev/null; then
    print_error "Java not found. Please install JDK 17 or later."
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -1)
echo "Found Java: $JAVA_VERSION"

# Check Gradle
if ! command -v ./gradlew &> /dev/null && ! command -v gradle &> /dev/null; then
    print_warning "Gradle wrapper not found. Installing Gradle wrapper..."
    # Will be created on first build
fi

# Clean previous builds
print_step "Cleaning previous builds..."
if [ -f "./gradlew" ]; then
    ./gradlew clean
else
    print_warning "Gradle wrapper not found. Run: gradle wrapper"
fi

# Build APK
print_step "Building APK..."
if [ -f "./gradlew" ]; then
    ./gradlew :androidApp:assembleRelease
else
    gradle :androidApp:assembleRelease
fi

# Find APK
APK_FILE=$(find geo-spider-app/androidApp/build/outputs/apk/release -name "*.apk" 2>/dev/null | head -1)

if [ -n "$APK_FILE" ] && [ -f "$APK_FILE" ]; then
    APK_SIZE=$(stat -f%z "$APK_FILE" 2>/dev/null || stat -c%s "$APK_FILE" 2>/dev/null || echo "unknown")
    print_success "APK built successfully!"
    echo ""
    echo "📱 APK Location: $APK_FILE"
    echo "📦 APK Size: ${APK_SIZE} bytes"
    echo ""
    echo "🚀 Next steps:"
    echo "   1. Connect Android device or start emulator"
    echo "   2. Run: adb install -r $APK_FILE"
    echo "   3. Run: adb shell am start -n com.geospider.android/.MainActivity"
else
    print_error "APK file not found!"
    exit 1
fi

print_success "Geo Spider APK build complete!"
