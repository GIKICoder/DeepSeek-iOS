// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pulse",
    products: [
        .library(
            name: "Pulse",
            targets: ["Pulse"]
        ),
        .library(
            name: "PulseUI",
            targets: ["PulseUI"]
        ),
        .library(
            name: "PulseProxy",
            targets: ["PulseProxy"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "Pulse",
            path: "Pulse.xcframework"
        ),
        .binaryTarget(
            name: "PulseUI",
            path: "PulseUI.xcframework"
        ),
        .binaryTarget(
            name: "PulseProxy",
            path: "PulseProxy.xcframework"
        ),
    ]
)
