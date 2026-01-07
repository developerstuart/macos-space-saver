# Quick Start Guide

## Getting Started in 5 Minutes

### 1. Build the App

```bash
git clone https://github.com/developerstuart/macos-space-saver.git
cd macos-space-saver
./build.sh
```

### 2. Run the App

```bash
./.build/release/macos-space-saver
```

Or create and run the app bundle:

```bash
./create_app_bundle.sh
open .build/release/macOS-Space-Saver.app
```

### 3. Grant Permissions

When prompted, grant Accessibility permissions:
- System Preferences → Security & Privacy → Privacy → Accessibility
- Enable "macos-space-saver" or "macOS Space Saver"

### 4. Save Your Layout

Arrange your windows how you like them, then:
- Press `⌘⇧S` (Command + Shift + S)
- Or click the menu bar icon → "Save Current Layout"

### 5. Restore Your Layout

At any time:
- Press `⌘⇧R` (Command + Shift + R)
- Or click the menu bar icon → "Restore Layout"

## Tips

- **Edit Configuration**: Click menu bar icon → "Open Config File" to manually edit your layout
- **Multiple Layouts**: Copy `~/.macos-space-saver.json` to different files and swap them as needed
- **Auto-start**: Add the app to System Preferences → Users & Groups → Login Items

## Troubleshooting

**App won't start?**
- Make sure you're running macOS 11 or later
- Run `swift --version` to ensure Swift is installed

**Windows won't move?**
- Check that Accessibility permissions are granted
- Some apps don't support window positioning

**Keyboard shortcuts not working?**
- Verify Accessibility permissions are enabled
- Try using the menu bar instead

## Next Steps

See the full [README.md](README.md) for detailed documentation, configuration options, and advanced usage.
