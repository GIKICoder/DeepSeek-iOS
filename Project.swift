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


let project = Project(
    name: projectName,
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
            dependencies: [
                // .external(name: "Then"),
                // .external(name: "RxSwift"),
                // .external(name: "RxCocoa"),
                // .external(name: "FlexLayout"),
                // .external(name: "PinLayout"),
            ],
            additionalFiles: [
                "Project.swift",
            ]
        ),
    ]
)
