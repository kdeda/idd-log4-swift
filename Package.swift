// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "idd-log4-swift",
    platforms: [
        .iOS(.v15),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "Log4swift",
            targets: ["Log4swift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.2")
    ],
    targets: [
        .target(
            name: "Log4swift",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ]),
        .testTarget(
            name: "Log4swiftTests",
            dependencies: ["Log4swift"]),
    ]
)
