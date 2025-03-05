//
//  File.swift
//  AppComponents
//
//  Created by GIKI on 2025/2/12.
//

import Foundation
import RouteComposer

public final class AppRouter {
    
    public static let router: Router = {
        var defaultRouter = GlobalInterceptorRouter(router: FailingRouter(router: DefaultRouter()))
        defaultRouter.addGlobal(NavigationDelayingInterceptor(strategy: .wait))
        return defaultRouter
    }()
    
}
