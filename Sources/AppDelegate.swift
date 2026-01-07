import Cocoa
import AppKit
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var statusItem: NSStatusItem!
    var menu: NSMenu!
    var spaceManager: SpaceManager!
    var configPath: String!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set up user notifications
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
        
        // Set up menu bar icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "square.grid.2x2", accessibilityDescription: "Space Saver")
        }
        
        // Set up menu
        menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Save Current Layout", action: #selector(saveLayout), keyEquivalent: "s"))
        menu.addItem(NSMenuItem(title: "Restore Layout", action: #selector(restoreLayout), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Open Config File", action: #selector(openConfigFile), keyEquivalent: "o"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        // Initialize space manager
        configPath = (NSHomeDirectory() as NSString).appendingPathComponent(".macos-space-saver.json")
        spaceManager = SpaceManager(configPath: configPath)
        
        // Register global keyboard shortcuts
        registerKeyboardShortcuts()
        
        // Check for accessibility permissions
        checkAccessibilityPermissions()
    }
    
    @objc func saveLayout() {
        do {
            try spaceManager.captureCurrentLayout()
            showNotification(title: "Layout Saved", message: "Current window layout has been saved to \(configPath)")
        } catch {
            showNotification(title: "Error", message: "Failed to save layout: \(error.localizedDescription)")
        }
    }
    
    @objc func restoreLayout() {
        do {
            try spaceManager.restoreLayout()
            showNotification(title: "Layout Restored", message: "Window layout has been restored")
        } catch {
            showNotification(title: "Error", message: "Failed to restore layout: \(error.localizedDescription)")
        }
    }
    
    @objc func openConfigFile() {
        NSWorkspace.shared.openFile(configPath)
    }
    
    func checkAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !accessEnabled {
            let alert = NSAlert()
            alert.messageText = "Accessibility Access Required"
            alert.informativeText = "This app needs accessibility access to manage windows. Please grant access in System Preferences > Security & Privacy > Privacy > Accessibility."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    func registerKeyboardShortcuts() {
        // Register global hotkeys (Cmd+Shift+S to save, Cmd+Shift+R to restore)
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains([.command, .shift]) {
                if event.charactersIgnoringModifiers == "s" {
                    self?.saveLayout()
                } else if event.charactersIgnoringModifiers == "r" {
                    self?.restoreLayout()
                }
            }
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains([.command, .shift]) {
                if event.charactersIgnoringModifiers == "s" {
                    self?.saveLayout()
                    return nil
                } else if event.charactersIgnoringModifiers == "r" {
                    self?.restoreLayout()
                    return nil
                }
            }
            return event
        }
    }
    
    func showNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Deliver immediately
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error showing notification: \(error)")
            }
        }
    }
    
    // UNUserNotificationCenterDelegate methods
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }
}
