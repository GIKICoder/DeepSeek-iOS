// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppServices",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppServices",
            targets: ["AppServices"]),
    ],
    dependencies: [
        .package(path: "../R-AppInfra"),
        .package(path: "../ZVendors/Moya"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppServices",
            dependencies: [
                .product(name: "AppInfra", package: "R-AppInfra"),
                .product(name: "Moya", package: "Moya"),
            ]
        ),
        .testTarget(
            name: "AppServicesTests",
            dependencies: ["AppServices"]
        ),
    ]
)
