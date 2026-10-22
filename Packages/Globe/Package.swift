// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "Globe",
    platforms: [.iOS(.v27), .macOS(.v26)],
    products: [
        .library(name: "Globe", targets: ["Globe"])
    ],
    dependencies: [
        .package(path: "../SkyCore"),
        .package(path: "../SkyUI"),
    ],
    targets: [
        .target(
            name: "Globe",
            dependencies: ["SkyCore", "SkyUI"],
            resources: [.process("Resources")],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        .testTarget(
            name: "GlobeTests",
            dependencies: ["Globe"],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
    ]
)
