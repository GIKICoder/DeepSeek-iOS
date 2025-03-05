// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "PagingKit",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "PagingKit", targets: ["PagingKit"]),
    ],
    targets: [
        .target(name: "PagingKit", path: "Sources"),
    ]
)
