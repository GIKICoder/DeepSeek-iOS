//
//  SceneDelegate.swift
//  DeepSeek
//
//  Created by GIKI
//


import UIKit
import AppDomain
import AppInfra
import AppFoundation
import AppServices

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        
        AppDomain.shared.configure {
            let root = AppNavigationController(rootViewController: MainViewController())
            return root
        }
        window = AppDomain.shared.handleSceneWillConnect(scene, session: session, options: connectionOptions)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        AppDomain.shared.handleSceneDidDisconnect(scene)
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        AppDomain.shared.handleActiveState()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        AppDomain.shared.handleInactiveState()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        AppDomain.shared.handleEnterForeground()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        AppDomain.shared.handleEnterBackground()
    }
}
