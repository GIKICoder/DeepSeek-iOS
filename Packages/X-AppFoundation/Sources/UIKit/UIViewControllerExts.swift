//
//  UIViewControllerExts.swift
//  AppFoundation
//
//  Created by GIKI on 2025/1/11.
//

import UIKit

extension UIViewController {
  public static func getTopViewController(from root: UIViewController?) -> UIViewController? {
    guard let root else { return nil }

    var current: UIViewController? = root

    while let next = current?.presentedViewController {
      current = next
    }

    if let tab = current as? UITabBarController {
      current = getTopViewController(from: tab.selectedViewController)
    } else if let nav = current as? UINavigationController {
      current = getTopViewController(from: nav.visibleViewController)
    }

    return current
  }
}

