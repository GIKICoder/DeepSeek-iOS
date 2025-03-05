// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Hero",
    platforms: [
        .tvOS(.v10),
        .iOS(.v10),
    ],
    products: [
        .library(name: "Hero",
                 targets: ["Hero"]),
    ],
    targets: [
        .target(name: "Hero", path: "Sources"),
    ],
    swiftLanguageVersions: [.v5]
)
