#!/bin/bash

# Installation script for macOS Space Saver
# This script builds the app and optionally installs it to /Applications

set -e

echo "======================================"
echo "macOS Space Saver - Installation"
echo "======================================"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Error: This application requires macOS"
    exit 1
fi

# Check Swift version
echo "Checking Swift installation..."
if ! command -v swift &> /dev/null; then
    echo "Error: Swift is not installed"
    echo "Please install Xcode Command Line Tools:"
    echo "  xcode-select --install"
    exit 1
fi

SWIFT_VERSION=$(swift --version | head -n 1)
echo "Found: $SWIFT_VERSION"
echo ""

# Build the application
echo "Building application..."
swift build -c release

if [ $? -eq 0 ]; then
    echo "✓ Build successful!"
    echo ""
else
    echo "✗ Build failed"
    exit 1
fi

# Create app bundle
echo "Creating app bundle..."
./create_app_bundle.sh

if [ $? -eq 0 ]; then
    echo "✓ App bundle created!"
    echo ""
else
    echo "✗ Failed to create app bundle"
    exit 1
fi

# Ask if user wants to install to Applications
echo "Would you like to install to /Applications? (y/n)"
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Installing to /Applications..."
    
    # Remove old version if exists
    if [ -d "/Applications/macOS-Space-Saver.app" ]; then
        echo "Removing old version..."
        rm -rf "/Applications/macOS-Space-Saver.app"
    fi
    
    # Copy new version
    cp -r ".build/release/macOS-Space-Saver.app" "/Applications/"
    
    echo "✓ Installed to /Applications/macOS-Space-Saver.app"
    echo ""
    echo "You can now:"
    echo "  1. Open Spotlight (Cmd+Space) and type 'macOS Space Saver'"
    echo "  2. Or run: open /Applications/macOS-Space-Saver.app"
else
    echo ""
    echo "App bundle is available at:"
    echo "  .build/release/macOS-Space-Saver.app"
    echo ""
    echo "To run: open .build/release/macOS-Space-Saver.app"
fi

echo ""
echo "======================================"
echo "Installation Complete!"
echo "======================================"
echo ""
echo "Important: Grant Accessibility permissions when prompted"
echo "System Preferences → Security & Privacy → Privacy → Accessibility"
echo ""
echo "Quick Start:"
echo "  ⌘⇧S - Save current layout"
echo "  ⌘⇧R - Restore layout"
echo ""
echo "See QUICKSTART.md for more information"
