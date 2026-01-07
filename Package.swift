// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "macOS-Space-Saver",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(
            name: "macos-space-saver",
            targets: ["macOS-Space-Saver"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "macOS-Space-Saver",
            dependencies: [],
            path: "Sources")
    ]
)
