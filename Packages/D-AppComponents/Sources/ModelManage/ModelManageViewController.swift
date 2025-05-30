//
//  File.swift
//  AppComponents
//
//  Created by 巩柯 on 2025/5/24.
//

import Foundation
import UIKit
import AppInfra
import SwiftUI

// MARK: - UIKit 包装器
public class ModelManageViewController: AppViewController {
    
    // 可选的回调闭包
    var onSave: ((ModelProvider, String, String, Int, Double) -> Void)?
    var onDismiss: (() -> Void)?
    
    private var hostingController: UIHostingController<ModeManageView>!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
        setupNavigationBar()
    }
    
    private func setupSwiftUIView() {
        view.backgroundColor = .systemGroupedBackground
        let swiftUIView = ModeManageView()
        hostingController = UIHostingController(rootView: swiftUIView)
        
        // 添加为子视图控制器
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // 设置约束
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        addCloseNavigationBar(title: "模型管理")
        navigationBar.setIgnoreStatusBar(true)
        navigationBar.setBackgroundColor(UIColor.systemGroupedBackground)
    }
    
    @objc private func dismissTapped() {
        onDismiss?()
        dismiss(animated: true)
    }
}

// MARK: - 便利的工厂方法
public extension ModelManageViewController {
    
    /// 创建一个包装在导航控制器中的模型管理视图控制器
    static func wrappedInNavigationController() -> UINavigationController {
        let modelVC = ModelManageViewController()
        let navController = UINavigationController(rootViewController: modelVC)
        return navController
    }
    
    /// 创建一个带有回调的模型管理视图控制器
    static func create(
        onSave: ((ModelProvider, String, String, Int, Double) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) -> ModelManageViewController {
        let controller = ModelManageViewController()
        controller.onSave = onSave
        controller.onDismiss = onDismiss
        return controller
    }
}
