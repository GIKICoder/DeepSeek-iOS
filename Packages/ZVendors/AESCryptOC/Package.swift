// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AESCryptOC",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "AESCryptOC",
            targets: ["AESCryptOC"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "AESCryptOC",
            dependencies: [
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include/**"),
            ]
        )
    ]
)
