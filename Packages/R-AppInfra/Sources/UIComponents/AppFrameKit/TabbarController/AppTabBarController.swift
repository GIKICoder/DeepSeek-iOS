//
//  AppTabBarController.swift
//  AppInfra
//
//  Created by GIKI on 2025/1/13.
//

import UIKit
import AppFoundation

// MARK: - AppTabBarController
open class AppTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    public var customTabBar: AppTabBar!
    private var tabBarItems: [TabBarItem] = []
    
    public var tabBarHeight: CGFloat = 60 {
        didSet {
            updateLayout()
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupCustomTabBar()
    }
    
    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateLayout() // 更新布局
    }
    
    private func setupCustomTabBar() {
        // 移除原生tabBar
        tabBar.isHidden = true
        
        // 创建自定义tabBar
        let tabBarHeight: CGFloat = tabBarHeight + view.safeAreaInsets.bottom
        let frame = CGRect(x: 0,
                          y: view.frame.height - tabBarHeight,
                          width: view.frame.width,
                          height: tabBarHeight)
        
        customTabBar = AppTabBar(frame: frame)
        customTabBar.delegate = self
        view.addSubview(customTabBar)
    }
    
    // 添加子控制器和对应的TabBarItem
    public func addChildViewController(_ viewController: UIViewController, tabBarItem: TabBarItem) {
        tabBarItems.append(tabBarItem)
        addChild(viewController)
        customTabBar.setupItems(tabBarItems)
    }
    
    /// 更新TabbarLayout
    func updateLayout() {
        let tabBarHeight: CGFloat = tabBarHeight + view.safeAreaInsets.bottom
        let frame = CGRect(x: 0,
                          y: view.frame.height - tabBarHeight,
                          width: view.frame.width,
                          height: tabBarHeight)
        
        customTabBar.frame = frame
        logDebug("\(view.safeAreaInsets.bottom)")
    }
}

// MARK: - Public
extension AppTabBarController {
    
   public func tabBar(didSelectItemAt index: Int) {
       customTabBar.didSelectAtIndex(index)
   }
    
}

// MARK: - AppTabBarDelegate
extension AppTabBarController: AppTabBarDelegate {
    
    func tabBar(_ tabBar: AppTabBar, didSelectItemAt index: Int) {
        selectedIndex = index
    }
    
}
