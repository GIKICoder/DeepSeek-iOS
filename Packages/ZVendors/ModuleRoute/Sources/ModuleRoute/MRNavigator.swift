//
//  Navigator.swift
//  ModuleRoute
//
//  Created by GIKI on 2025/2/13.
//

import UIKit

public class MRNavigator {
    
    public let serviceLocator: ServiceLocator
    
    private var middlewares: [MRMiddleware] = []
    private var interceptors: [MRInterceptor] = []
    private var deepLinkParser = DeepLinkParser()
    private var logger: MRLogger = DefaultLogger()
    private var permissionChecker: MRPermissionChecker = DefaultPermissionChecker()
    
    public init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
        MRNavigatorLocator.shared.serviceLocator = serviceLocator
        serviceLocator.register {
            self
        }
        buildServiceLocator()
    }
    
    private var routeToModuleTypeMap: [ObjectIdentifier: (ServiceLocator) -> MRModule] = [:]
    
    public func register<T>(_ type: T.Type = T.self, routes: [MRRoute.Type], _ factory: @escaping () -> T) -> Void {
        serviceLocator.single(type, factory)
        routes.forEach { routeType in
            let key = ObjectIdentifier(routeType)
            routeToModuleTypeMap[key] = { locator in
                guard let instance = try? locator.resolve() as T else {
                    fatalError("Failed to resolve type \(T.self)")
                }
                return instance as! MRModule
            }
        }
        buildServiceLocator()
    }
    
    private func buildServiceLocator() {
        if #available(iOS 13.0, *) {
            Task{
                await serviceLocator.build()
            }
        }
    }
    
    public func addMiddleware(_ middleware: MRMiddleware) {
        middlewares.append(middleware)
    }
    
    public func addInterceptor(_ interceptor: MRInterceptor) {
        interceptors.append(interceptor)
    }
    
    public func navigate(to route: MRRoute,
                         from viewController: UIViewController,
                         navigationType: NavigationType = .push,
                         animated: Bool = true,
                         completion: (() -> Void)? = nil) {
        
        if let permissionResult = checkPermission(for: route) {
            handleResult(permissionResult, from: viewController, navigationType: navigationType, animated: animated, completion: completion)
            return
        }
        
        let result = processMiddlewares(route: route)
        handleResult(result, from: viewController, navigationType: navigationType, animated: animated, completion: completion)
    }
    
    public func registerDeepLinkHandler(scheme: String, handler: @escaping (URL) -> MRRoute?) {
        deepLinkParser.register(scheme: scheme, handler: handler)
    }
    
    public func handleDeepLink(_ url: URL) -> Bool {
        guard let route = deepLinkParser.parse(url: url) else {
            return false
        }
        
        if let rootVC = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            navigate(to: route, from: rootVC)
            return true
        }
        return false
    }
    
    private func processMiddlewares(route: MRRoute, index: Int = 0) -> RouteResult {
        if index >= middlewares.count {
            return handleRouteDirectly(route: route)
        }
        
        let middleware = middlewares[index]
        return middleware.process(route: route, navigator: self) { [weak self] route in
            guard let self = self else { return .none }
            return self.processMiddlewares(route: route, index: index + 1)
        }
    }
    
    private func handleRouteDirectly(route: MRRoute) -> RouteResult {
        for interceptor in interceptors {
            if interceptor.shouldIntercept(route: route) {
                return interceptor.handleInterception(route: route)
            }
        }
        
        let routeTypeKey = ObjectIdentifier(type(of: route))
        guard let moduleFactory = routeToModuleTypeMap[routeTypeKey] else {
            logger.log(level: .warning, message: "No module found for route: \(type(of: route))", metadata: nil)
            return .none
        }
        
        let module = moduleFactory(serviceLocator)
        let result = module.handle(route: route)
        logRoute(route, result: result)
        return result
    }
    
    private func handleResult(_ result: RouteResult,
                              from viewController: UIViewController,
                              navigationType: NavigationType,
                              animated: Bool,
                              completion: (() -> Void)?) {
        switch result {
        case .navigator(let targetVC):
            perform(navigation: navigationType,
                    from: viewController,
                    to: targetVC,
                    animated: animated,
                    completion: completion)
        case .handler(let handler):
            handler()
            completion?()
        case .service(_),
                .value(_),
                .none:
            completion?()
        }
    }
    
    private func perform(navigation type: NavigationType,
                         from: UIViewController,
                         to: UIViewController,
                         animated: Bool,
                         completion: (() -> Void)?) {
        switch type {
        case .push:
            from.navigationController?.pushViewController(to, animated: animated)
            completion?()
        case .present:
            from.present(to, animated: animated, completion: completion)
        case .modal:
            to.modalPresentationStyle = .fullScreen
            from.present(to, animated: animated, completion: completion)
        case .replace:
            guard let navigationController = from.navigationController else {
                completion?()
                return
            }
            var viewControllers = navigationController.viewControllers
            viewControllers.removeLast()
            viewControllers.append(to)
            navigationController.setViewControllers(viewControllers, animated: animated)
            completion?()
        case .custom(let handler):
            handler(from, to)
            completion?()
        }
    }
    
    private func checkPermission(for route: MRRoute) -> RouteResult? {
        guard permissionChecker.hasPermission(for: route) else {
            return permissionChecker.handleUnauthorized(route: route)
        }
        return nil
    }
    
    private func logRoute(_ route: MRRoute, result: RouteResult) {
        logger.log(level: .info,
                   message: "Processing route: \(type(of: route))",
                   metadata: ["params": route.params, "result": String(describing: result)])
    }
}
