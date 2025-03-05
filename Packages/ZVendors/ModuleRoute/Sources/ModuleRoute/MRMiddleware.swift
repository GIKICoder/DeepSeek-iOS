//
//  File.swift
//  ModuleRoute
//
//  Created by GIKI on 2025/2/15.
//

import Foundation

public protocol MRMiddleware {
    func process(route: MRRoute, navigator: MRNavigator, next: @escaping (MRRoute) -> RouteResult) -> RouteResult
}

public protocol MRInterceptor {
    func shouldIntercept(route: MRRoute) -> Bool
    func handleInterception(route: MRRoute) -> RouteResult
}

// 日志中间件
public class LoggingMiddleware: MRMiddleware {
    public func process(route: MRRoute, navigator: MRNavigator, next: @escaping (MRRoute) -> RouteResult) -> RouteResult {
        print("➡️ Processing route: \(type(of: route).name)")
        let result = next(route)
        print("⬅️ Route result: \(result)")
        return result
    }
}
