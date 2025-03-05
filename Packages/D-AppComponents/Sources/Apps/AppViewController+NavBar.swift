//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/13.
//

import Foundation
import AppFoundation
import UIKit
import AppInfra
//import IGListKit

public extension AppViewController {
    
    func addBackNavigationBar(title: String? = nil,
                             target: AnyObject? = nil,
                             action: Selector? = #selector(appCancel)) {
        addNavigationbar()
        // 如果 target 为 nil，则使用 self 作为默认值
        let finalTarget = target ?? self
        navigationBar.addLeft(UIImage(named: "App_back_ic"), target: finalTarget, action: action)
        if let title {
            navigationBar.centerLabel.text = title
        }
    }
    
    func addCloseNavigationBar(title:String? = nil,
                              target: AnyObject? = nil,
                              action: Selector = #selector(appCancel)) {
        addNavigationbar()
        let finalTarget = target ?? self
        navigationBar.addLeft(UIImage(named: "App_close_ic"),target: finalTarget,action: action)
        if let title {
            navigationBar.centerLabel.text = title
        }
    }
}
