//
//  DetailModule.swift
//  ModuleRouteExample
//
//  Created by GIKI on 2025/2/14.
//

import Foundation
import ModuleRoute
import UIKit

protocol DetailInterface: MRModule {
    
}

class DetailModule: DetailInterface {
    
    @MRInject var navigator: MRNavigator
    
    static var supportedRoutes: [MRRoute.Type] = [
        DetailRoute.self
    ]
    public init() {
        
    }

    public func handle(route: MRRoute) -> RouteResult {

        switch route {
        case is DetailRoute:
            let detail = DetailViewController()
            return .navigator(detail)
        default:
            return .none
        }
    }
}
