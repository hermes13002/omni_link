#!/usr/bin/env bash
# exit on error
set -o errexit

cd omnilink_admin
echo "Downloading Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

echo "Building Flutter Web for Admin..."
flutter clean
flutter pub get
flutter build web --release
