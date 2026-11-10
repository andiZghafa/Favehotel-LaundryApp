#!/bin/bash
set -e

# If build/web is committed and ready, deploy directly in seconds
if [ -f "build/web/index.html" ]; then
  echo "=== Pre-built Flutter web artifacts detected in build/web ==="
  echo "=== Deploying directly to Vercel without downloading SDK ==="
  ls -lh build/web
  exit 0
fi

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

echo "=== Building Web App (Standard JS) ==="
flutter build web --release --no-wasm

echo "=== Build Succeeded ==="
ls -la build/web
