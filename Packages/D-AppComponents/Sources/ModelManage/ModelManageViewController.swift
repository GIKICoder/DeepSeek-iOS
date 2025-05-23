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

// MARK: - 使用示例
/*
// 在UIKit视图控制器中使用示例：

class MainViewController: UIViewController {
    
    @IBAction func showModelManage(_ sender: UIButton) {
        // 方式1: 直接推送到导航栈
        let modelVC = ModelManageViewController()
        navigationController?.pushViewController(modelVC, animated: true)
        
        // 方式2: 模态展示
        let modelVC2 = ModelManageViewController.create(
            onSave: { provider, apiKey, model, contextSize, temperature in
                print("保存设置: \(provider.name), \(model)")
                // 处理保存逻辑
            },
            onDismiss: {
                print("用户取消了设置")
            }
        )
        let navController = UINavigationController(rootViewController: modelVC2)
        present(navController, animated: true)
        
        // 方式3: 使用便利方法
        let wrappedVC = ModelManageViewController.wrappedInNavigationController()
        present(wrappedVC, animated: true)
    }
}
*/
