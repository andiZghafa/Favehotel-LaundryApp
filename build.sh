#!/bin/bash
set -e

echo "=== Configuring Git Safe Directory ==="
git config --global --add safe.directory "*"

echo "=== Downloading Flutter SDK ==="
if [ ! -d "_flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable _flutter
fi

export PATH="$PWD/_flutter/bin:$PATH"

echo "=== Checking Flutter Version ==="
flutter --version

echo "=== Getting Dependencies ==="
flutter config --no-analytics
flutter config --enable-web
flutter pub get

echo "=== Building Web App ==="
flutter build web --release

echo "=== Build Succeeded ==="
ls -la build/web
