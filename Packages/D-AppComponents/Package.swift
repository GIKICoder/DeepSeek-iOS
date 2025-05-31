// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppComponents",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppComponents",
            targets: ["AppComponents"]),
        .library(
            name: "DBClient",
            targets: ["DBClient"]),
    ],
    dependencies: [
        .package(path: "../R-AppInfra"),
        .package(path: "../F-AppServices"),
        .package(path: "../ZVendors/SideMenu"),
        .package(name: "WCDBSwift", path: "../ZVendors/wcdb-2.1.11"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DBClient",
            dependencies: [
              .product(name: "AppInfra", package: "R-AppInfra"),
              .product(name: "AppServices", package: "F-AppServices"),
              .product(name: "WCDBSwift", package: "WCDBSwift"),
            ],
            path: "Sources/DBClient"
        ),
        .target(
            name: "AppComponents",
            dependencies: [
              .product(name: "AppInfra", package: "R-AppInfra"),
              .product(name: "AppServices", package: "F-AppServices"),
              .product(name: "SideMenu", package: "SideMenu"),
              "DBClient",
            ],
            path: "Sources",
            exclude: ["DBClient"]
        ),
        .testTarget(
            name: "AppComponentsTests",
            dependencies: ["AppComponents"]
        ),
        .testTarget(
            name: "DBClientTests",
            dependencies: ["DBClient"],
            path: "Tests/DBClientTests"
        ),
    ]
)
