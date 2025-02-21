// swift-tools-version:5.9
//
//  Package.swift
//  DeepSeek
//
//  Created by GIKI
//

import PackageDescription
#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        // "Alamofire": .framework, // default is .staticFramework
        // "Then": .framework,
        // "RxSwift": .framework,
        // "RxCocoa": .framework,
        // "FlexLayout": .framework,
        // "PinLayout": .framework,
    ]
)
#endif

let package = Package(
    name: "SomeSample",
    dependencies: [
        // Add your own dependencies here:
        // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        // You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies
        // .package(url: "https://github.com/devxoul/Then", from: "3.0.0"), // Then
        // .package(url: "https://github.com/ReactiveX/RxSwift", from: "6.7.1"), // RxSwift
        // .package(url: "https://github.com/layoutBox/FlexLayout", from: "2.0.0"), // FlexLayout
        // .package(url: "https://github.com/layoutBox/PinLayout", from: "1.0.0"), // PinLayout
    ]
)
