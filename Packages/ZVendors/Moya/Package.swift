// swift-tools-version:5.3

import PackageDescription

let rocketIfNeeded: [Package.Dependency]

#if os(OSX) || os(Linux)
rocketIfNeeded = [
    .package(url: "https://github.com/shibapm/Rocket", .upToNextMajor(from: "1.2.0")) // dev
]
#else
rocketIfNeeded = []
#endif

let package = Package(
    name: "Moya",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(name: "Moya", targets: ["Moya"]),
        .library(name: "CombineMoya", targets: ["CombineMoya"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.0.0")),
    ] + rocketIfNeeded,
    targets: [
        .target(
            name: "Moya",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire")
            ],
            exclude: [
            ]
        ),
        .target(
            name: "CombineMoya",
            dependencies: [
                "Moya"
            ]
        )
    ]
)

