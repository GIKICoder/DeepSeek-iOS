// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "DSBridge",
    platforms: [
        .iOS(.v8) // 指定支持的最低平台版本
    ],
    products: [
        .library(
            name: "DSBridge",
            targets: ["DSBridge"]
        ),
    ],
    dependencies: [
        // 如果有其他依赖项，可以在这里声明
    ],
    targets: [
        .target(
            name: "DSBridge",
            path: "Sources", // 源代码所在的目录
            publicHeadersPath: ".", // 公共头文件所在的目录
            linkerSettings: [
                .linkedFramework("UIKit") // 链接 UIKit 框架
            ]
        ),
        // 如果有测试目标，可以在这里添加
        // .testTarget(
        //     name: "dsBridgeTests",
        //     dependencies: ["dsBridge"]
        // ),
    ],
    swiftLanguageVersions: [.v5] // 指定 Swift 版本
)
