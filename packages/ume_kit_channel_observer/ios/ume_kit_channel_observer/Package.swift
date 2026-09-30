// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ume_kit_channel_observer",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "ume-kit-channel-observer", targets: ["ume_kit_channel_observer"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "ume_kit_channel_observer",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
