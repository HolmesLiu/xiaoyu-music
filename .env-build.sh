#!/bin/bash
# Source this file before running flutter / gradle:
#   source .env-build.sh
#
# Configures: Java 17, Android SDK 36, Flutter 3.44.8 (China mirrors for pub storage)

export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
export FLUTTER_ROOT="$HOME/development/flutter"

# China mirrors (Google CDN is unreliable in CN; FLUTTER_STORAGE_BASE_URL covers
# the engine/dart SDK downloads, PUB_HOSTED_URL covers dart package server).
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"

export PATH="$FLUTTER_ROOT/bin:$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

echo "✅ Build env loaded (Java 17 + Android SDK 36 + Flutter 3.44.8 + CN mirrors)"
echo "   flutter:  $(flutter --version --machine 2>/dev/null | head -1 || echo 'N/A')"
echo "   java:     $(java -version 2>&1 | head -1)"
echo "   sdk:      $ANDROID_HOME"
