//
//  Project.swift
//  DeepSeek
//
//  Created by GIKI
//

import ProjectDescription

let projectName: String = "DeepSeek"
let deploymentTarget: String = "14.0"
let bundleId: String = "com.giki.deepseek"

let packageNames = [
    "A-AppDomain",
    "D-AppComponents",
    "F-AppServices",
    "R-AppInfra",
    "X-AppFoundation"
]

let packageTargets = [
    "AppDomain",
    "AppComponents",
    "AppServices",
    "AppInfra",
    "AppFoundation"
]
let project = Project(
    name: projectName,
    packages: packageNames.map { Package.package(path: "Packages/\($0)") },
    targets: [
        .target(
            name: projectName,
            destinations: .iOS,
            product: .app,
            bundleId: bundleId,
            deploymentTargets: .iOS(deploymentTarget),
            infoPlist: .file(path: "Info.plist"),
            sources: ["\(projectName)/Sources/**"],
            resources: ["\(projectName)/Resources/**"],
            dependencies: packageTargets.map { TargetDependency.package(product: $0) },
            additionalFiles: [
                "Project.swift",
            ]
        ),
    ]
)
