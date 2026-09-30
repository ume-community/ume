// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ume_kit_memory_detector",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "ume-kit-memory-detector", targets: ["ume_kit_memory_detector"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "ume_kit_memory_detector",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
