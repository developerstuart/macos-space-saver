#!/bin/bash

# Validation script to check project structure and files

set -e

echo "======================================"
echo "macOS Space Saver - Project Validation"
echo "======================================"
echo ""

ERRORS=0

# Function to check if file exists
check_file() {
    if [ -f "$1" ]; then
        echo "✓ $1"
    else
        echo "✗ $1 (missing)"
        ERRORS=$((ERRORS + 1))
    fi
}

# Function to check if directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo "✓ $1/"
    else
        echo "✗ $1/ (missing)"
        ERRORS=$((ERRORS + 1))
    fi
}

echo "Checking project structure..."
echo ""

# Check directories
check_dir "Sources"
check_dir "screenshots"

# Check source files
check_file "Sources/main.swift"
check_file "Sources/AppDelegate.swift"
check_file "Sources/SpaceManager.swift"

# Check configuration files
check_file "Package.swift"
check_file "Info.plist"
check_file ".gitignore"

# Check documentation
check_file "README.md"
check_file "QUICKSTART.md"
check_file "CONTRIBUTING.md"
check_file "CHANGELOG.md"
check_file "LICENSE"

# Check scripts
check_file "build.sh"
check_file "create_app_bundle.sh"
check_file "install.sh"

# Check example files
check_file "example-config.json"

echo ""
echo "======================================"

if [ $ERRORS -eq 0 ]; then
    echo "✓ All checks passed!"
    echo "======================================"
    exit 0
else
    echo "✗ Found $ERRORS error(s)"
    echo "======================================"
    exit 1
fi
