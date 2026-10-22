// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "SkyData",
    platforms: [.iOS(.v27), .macOS(.v26)],
    products: [
        .library(name: "SkyData", targets: ["SkyData"])
    ],
    dependencies: [
        .package(path: "../SkyCore")
    ],
    targets: [
        .target(
            name: "SkyData",
            dependencies: ["SkyCore"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "SkyDataTests",
            dependencies: ["SkyData"],
            resources: [.process("Fixtures")]
        ),
    ]
)
