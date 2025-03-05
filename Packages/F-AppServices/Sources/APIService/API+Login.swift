//
//  File.swift
//  AppServices
//
//  Created by GIKI on 2025/1/14.
//

import Foundation
import AppInfra
import Moya

public enum LoginAPI {
    case authDeviceId(did: String)
}

extension LoginAPI: NetworkAPI {

    public var customHeaders: [String: String] {
        [:]
    }
    public var path: String {
        switch self {
        case .authDeviceId:
            return "/api/v1/xxxxx"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .authDeviceId:
            return .post
        }
    }
    
    public var task: Task {
        switch self {
        case .authDeviceId(let did):
            let params = ["did": did] as [String : Any]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    public var sampleData: Data {
        switch self {
        case .authDeviceId(_):
            return """
                        {
                            "code": 200,
                            "message": "Success",
                            "data": {
                            }
                        }
                        """.data(using: .utf8)!
        }
    }
}

