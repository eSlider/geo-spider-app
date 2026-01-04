# Dockerfile for Android CI/CD Build Environment
# 
# NOTE: This Dockerfile is optional. The CI/CD pipeline uses the pre-built
# mobiledevops/android-sdk-image:34.0.0 image instead for faster builds.
# 
# This Dockerfile can be used for:
# - Custom build requirements
# - Local development with specific configurations
# - Extending the base image with additional tools
#
# For most use cases, use the pre-built image directly:
# docker pull mobiledevops/android-sdk-image:34.0.0
#
# Reference: https://github.com/MobileDevOps/android-sdk-image

FROM openjdk:17-slim

# Set metadata
LABEL maintainer="Geo Spider App"
LABEL description="Android build environment with JDK 17, Android SDK, and Gradle"

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    wget \
    git \
    curl \
    bash \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV ANDROID_HOME=/opt/android-sdk \
    ANDROID_SDK_ROOT=/opt/android-sdk \
    GRADLE_USER_HOME=/home/gradle/.gradle \
    PATH=$PATH:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:/opt/android-sdk/emulator

# Create directories
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && mkdir -p ${GRADLE_USER_HOME} \
    && mkdir -p /app

# Download and install Android command-line tools
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdline-tools.zip \
    && unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/cmdline-tools.zip

# Accept Android SDK licenses and install required components
RUN yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --licenses || true \
    && ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager \
        "platform-tools" \
        "platforms;android-35" \
        "build-tools;35.0.0" \
        "cmdline-tools;latest"

# Set working directory
WORKDIR /app

# Default command
CMD ["/bin/bash"]
