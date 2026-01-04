#!/bin/bash
# Build Android APK using Docker
# This script builds the APK inside a Docker container for consistent builds

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo "🐳 Building Android APK using Docker..."
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker daemon is not running. Please start Docker first."
    exit 1
fi

# Use pre-built Android SDK image from MobileDevOps
# Reference: https://github.com/MobileDevOps/android-sdk-image
DOCKER_IMAGE="mobiledevops/android-sdk-image:34.0.0"

echo "📦 Using pre-built Android SDK image: $DOCKER_IMAGE"
echo "   Image contains: Android SDK, Gradle 8.2, build tools, and platforms"
echo ""

# Pull the image (will use cache if already exists)
docker pull $DOCKER_IMAGE

# Create build outputs directory
mkdir -p build-outputs
mkdir -p var/logs

# Get version from gradle.properties or use default
VERSION_NAME=$(grep -E "^VERSION_NAME=" gradle.properties 2>/dev/null | cut -d'=' -f2 || echo "1.0.0")
VERSION_CODE=$(grep -E "^VERSION_CODE=" gradle.properties 2>/dev/null | cut -d'=' -f2 || echo "1")

echo "📌 Building with version: $VERSION_NAME (code: $VERSION_CODE)"
echo ""

# Run build inside Docker container
docker run --rm \
    -v "$PROJECT_ROOT":/app \
    -v geospider-gradle-cache:/home/mobiledevops/.gradle \
    -w /app \
    -e VERSION_NAME="$VERSION_NAME" \
    -e VERSION_CODE="$VERSION_CODE" \
    -e CI=false \
    $DOCKER_IMAGE \
    bash -c "
        echo '📱 Accepting Android SDK licenses...'
        yes | \$ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=\$ANDROID_HOME --licenses || true
        
        echo '📦 Installing additional SDK components (API 35, build-tools 35.0.0)...'
        \$ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=\$ANDROID_HOME \
            'platforms;android-35' \
            'build-tools;35.0.0' || true
        
        echo '🔨 Building APK...'
        ./gradlew :androidApp:assembleRelease \
            -PVERSION_NAME=\"\$VERSION_NAME\" \
            -PVERSION_CODE=\"\$VERSION_CODE\" \
            --no-daemon \
            --stacktrace 2>&1 | tee var/logs/build_\$(date +%Y%m%d_%H%M%S).log || true
        
        # Find APK file
        APK_FILE=\$(find geo-spider-app/androidApp/build/outputs/apk/release -name \"*.apk\" | head -1)
        if [ -z \"\$APK_FILE\" ]; then
            echo '❌ APK file not found!'
            exit 1
        fi
        
        # Copy APK to build-outputs (ensure directory is writable)
        mkdir -p /app/build-outputs
        cp \"\$APK_FILE\" /app/build-outputs/ || cp \"\$APK_FILE\" /app/build-outputs/\$(basename \"\$APK_FILE\")
        echo \"✅ APK built: \$APK_FILE\"
        echo \"📦 APK size: \$(du -h \"\$APK_FILE\" | cut -f1)\"
    "

# Find the APK in build-outputs
APK_FILE=$(find build-outputs -name "*.apk" | head -1)

if [ -z "$APK_FILE" ]; then
    echo "❌ APK file not found in build-outputs!"
    exit 1
fi

echo ""
echo "✅ Build completed successfully!"
echo "📦 APK location: $APK_FILE"
echo "📊 APK size: $(du -h "$APK_FILE" | cut -f1)"
echo ""
echo "💡 You can install the APK on your Android device:"
echo "   adb install $APK_FILE"

