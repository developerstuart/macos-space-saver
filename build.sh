#!/bin/bash

# Build script for macOS Space Saver
# This script builds the Swift application and creates a macOS app bundle

set -e

echo "Building macOS Space Saver..."

# Build the Swift package
swift build -c release

echo "Build complete!"
echo ""
echo "To run the application, use:"
echo "  ./.build/release/macos-space-saver"
echo ""
echo "Or create an app bundle with:"
echo "  ./create_app_bundle.sh"
