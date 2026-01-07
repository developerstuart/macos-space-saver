# macOS Space Saver

A macOS application that saves and restores the placement of application windows across Spaces/desktops and monitors. Perfect for managing complex multi-monitor workflows.

## Features

- 💾 **Save Current Layout**: Capture the exact position and state of all open windows
- 🔄 **Restore Layout**: Restore windows to their saved positions with a keyboard shortcut
- 🖥️ **Multi-Monitor Support**: Tracks which monitor and Space each window belongs to
- 🌐 **Chrome Profile Detection**: Identifies Chrome windows by profile
- 💻 **VS Code Workspace Support**: Handles multiple VS Code project windows
- ⌨️ **Keyboard Shortcuts**: Quick access via global shortcuts
- 📝 **Editable Configuration**: Store layouts in a human-readable JSON file
- 🔒 **Privacy First**: All data stored locally on your machine

## Requirements

- macOS 11.0 (Big Sur) or later
- Xcode Command Line Tools or Swift 5.5+
- Accessibility permissions (app will prompt on first run)

## Installation

### From Source

1. Clone the repository:
   ```bash
   git clone https://github.com/developerstuart/macos-space-saver.git
   cd macos-space-saver
   ```

2. Build the application:
   ```bash
   ./build.sh
   ```

3. Create an app bundle (optional):
   ```bash
   ./create_app_bundle.sh
   ```

4. Run the application:
   ```bash
   ./.build/release/macos-space-saver
   ```
   
   Or if you created the app bundle:
   ```bash
   open .build/release/macOS-Space-Saver.app
   ```

5. Install to Applications folder (optional):
   ```bash
   cp -r .build/release/macOS-Space-Saver.app /Applications/
   ```

## Usage

### First Launch

1. Launch the app - you'll see a grid icon in your menu bar
2. Grant Accessibility permissions when prompted (System Preferences → Security & Privacy → Privacy → Accessibility)
3. The app runs in the background as a menu bar application

### Saving a Layout

To save your current window layout:

1. **Via Menu**: Click the menu bar icon → "Save Current Layout"
2. **Via Keyboard**: Press `⌘⇧S` (Command + Shift + S)

The layout is saved to `~/.macos-space-saver.json`

### Restoring a Layout

To restore a previously saved layout:

1. **Via Menu**: Click the menu bar icon → "Restore Layout"
2. **Via Keyboard**: Press `⌘⇧R` (Command + Shift + R)

When restoring:
- Closed applications will be launched
- Windows will move to their saved positions and Spaces
- Applications not in the saved layout will be hidden

### Editing the Configuration

The configuration file is stored at `~/.macos-space-saver.json` and can be edited with any text editor.

To open it quickly:
- Click the menu bar icon → "Open Config File"

### Configuration File Format

The configuration file is a JSON document with the following structure:

```json
{
  "timestamp": "2026-01-07T09:00:00Z",
  "version": "1.0",
  "windows": [
    {
      "appName": "Google Chrome",
      "appBundleIdentifier": "com.google.Chrome",
      "windowTitle": "GitHub - Chrome",
      "frame": {
        "x": 0,
        "y": 23,
        "width": 1920,
        "height": 1057
      },
      "spaceIndex": 0,
      "displayID": 724241472,
      "isMinimized": false,
      "isHidden": false,
      "chromeProfile": "Default",
      "vscodeWorkspace": null
    }
  ]
}
```

You can manually edit this file to:
- Adjust window positions
- Change which Space or monitor a window should appear on
- Remove windows you don't want to restore
- Add custom window configurations

## Keyboard Shortcuts

- `⌘⇧S` (Command + Shift + S) - Save current layout
- `⌘⇧R` (Command + Shift + R) - Restore layout
- `⌘Q` (in menu) - Quit application

## Special Application Support

### Google Chrome

The app detects Chrome windows by profile name (visible in the window title). This allows you to:
- Save layouts with multiple Chrome profiles
- Restore windows to the correct profile

### Visual Studio Code

The app detects VS Code workspace names from window titles. Each VS Code window/workspace:
- Is tracked separately
- Can be restored to its specific monitor and Space
- Maintains its workspace association

## Permissions

This app requires the following permissions:

- **Accessibility**: Required to read and control window positions
- **AppleEvents**: Required to launch and control applications

The app will prompt for these permissions on first launch.

## Troubleshooting

### "App needs accessibility access"

1. Open System Preferences → Security & Privacy → Privacy → Accessibility
2. Add or enable "macOS Space Saver" in the list
3. Restart the application

### Windows not restoring correctly

- Ensure all applications have been granted Accessibility permissions
- Some apps may not support window positioning via Accessibility API
- Check that the configuration file exists and is valid JSON

### Keyboard shortcuts not working

- Global keyboard shortcuts require Accessibility permissions
- Some apps may capture these shortcuts first
- Try using the menu bar instead

## Development

### Project Structure

```
macos-space-saver/
├── Package.swift          # Swift Package Manager manifest
├── Sources/
│   ├── main.swift        # Application entry point
│   ├── AppDelegate.swift # Menu bar app and main logic
│   └── SpaceManager.swift # Window detection and management
├── Info.plist            # App bundle metadata
├── build.sh              # Build script
└── create_app_bundle.sh  # App bundle creation script
```

### Building

```bash
# Debug build
swift build

# Release build
swift build -c release

# Run tests (if available)
swift test
```

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Known Limitations

- Space detection relies on window position heuristics (macOS private APIs would be needed for exact Space detection)
- Some applications don't support programmatic window positioning
- Full-screen windows may not be handled correctly
- Multiple windows with identical titles may not be distinguished

## License

MIT License - See LICENSE file for details

## Acknowledgments

- Uses macOS Accessibility API for window management
- Built with Swift and AppKit

## Support

For issues, questions, or feature requests, please open an issue on GitHub:
https://github.com/developerstuart/macos-space-saver/issues