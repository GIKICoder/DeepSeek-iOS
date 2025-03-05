//
//  DetailRoute.swift
//  ModuleRouteExample
//
//  Created by GIKI on 2025/2/14.
//

import Foundation
import ModuleRoute

struct DetailRoute: MRRoute {
    var params: [String : Any] = [:]
    
    var callback: ((Any?) -> Void)?
    
    static var name: String = "detail"
}


struct ChatRoute: MRRoute {
    var params: [String : Any] = [:]
    
    var callback: ((Any?) -> Void)?
    
    static var name: String = "chat"
}
