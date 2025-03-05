//
//  File.swift
//  ModuleRoute
//
//  Created by GIKI on 2025/2/15.
//

import Foundation

public struct DeepLinkParser {
    private var schemeHandlers: [String: (URL) -> MRRoute?] = [:]
    
    public mutating func register(scheme: String, handler: @escaping (URL) -> MRRoute?) {
        schemeHandlers[scheme] = handler
    }
    
    public func parse(url: URL) -> MRRoute? {
        guard let scheme = url.scheme else { return nil }
        return schemeHandlers[scheme]?(url)
    }
}

extension MRRoute {
    static func from(url: URL) -> MRRoute? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        var params: [String: Any] = [:]
        components.queryItems?.forEach { item in
            params[item.name] = item.value
        }
        
        return BasicRoute(params: params)
    }
}
