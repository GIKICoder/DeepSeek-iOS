//
//  File.swift
//  ModuleRoute
//
//  Created by GIKI on 2025/2/15.
//

import Foundation
import UIKit

// MARK: - Core Protocols
public protocol MRRoute {
    static var name: String { get }
    var params: [String: Any] { get }
    var callback: ((Any?) -> Void)? { get }
}

public enum RouteResult {
    case navigator(UIViewController)
    case handler(() -> Void)
    case service(Any)
    case value(Any)
    case none
}


public protocol MRModule {
    static var supportedRoutes: [MRRoute.Type] { get }
    func handle(route: MRRoute) -> RouteResult
}

// MARK: - Basic Route Implementation
public struct BasicRoute: MRRoute {
    public static var name: String { "" }
    public let params: [String: Any]
    public let callback: ((Any?) -> Void)?
    
    public init(params: [String: Any] = [:], callback: ((Any?) -> Void)? = nil) {
        self.params = params
        self.callback = callback
    }
}

// MARK: - Navigation Types
public enum NavigationType {
    case push
    case present
    case modal
    case replace
    case custom((UIViewController, UIViewController) -> Void)
}
