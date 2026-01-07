import Cocoa
import Foundation

struct WindowInfo: Codable {
    let appName: String
    let appBundleIdentifier: String?
    let windowTitle: String
    let frame: CGRect
    let spaceIndex: Int
    let displayID: CGDirectDisplayID
    let isMinimized: Bool
    let isHidden: Bool
    
    // Chrome-specific
    let chromeProfile: String?
    
    // VS Code-specific
    let vscodeWorkspace: String?
}

struct LayoutConfiguration: Codable {
    let timestamp: Date
    let windows: [WindowInfo]
    let version: String = "1.0"
}

class SpaceManager {
    let configPath: String
    
    init(configPath: String) {
        self.configPath = configPath
    }
    
    func captureCurrentLayout() throws {
        var windows: [WindowInfo] = []
        
        // Get all running applications
        let runningApps = NSWorkspace.shared.runningApplications
        
        for app in runningApps {
            guard let bundleIdentifier = app.bundleIdentifier else { continue }
            
            // Skip system apps and background processes
            if app.activationPolicy != .regular { continue }
            
            // Get windows for this application
            let appWindows = getWindowsForApp(bundleIdentifier: bundleIdentifier, appName: app.localizedName ?? "Unknown")
            windows.append(contentsOf: appWindows)
        }
        
        // Create configuration
        let config = LayoutConfiguration(timestamp: Date(), windows: windows)
        
        // Save to file
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(config)
        try data.write(to: URL(fileURLWithPath: configPath))
    }
    
    func restoreLayout() throws {
        // Load configuration
        let data = try Data(contentsOf: URL(fileURLWithPath: configPath))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let config = try decoder.decode(LayoutConfiguration.self, from: data)
        
        // Get currently running apps
        let runningApps = NSWorkspace.shared.runningApplications
        let runningBundleIDs = Set(runningApps.compactMap { $0.bundleIdentifier })
        
        // Group windows by app
        let windowsByApp = Dictionary(grouping: config.windows) { $0.appBundleIdentifier ?? $0.appName }
        
        // First, hide all windows not in configuration
        hideWindowsNotInConfig(config: config, runningApps: runningApps)
        
        // Open apps that are closed
        for (bundleID, windows) in windowsByApp {
            if let bundleIdentifier = windows.first?.appBundleIdentifier,
               !runningBundleIDs.contains(bundleIdentifier) {
                // App is not running, launch it
                launchApp(bundleIdentifier: bundleIdentifier, appName: windows.first?.appName ?? "")
                
                // Wait a bit for app to launch
                Thread.sleep(forTimeInterval: 2.0)
            }
            
            // Handle special cases
            if bundleID == "com.google.Chrome" {
                restoreChromeWindows(windows)
            } else if bundleID == "com.microsoft.VSCode" {
                restoreVSCodeWindows(windows)
            } else {
                restoreGenericWindows(windows)
            }
        }
    }
    
    private func getWindowsForApp(bundleIdentifier: String, appName: String) -> [WindowInfo] {
        var windows: [WindowInfo] = []
        
        // Use Accessibility API to get window information
        guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).first else {
            return windows
        }
        
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        var windowList: CFTypeRef?
        
        let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowList)
        
        if result == .success, let windowArray = windowList as? [AXUIElement] {
            for (index, windowElement) in windowArray.enumerated() {
                if let windowInfo = extractWindowInfo(
                    windowElement: windowElement,
                    appName: appName,
                    bundleIdentifier: bundleIdentifier,
                    index: index
                ) {
                    windows.append(windowInfo)
                }
            }
        }
        
        return windows
    }
    
    private func extractWindowInfo(
        windowElement: AXUIElement,
        appName: String,
        bundleIdentifier: String,
        index: Int
    ) -> WindowInfo? {
        // Get window title
        var titleValue: CFTypeRef?
        AXUIElementCopyAttributeValue(windowElement, kAXTitleAttribute as CFString, &titleValue)
        let title = titleValue as? String ?? "Untitled"
        
        // Get window position
        var positionValue: CFTypeRef?
        var sizeValue: CFTypeRef?
        AXUIElementCopyAttributeValue(windowElement, kAXPositionAttribute as CFString, &positionValue)
        AXUIElementCopyAttributeValue(windowElement, kAXSizeAttribute as CFString, &sizeValue)
        
        var position = CGPoint.zero
        var size = CGSize.zero
        
        if let positionValue = positionValue as? AXValue {
            if !AXValueGetValue(positionValue, .cgPoint, &position) {
                print("Warning: Failed to extract position for window: \(title)")
            }
        }
        
        if let sizeValue = sizeValue as? AXValue {
            if !AXValueGetValue(sizeValue, .cgSize, &size) {
                print("Warning: Failed to extract size for window: \(title)")
            }
        }
        
        let frame = CGRect(origin: position, size: size)
        
        // Get minimized state
        var minimizedValue: CFTypeRef?
        AXUIElementCopyAttributeValue(windowElement, kAXMinimizedAttribute as CFString, &minimizedValue)
        let isMinimized = minimizedValue as? Bool ?? false
        
        // Get hidden state
        var hiddenValue: CFTypeRef?
        AXUIElementCopyAttributeValue(windowElement, kAXHiddenAttribute as CFString, &hiddenValue)
        let isHidden = hiddenValue as? Bool ?? false
        
        // Detect which display/screen the window is on
        let displayID = getDisplayForWindow(frame: frame)
        
        // Detect which Space the window is on (this is an approximation)
        let spaceIndex = getSpaceForWindow(frame: frame)
        
        // Chrome-specific detection
        var chromeProfile: String?
        if bundleIdentifier == "com.google.Chrome" {
            chromeProfile = detectChromeProfile(title: title)
        }
        
        // VS Code-specific detection
        var vscodeWorkspace: String?
        if bundleIdentifier == "com.microsoft.VSCode" {
            vscodeWorkspace = detectVSCodeWorkspace(title: title)
        }
        
        return WindowInfo(
            appName: appName,
            appBundleIdentifier: bundleIdentifier,
            windowTitle: title,
            frame: frame,
            spaceIndex: spaceIndex,
            displayID: displayID,
            isMinimized: isMinimized,
            isHidden: isHidden,
            chromeProfile: chromeProfile,
            vscodeWorkspace: vscodeWorkspace
        )
    }
    
    private func detectChromeProfile(title: String) -> String? {
        // Chrome window titles often include profile name
        // Format: "Page Title - Profile Name"
        // Try to extract profile from title
        if title.contains(" - ") {
            let components = title.components(separatedBy: " - ")
            if components.count >= 2 {
                return components.last
            }
        }
        return nil
    }
    
    private func detectVSCodeWorkspace(title: String) -> String? {
        // VS Code titles format: "filename - project name - Visual Studio Code"
        if title.contains(" - Visual Studio Code") {
            let withoutVSCode = title.replacingOccurrences(of: " - Visual Studio Code", with: "")
            let components = withoutVSCode.components(separatedBy: " - ")
            if components.count >= 2 {
                return components[components.count - 1] // Return project/workspace name
            }
        }
        return nil
    }
    
    private func getDisplayForWindow(frame: CGRect) -> CGDirectDisplayID {
        // Find which display contains the center of the window
        let centerPoint = CGPoint(x: frame.midX, y: frame.midY)
        
        var displayCount: UInt32 = 0
        var displays = [CGDirectDisplayID](repeating: 0, count: 16)
        
        CGGetDisplaysWithPoint(centerPoint, 16, &displays, &displayCount)
        
        return displayCount > 0 ? displays[0] : CGMainDisplayID()
    }
    
    private func getSpaceForWindow(frame: CGRect) -> Int {
        // IMPORTANT LIMITATION: Accurate Space detection requires private APIs
        // (CGSGetWindowsInSpaceForConnection or similar) which are not available
        // in the public macOS SDK. Current implementation uses a simplified approach.
        // 
        // For production use, consider:
        // 1. Using a workaround with private frameworks (requires disabling SIP)
        // 2. Using AppleScript to detect Spaces
        // 3. Manual Space assignment in configuration file
        // 
        // For now, defaulting to Space 0 - users can manually edit the JSON config
        // to specify the correct Space for each window.
        return 0 // Default to space 0 - users should manually edit if needed
    }
    
    private func hideWindowsNotInConfig(config: LayoutConfiguration, runningApps: [NSRunningApplication]) {
        let configWindowTitles = Set(config.windows.map { $0.windowTitle })
        let configBundleIDs = Set(config.windows.compactMap { $0.appBundleIdentifier })
        
        for app in runningApps {
            guard let bundleIdentifier = app.bundleIdentifier else { continue }
            
            // If app is not in config at all, hide it
            if !configBundleIDs.contains(bundleIdentifier) && app.activationPolicy == .regular {
                app.hide()
            }
        }
    }
    
    private func launchApp(bundleIdentifier: String, appName: String) {
        let workspace = NSWorkspace.shared
        
        // Try to launch by bundle identifier
        if let url = workspace.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.activates = true
            workspace.openApplication(at: url, configuration: configuration) { app, error in
                if let error = error {
                    print("Error launching \(appName): \(error)")
                }
            }
        }
    }
    
    private func restoreChromeWindows(_ windows: [WindowInfo]) {
        // Group Chrome windows by profile
        let windowsByProfile = Dictionary(grouping: windows) { $0.chromeProfile ?? "Default" }
        
        for (profile, profileWindows) in windowsByProfile {
            for window in profileWindows {
                restoreWindow(window)
            }
        }
    }
    
    private func restoreVSCodeWindows(_ windows: [WindowInfo]) {
        // For VS Code, each window represents a workspace/project
        // Restore each to its specific desktop/monitor
        for window in windows {
            restoreWindow(window)
            
            // If workspace is specified, try to open it
            if let workspace = window.vscodeWorkspace {
                // This would require opening VS Code with specific workspace
                // Implementation depends on VS Code CLI
            }
        }
    }
    
    private func restoreGenericWindows(_ windows: [WindowInfo]) {
        for window in windows {
            restoreWindow(window)
        }
    }
    
    private func restoreWindow(_ window: WindowInfo) {
        guard let bundleIdentifier = window.appBundleIdentifier else { return }
        guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).first else {
            return
        }
        
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        var windowList: CFTypeRef?
        
        let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowList)
        
        if result == .success, let windowArray = windowList as? [AXUIElement] {
            // Find matching window by title
            for windowElement in windowArray {
                var titleValue: CFTypeRef?
                AXUIElementCopyAttributeValue(windowElement, kAXTitleAttribute as CFString, &titleValue)
                
                if let title = titleValue as? String, title == window.windowTitle {
                    // Set window position
                    var position = window.frame.origin
                    guard let positionValue = AXValueCreate(.cgPoint, &position) else {
                        print("Warning: Failed to create position value for window: \(window.windowTitle)")
                        continue
                    }
                    AXUIElementSetAttributeValue(windowElement, kAXPositionAttribute as CFString, positionValue)
                    
                    // Set window size
                    var size = window.frame.size
                    guard let sizeValue = AXValueCreate(.cgSize, &size) else {
                        print("Warning: Failed to create size value for window: \(window.windowTitle)")
                        continue
                    }
                    AXUIElementSetAttributeValue(windowElement, kAXSizeAttribute as CFString, sizeValue)
                    
                    // Set minimized state
                    if window.isMinimized {
                        AXUIElementSetAttributeValue(windowElement, kAXMinimizedAttribute as CFString, kCFBooleanTrue)
                    }
                    
                    break
                }
            }
        }
    }
}
