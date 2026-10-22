// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "SkyUI",
    platforms: [.iOS(.v27)],
    products: [
        .library(name: "SkyUI", targets: ["SkyUI"])
    ],
    dependencies: [
        .package(path: "../SkyCore")
    ],
    targets: [
        .target(
            name: "SkyUI",
            dependencies: ["SkyCore"],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        .testTarget(
            name: "SkyUITests",
            dependencies: ["SkyUI"],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
    ]
)
