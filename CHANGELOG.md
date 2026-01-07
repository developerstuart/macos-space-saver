# Changelog

All notable changes to macOS Space Saver will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-07

### Added

#### Core Features
- **Save Current Layout**: Capture all open window positions, sizes, and states
- **Restore Layout**: Restore windows to saved positions with automatic app launching
- **Menu Bar Application**: Lightweight background app with menu bar icon
- **Keyboard Shortcuts**: 
  - `⌘⇧S` to save layout
  - `⌘⇧R` to restore layout
- **Multi-Monitor Support**: Track which monitor each window belongs to
- **Space/Desktop Tracking**: Remember which Space/Desktop each window is on
- **JSON Configuration**: Human-readable, editable configuration file at `~/.macos-space-saver.json`

#### Special Application Support
- **Google Chrome**: Profile detection based on window titles
- **Visual Studio Code**: Workspace detection and tracking for each project window

#### Window Management
- **Auto-launch Closed Apps**: Opens applications that were running in saved layout
- **Hide Unlisted Windows**: Automatically hides apps not in the saved configuration
- **Window State Preservation**: Saves and restores minimized/hidden states
- **Position and Size**: Exact window frame restoration

#### User Experience
- **Accessibility Permissions Prompt**: Automatic prompt for required permissions
- **Notifications**: Visual feedback for save/restore operations
- **Config File Access**: Quick access to edit configuration via menu
- **Error Handling**: User-friendly error messages and notifications

### Documentation
- Comprehensive README with installation, usage, and troubleshooting
- Quick Start Guide for 5-minute setup
- Contributing Guidelines for developers
- Example configuration file
- Build and installation scripts

### Technical
- Swift Package Manager project structure
- macOS 11.0+ support
- Accessibility API integration
- Built with Swift 5.5+ and AppKit
- Clean separation of concerns (AppDelegate, SpaceManager, main)

## [Unreleased]

### Planned Features
- Multiple layout profiles support
- Configuration UI instead of JSON editing
- Improved Space detection using private APIs (if feasible)
- Animation during window restoration
- Status indicator during operations
- Support for more applications with special handling
- Layout templates and presets
- Cloud sync option (optional)
- Dark mode menu bar icon support

[1.0.0]: https://github.com/developerstuart/macos-space-saver/releases/tag/v1.0.0
