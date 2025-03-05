// The Swift Programming Language
// https://docs.swift.org/swift-book

import AppComponents
import AppInfra
import AppFoundation
import UIKit
import SDWebImage
import SDWebImageWebPCoder

public class AppDomain {
    
    public static let shared = AppDomain()
    
    // MARK: - Types
    public enum WindowMode {
        case scene
        case legacy // appdelegate
    }
    public typealias RootViewControllerProvider = () -> UIViewController
    
    // MARK: - Properties
    private var windows: [UIWindow] = []
    private var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    private var windowMode: WindowMode = .legacy
    private var rootViewControllerProvider: RootViewControllerProvider?
    
    // MARK: - Configuration
    public func configure(rootViewControllerProvider: @escaping RootViewControllerProvider) {
        self.rootViewControllerProvider = rootViewControllerProvider
    }
    
    // MARK: - Window Management
    public func configureMainWindow(mode: WindowMode = .legacy,
                                    scene: UIWindowScene? = nil,
                                    frame: CGRect = UIScreen.main.bounds) -> UIWindow? {
        guard let provider = rootViewControllerProvider else {
            assertionFailure("RootViewControllerProvider not set. Call configure() first.")
            return nil
        }
        windowMode = mode
        let window: UIWindow
        
        switch mode {
        case .scene:
            guard let windowScene = scene else {
                fatalError("WindowScene is required for scene mode")
            }
            window = UIWindow(windowScene: windowScene)
        case .legacy:
            window = UIWindow(frame: frame)
        }
        
        // 配置根视图控制器
        // 使用提供的 rootViewController
        window.rootViewController = provider()
        window.makeKeyAndVisible()
        windows.append(window)
        
        return window
    }
    
    // MARK: - Application Lifecycle
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        self.launchOptions = launchOptions
        setupBasicConfigurations()
    }
    
    // MARK: - Scene Lifecycle
    public func handleSceneWillConnect(_ scene: UIScene,
                                       session: UISceneSession,
                                       options: UIScene.ConnectionOptions) -> UIWindow? {
        guard let windowScene = scene as? UIWindowScene else { return nil }
        return configureMainWindow(mode: .scene, scene: windowScene)
    }
    
    public func handleSceneDidDisconnect(_ scene: UIScene) {
        guard let windowScene = scene as? UIWindowScene else { return }
        windows.removeAll { $0.windowScene === windowScene }
    }
    
    // MARK: - State Management
    public func handleActiveState() {
        // 处理活跃状态
        updateTrackingStatus(true)
        refreshContent()
    }
    
    public func handleInactiveState() {
        // 处理非活跃状态
        updateTrackingStatus(false)
    }
    
    public func handleEnterForeground() {
        // 处理进入前台
        refreshContent()
        checkAppUpdate()
    }
    
    public func handleEnterBackground() {
        // 处理进入后台
        saveApplicationState()
    }
    
    // MARK: - Private Setup Methods
    private func setupBasicConfigurations() {
        setupThirdPartySDKs()
        setupNetworkConfiguration()
        setupUserConfiguration()
//        setupNotifications()
    }
    
    private func setupRootViewController(for window: UIWindow) {
        let tabbar = AppTabBarController()
        let navigation = AppNavigationController(rootViewController: tabbar)
        window.rootViewController = navigation
    }
    
   
    
    // MARK: - State Handling Methods
    private func updateTrackingStatus(_ isActive: Bool) {
        // 更新追踪状态
    }
    
    private func refreshContent() {
        // 刷新内容
    }
    
    private func checkAppUpdate() {
        // 检查应用更新
    }
    
    private func saveApplicationState() {
        // 保存应用状态
    }
    
    // MARK: - Deep Link Handling
    public func handleDeepLink(_ url: URL) -> Bool {
        // 处理深度链接
        return true
    }
    
    // MARK: - Push Notifications
    public func handleRemoteNotification(userInfo: [AnyHashable: Any]) {
        // 处理远程推送
    }
    
    public func handleNotificationResponse(_ response: UNNotificationResponse) {
        // 处理通知响应
    }
}

extension AppDomain {
    private func setupThirdPartySDKs() {
        // 配置第三方SDK
        setupSDWebImage()
    }
    
    private func setupSDWebImage() {
        // Add coder
        let WebPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(WebPCoder)
        // 自定义缓存键过滤器
        SDWebImageManager.shared.cacheKeyFilter  = SDWebImageCacheKeyFilter {[weak self] url in
            if let cacheKey = self?.getLastSegmentBeforeQueryString(from: url) {
                let retval = "app.image." + cacheKey
                return retval
            }
            return url.absoluteString.lowercased()
        }
        SDWebImageDownloader.shared.config.downloadTimeout = 15.0
        SDImageCache.shared.config.maxDiskAge = 60 * 60 * 24 * 7 // 7天
    }
    
    private func getLastSegmentBeforeQueryString(from url: URL?) -> String? {
        guard let url = url else {
            return nil
        }
        /*
        let hosts = ["pic.xxx.com", "pic.xxxx.ai"]
        guard let host = url.host, hosts.contains(host) else {
            return nil
        }
         */
        // 获取问号之前的路径部分
        let pathWithoutQuery = url.path

        // 分割路径并获取最后一个组件
        let lastPathComponent = pathWithoutQuery.components(separatedBy: "/").last
        return lastPathComponent
    }
}

extension AppDomain {
    
    private func setupNetworkConfiguration() {
        
    }
}

extension AppDomain {
    
    private func setupUserConfiguration() {
        // 配置用户相关
    }
   
}


extension AppDomain {
    
    private func setupNotifications() {
        // 配置推送通知
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}


// MARK: - Example
/**  使用传统 AppDelegate 时：
 @main
 class AppDelegate: UIResponder, UIApplicationDelegate {
 var window: UIWindow?
 
 func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
 // 配置 rootViewController 提供者
        AppDomain.shared.configure {
            let tabbar = TabBarViewController()
            return AppNavigationController(rootViewController: tabbar)
        }
        
 AppDomain.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
 window = AppDomain.shared.configureMainWindow(mode: .legacy)
 return true
 }
 
 func applicationDidBecomeActive(_ application: UIApplication) {
 AppDomain.shared.handleActiveState()
 }
 
 func applicationWillResignActive(_ application: UIApplication) {
 AppDomain.shared.handleInactiveState()
 }
 
 func applicationDidEnterBackground(_ application: UIApplication) {
 AppDomain.shared.handleEnterBackground()
 }
 
 func applicationWillEnterForeground(_ application: UIApplication) {
 AppDomain.shared.handleEnterForeground()
 }
 }
 
 */

/**使用 SceneDelegate 时：
 
 class SceneDelegate: UIResponder, UIWindowSceneDelegate {
 var window: UIWindow?
 
 func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
 // 配置 rootViewController 提供者
         AppDomain.shared.configure {
             let tabbar = TabBarViewController()
             return AppNavigationController(rootViewController: tabbar)
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
 */

