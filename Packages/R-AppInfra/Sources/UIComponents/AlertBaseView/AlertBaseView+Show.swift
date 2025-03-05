///
//  @filename   AlertBaseView+Show.swift
//  @package   AppComponents
//  
//  @author     jeffy
//  @date       2024/10/25 
//  @abstract   
//
//  Copyright (c) 2024 and Confidential to jeffy All rights reserved.
//

import UIKit


public extension AlertBaseView {
    
    func showWithNewWindow() {
        oldKeyWindow = UIApplication.shared.alertCompatibleKeyWindow
        let viewController = UIViewController()
        viewController.view = self

        if alertWindow == nil {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.isOpaque = false
            window.windowLevel = AlertWindowLevel
            window.rootViewController = viewController
            alertWindow = window
        }
        alertWindow?.makeKeyAndVisible()
        show()
    }

    func showWithKeyWindow() {
        if let window = UIApplication.shared.alertCompatibleKeyWindow {
            frame = window.bounds
            window.addSubview(self)
            show()
        }
    }

    func showWithCurrentWindow() {
        if let window = AlertControllerUtil.getCurrentWindow() {
            frame = window.bounds
            window.addSubview(self)
            show()
        }
    }

    func showWithCurrentVC() {
        if let rootVC = AlertControllerUtil.topCurrentViewController() {
            rootVC.view.addSubview(self)
            frame = rootVC.view.bounds
            show()
        }
    }

    func showWithTopVC() {
        if let rootVC = AlertControllerUtil.topNavOrTabbarViewController() {
            rootVC.view.addSubview(self)
            frame = rootVC.view.bounds
            show()
        }
    }

    func showWithView(_ view: UIView) {
        view.addSubview(self)
        frame = view.bounds
        show()
    }
}

@MainActor
class AlertControllerUtil {
     static func getCurrentWindow() -> UIWindow? {
        // 返回当前的 window 实例
        return UIApplication.shared.alertCompatibleKeyWindow
    }

    static func topCurrentViewController() -> UIViewController? {
        // 返回当前显示的 viewController
        if var topController = UIApplication.shared.alertCompatibleKeyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }

    static func topNavOrTabbarViewController() -> UIViewController? {
        // 返回顶部的导航或标签栏控制器
        if let rootVC = UIApplication.shared.alertCompatibleKeyWindow?.rootViewController {
            if let navController = rootVC as? UINavigationController {
                return navController.topViewController
            } else if let tabController = rootVC as? UITabBarController {
                return tabController.selectedViewController
            }
            return rootVC
        }
        return nil
    }
}

extension UIApplication {
    var alertCompatibleKeyWindow: UIWindow? {
        if #available(iOS 13, *) {
            return self.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return keyWindow
        }
    }
}
