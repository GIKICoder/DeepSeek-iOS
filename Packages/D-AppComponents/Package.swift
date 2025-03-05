// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppComponents",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppComponents",
            targets: ["AppComponents"]),
    ],
    dependencies: [
        .package(path: "../R-AppInfra"),
        .package(path: "../F-AppServices"),
        .package(path: "../ZVendors/SideMenu"),
        .package(path: "../ZVendors/route-composer"),
        .package(path: "../ZVendors/RouterService"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppComponents",
            dependencies: [
              .product(name: "AppInfra", package: "R-AppInfra"),
              .product(name: "AppServices", package: "F-AppServices"),
              .product(name: "SideMenu", package: "SideMenu"),
              .product(name: "RouteComposer", package: "route-composer"),
              .product(name: "RouterService", package: "RouterService")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "AppComponentsTests",
            dependencies: ["AppComponents"]
        ),
    ]
)
