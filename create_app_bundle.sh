#!/bin/bash

# Script to create a macOS app bundle

set -e

APP_NAME="macOS Space Saver"
BUNDLE_NAME="macOS-Space-Saver.app"
BUILD_DIR=".build/release"
BUNDLE_DIR="$BUILD_DIR/$BUNDLE_NAME"

echo "Creating app bundle..."

# Create bundle structure
mkdir -p "$BUNDLE_DIR/Contents/MacOS"
mkdir -p "$BUNDLE_DIR/Contents/Resources"

# Copy executable
cp "$BUILD_DIR/macos-space-saver" "$BUNDLE_DIR/Contents/MacOS/"

# Copy Info.plist
cp Info.plist "$BUNDLE_DIR/Contents/"

echo "App bundle created at: $BUNDLE_DIR"
echo ""
echo "To run the app:"
echo "  open '$BUNDLE_DIR'"
echo ""
echo "To install to Applications:"
echo "  cp -r '$BUNDLE_DIR' /Applications/"
