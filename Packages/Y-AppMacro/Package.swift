// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "AppMacro",
    platforms: [.macOS(.v10_15), .iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppMacro",
            targets: ["AppMacro"]),
        .executable(
            name: "AppMacroClient",
            targets: ["AppMacroClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyLab/MetaCodable.git", from: "1.4.0"),
//        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .macro(
          name: "AppMacroMacros",
          dependencies: [
            .product(name: "MetaCodable", package: "MetaCodable"),
//            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
//            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
          ]
        ),
        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "AppMacro", dependencies: ["AppMacroMacros"]),
        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "AppMacroClient", dependencies: ["AppMacro"]),

        .testTarget(
            name: "AppMacroTests",
            dependencies: ["AppMacro"]
        ),
    ]
)
