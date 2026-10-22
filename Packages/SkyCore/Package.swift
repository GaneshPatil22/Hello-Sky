// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "SkyCore",
    platforms: [.iOS(.v27)],
    products: [
        .library(name: "SkyCore", targets: ["SkyCore"])
    ],
    targets: [
        .target(name: "SkyCore"),
        .testTarget(name: "SkyCoreTests", dependencies: ["SkyCore"]),
    ]
)
