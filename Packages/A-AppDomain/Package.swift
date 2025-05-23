// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppDomain",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppDomain",
            targets: ["AppDomain"]),
    ],
    dependencies: [
        .package(path: "../D-AppComponents"),
        .package(path: "../F-AppServices"),
        // .package(path: "../ZVendors/GMarkdown"),
        .package(path: "../ZVendors/IQListKit"),
        .package(path: "../ZVendors/AESCryptOC"),
        .package(url: "https://github.com/GIKICoder/GMarkdown.git", branch: "main"),
        .package(url: "https://github.com/QMUI/LookinServer", from: "1.2.8"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppDomain",
            dependencies: [
              .product(name: "AppComponents", package: "D-AppComponents"),
              .product(name: "AppServices", package: "F-AppServices"),
              "LookinServer",
              "GMarkdown",
              "IQListKit",
              "AESCryptOC"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "AppDomainTests",
            dependencies: ["AppDomain"]
        ),
    ]
)
