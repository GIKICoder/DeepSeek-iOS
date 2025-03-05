//
//  AppDelegate.swift
//  ModuleRouteExample
//
//  Created by GIKI on 2025/2/14.
//

import UIKit
import ModuleRoute

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    public lazy var myServiceLocator = startServiceLocator()
//    {
////      AppModule()
//    }
    private var navigator: MRNavigator!
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupRoute()
      
        return true
    }

    private func setupServiceLocator() async {
        await myServiceLocator.build()
    }
    
    private func setupRoute() {
        navigator = MRNavigator(serviceLocator:myServiceLocator)
        navigator.register(DetailInterface.self, routes: DetailModule.supportedRoutes) {
            DetailModule()
        }
        navigator.register(ChatInterface.self, routes: ChatModule.supportedRoutes) {
            ChatModule()
        }
        
//        navigator.register(interfaceType: DetailInterface.self, moduleType: DetailModule.self)
//        navigator.register(moduleType: DetailModule.self)
//        navigator.register(moduleType: ChatModule.self)
    }


    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
   
}


class AppModule: ServiceLocatorModule {

    override func build() {
        single(DetailInterface.self) {
            DetailModule()
        }
//        single {
//            ChatModule()
//        }
        single(ChatInterface.self) {
            ChatModule()
        }
    }
}
