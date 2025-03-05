//
//  File.swift
//  ModuleRoute
//
//  Created by GIKI on 2025/2/15.
//

import Foundation

// 权限控制
public protocol MRPermissionChecker {
    func hasPermission(for route: MRRoute) -> Bool
    func handleUnauthorized(route: MRRoute) -> RouteResult
}

class DefaultPermissionChecker: MRPermissionChecker {
    func hasPermission(for route: MRRoute) -> Bool {
        return true
    }
    func handleUnauthorized(route: MRRoute) -> RouteResult {
        return .none
    }
}
