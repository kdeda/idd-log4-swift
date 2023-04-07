// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "idd-log4-swift",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "Log4swift",
            targets: ["Log4swift"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Log4swift",
            dependencies: []),
        .testTarget(
            name: "Log4swiftTests",
            dependencies: ["Log4swift"]),
    ]
)
