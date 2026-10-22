// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "SkyData",
    platforms: [.iOS(.v27)],
    products: [
        .library(name: "SkyData", targets: ["SkyData"])
    ],
    dependencies: [
        .package(path: "../SkyCore")
    ],
    targets: [
        .target(name: "SkyData", dependencies: ["SkyCore"]),
        .testTarget(name: "SkyDataTests", dependencies: ["SkyData"]),
    ]
)
