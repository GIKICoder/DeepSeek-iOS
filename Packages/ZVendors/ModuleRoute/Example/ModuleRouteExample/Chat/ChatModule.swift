//
//  ChatModule.swift
//  ModuleRouteExample
//
//  Created by GIKI on 2025/2/15.
//

import UIKit
import ModuleRoute

protocol ChatInterface: MRModule {
    
}

class ChatModule: ChatInterface {
    
    static var supportedRoutes: [MRRoute.Type] = [
        ChatRoute.self
    ]
    
    public init() {}
    
    public func handle(route: MRRoute) -> RouteResult {
        // 根据具体路由做出响应
        switch route {
        case is ChatRoute:
            let detail = ChatViewController()
            return .navigator(detail)
        default:
            return .none
        }
    }
}
