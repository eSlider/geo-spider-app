#!/bin/bash
# Build Android APK using Docker
# Uses budtmo/docker-android image - everything is pre-configured
# Reference: https://github.com/budtmo/docker-android

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

# Use docker-android image from budtmo
# Reference: https://github.com/budtmo/docker-android
DOCKER_IMAGE="budtmo/docker-android:emulator_14.0"

echo "📦 Using docker-android image: $DOCKER_IMAGE"
echo "   Image contains: Android SDK, Java 17, build tools"
echo "   Reference: https://github.com/budtmo/docker-android"
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
# docker-android uses /home/androidusr as user home
# Override entrypoint to skip emulator startup for build-only
docker run --rm \
    --entrypoint="/bin/bash" \
    -v "$PROJECT_ROOT":/home/androidusr/workspace \
    -v geospider-gradle-cache:/home/androidusr/.gradle \
    -w /home/androidusr/workspace \
    -e VERSION_NAME="$VERSION_NAME" \
    -e VERSION_CODE="$VERSION_CODE" \
    -e CI=false \
    $DOCKER_IMAGE \
    -c "
        # Make gradlew executable
        chmod +x ./gradlew || true
        
        # Ensure build outputs directory exists
        mkdir -p /home/androidusr/workspace/build-outputs
        
        # Build APK - use gradlew which handles everything
        echo '🔨 Building APK with Gradle...'
        ./gradlew :androidApp:assembleRelease \
            -PVERSION_NAME=\"\$VERSION_NAME\" \
            -PVERSION_CODE=\"\$VERSION_CODE\" \
            --no-daemon \
            --stacktrace 2>&1 | tee var/logs/build_\$(date +%Y%m%d_%H%M%S).log
        
        # Find APK file
        APK_FILE=\$(find geo-spider-app/androidApp/build/outputs/apk/release -name \"*.apk\" | head -1)
        if [ -z \"\$APK_FILE\" ]; then
            echo '❌ APK file not found!'
            echo 'Checking build outputs...'
            ls -la geo-spider-app/androidApp/build/outputs/apk/release/ || true
            exit 1
        fi
        
        # Copy APK to build-outputs
        cp \"\$APK_FILE\" /home/androidusr/workspace/build-outputs/
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
