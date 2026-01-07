# Contributing to macOS Space Saver

Thank you for your interest in contributing! This guide will help you get started.

## Development Setup

### Prerequisites

- macOS 11.0 or later
- Xcode Command Line Tools or Swift 5.5+
- Git

### Getting Started

1. Fork the repository on GitHub
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/macos-space-saver.git
   cd macos-space-saver
   ```

3. Build the project:
   ```bash
   ./build.sh
   ```

## Project Structure

```
macos-space-saver/
├── Sources/
│   ├── main.swift           # Entry point
│   ├── AppDelegate.swift    # Menu bar app, shortcuts, UI
│   └── SpaceManager.swift   # Core window management logic
├── Package.swift            # Swift Package Manager config
├── Info.plist              # App metadata and permissions
├── build.sh                # Build script
└── create_app_bundle.sh    # App bundle creation
```

## Making Changes

### Code Style

- Follow Swift standard conventions
- Use meaningful variable names
- Add comments for complex logic
- Keep functions focused and small

### Testing Changes

1. Build the app: `./build.sh`
2. Run the app: `./.build/release/macos-space-saver`
3. Test your changes:
   - Try saving a layout
   - Try restoring a layout
   - Test with Chrome and VS Code if applicable
   - Test keyboard shortcuts

### Committing

- Write clear commit messages
- Keep commits focused on a single change
- Reference issues when applicable (e.g., "Fix #123")

## Pull Request Process

1. Create a new branch for your feature:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and commit:
   ```bash
   git add .
   git commit -m "Description of your changes"
   ```

3. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

4. Open a Pull Request on GitHub
   - Provide a clear description of the changes
   - Reference any related issues
   - Include screenshots if UI changes are involved

## Ideas for Contributions

### Features

- Support for saving/loading multiple layout profiles
- Improved Space detection (possibly using private APIs)
- Support for more applications with special handling
- Animation when restoring windows
- Status indicator during restore operations
- Configuration UI instead of JSON editing

### Bug Fixes

- Improve window matching logic
- Better handling of minimized/hidden windows
- Fix issues with specific applications

### Documentation

- Additional usage examples
- Video tutorials
- Troubleshooting guides
- Translation to other languages

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Help others learn and grow

## Questions?

Feel free to open an issue for:
- Bug reports
- Feature requests
- Questions about the code
- General discussion

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
