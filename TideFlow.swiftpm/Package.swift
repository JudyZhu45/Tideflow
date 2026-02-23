// swift-tools-version: 5.8

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "TideFlow",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "TideFlow",
            targets: ["TideFlow"],
            bundleIdentifier: "com.tideflow.app",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .cloud),
            accentColor: .presetColor(.teal),
            supportedDeviceFamilies: [.pad, .phone],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "TideFlow",
            path: "Sources"
        )
    ]
)
