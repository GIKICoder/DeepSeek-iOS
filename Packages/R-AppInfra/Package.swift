// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppInfra",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "AppInfra",
            targets: ["AppInfra"]),
    ],
    dependencies: [
        .package(path: "../X-AppFoundation"),
        .package(path: "../ZVendors/Skeleton"),
        .package(path: "../ZVendors/MJRefreshSwift"),
        .package(path: "../ZVendors/MagazineLayout"),
        .package(path: "../ZVendors/AppRefreshView"),
        .package(path: "../ZVendors/ReerCodable"),
        .package(path: "../ZVendors/Moya"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.10.2"),
//        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.3"),
        .package(url: "https://github.com/Instagram/IGListKit.git", from: "5.0.0"),
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.4.3"),
        .package(url: "https://github.com/airbnb/epoxy-ios.git", from: "0.10.0"),
        .package(url: "https://github.com/HeroTransitions/Hero.git", .upToNextMajor(from: "1.6.3")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"),
        .package(url: "https://github.com/devicekit/DeviceKit.git", from: "5.4.0"),
//        .package(url: "https://github.com/reers/ReerCodable.git", from: "1.1.6"),
        .package(url: "https://github.com/Danie1s/Tiercel.git", from: "3.2.2"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.20.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImageWebPCoder.git", from: "0.14.6"),
        .package(url: "https://github.com/kaishin/Gifu.git", from: "3.4.1"),
        .package(url: "https://github.com/scalessec/Toast-Swift.git", .upToNextMajor(from: "5.1.0")),
        .package(url: "https://github.com/relatedcode/ProgressHUD.git", from: "14.1.3"),
        .package(url: "https://github.com/hyperoslo/Cache.git", from: "7.3.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", .upToNextMajor(from: "4.2.2")),
    ],
    targets: [
        .target(
            name: "AppInfra",
            dependencies: [
              .product(name: "AppFoundation", package: "X-AppFoundation"),
              .product(name: "Lottie", package: "lottie-ios"),
              .product(name: "Epoxy", package: "epoxy-ios"),
              .product(name: "Alamofire", package: "Alamofire"),
              .product(name: "Moya", package: "Moya"),
              .product(name: "IGListKit", package: "IGListKit"),
              .product(name: "IGListSwiftKit", package: "IGListKit"),
              .product(name: "IGListDiffKit", package: "IGListKit"),
              "AppRefreshView",
              "Skeleton",
              "Hero",
              "SnapKit",
              "DeviceKit",
              "ReerCodable",
              "Tiercel",
              .product(name: "SDWebImage", package: "SDWebImage"),
              .product(name: "SDWebImageWebPCoder", package: "SDWebImageWebPCoder"),
              .product(name: "Gifu", package: "Gifu"),
              "MJRefreshSwift",
              "ProgressHUD",
              .product(name: "Toast", package: "Toast-Swift"),
              .product(name: "Cache", package: "Cache"),
              "KeychainAccess",
              "MagazineLayout"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "AppInfraTests",
            dependencies: ["AppInfra"]
        ),
    ]
)
