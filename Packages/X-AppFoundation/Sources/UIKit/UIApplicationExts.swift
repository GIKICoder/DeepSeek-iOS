//
//  File.swift
//  AppFoundation
//
//  Created by GIKI on 2025/1/13.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit

public extension UIApplication {
    
    ///  返回当前的 window 实例
    /// - Returns: <#description#>
    static var getCurrentWindow: UIWindow? {
        return UIApplication.shared.compatibleKeyWindow
    }
    
    ///  Run a block in background after app resigns activity
    func runInBackground(_ closure: @escaping () -> Void, expirationHandler: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let taskID: UIBackgroundTaskIdentifier
            if let expirationHandler = expirationHandler {
                taskID = self.beginBackgroundTask(expirationHandler: expirationHandler)
            } else {
                taskID = self.beginBackgroundTask(expirationHandler: { })
            }
            closure()
            self.endBackgroundTask(taskID)
        }
    }

    ///  Get the top most view controller from the base view controller; default param is UIWindow's rootViewController
    class func topViewController(_ base: UIViewController? = UIApplication.getCurrentWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

public extension UIApplication {
    var compatibleKeyWindow: UIWindow? {
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
#endif
