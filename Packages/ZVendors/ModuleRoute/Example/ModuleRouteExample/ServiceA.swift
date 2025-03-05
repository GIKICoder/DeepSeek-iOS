//
//  ModuleA.swift
//  ModuleRouteExample
//
//  Created by GIKI on 2025/2/14.
//

import Foundation
import UIKit

class ServiceA: ServiceAInterface {
    
    func showAlertWithTap() {
        // 创建 UIAlertController
        let alertController = UIAlertController(
            title: "点击了我了",
            message: nil,
            preferredStyle: .alert
        )
        
        // 创建确认按钮
        let okAction = UIAlertAction(
            title: "知道了",
            style: .default,
            handler: nil
        )
        
        // 添加按钮到 alertController
        alertController.addAction(okAction)
        
        // 获取当前最顶层的 ViewController 并显示 alert
        if let topViewController = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController() {
            topViewController.present(alertController, animated: true, completion: nil)
        }
    }
}

// 辅助扩展，用于获取最顶层的 ViewController
extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
}
