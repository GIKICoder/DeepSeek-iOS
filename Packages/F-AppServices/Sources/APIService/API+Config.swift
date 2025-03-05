//
//  File.swift
//  AppServices
//
//  Created by GIKI on 2025/1/11.
//

import Foundation
import Moya

public enum ConfigApi {
    case getUser(id: Int)
    case createUser(name: String, age: Int)
    case logout
}

extension ConfigApi: TargetType {
    public var baseURL: URL {
        return URL("https://api.example.com")!
    }
    
    public var headers: [String : String]? {
        [:]
    }
        
    var baseURLString: String {
        return "https://api.example.com"
    }
    
    public var path: String {
        switch self {
        case .getUser(let id):
            return "/user/\(id)"
        case .createUser:
            return "/user/create"
        case .logout:
            return "/user/logout"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getUser:
            return .get
        case .createUser, .logout:
            return .post
        }
    }
    
    public var task: Task {
        switch self {
        case .getUser, .logout:
            return .requestPlain
        case .createUser(let name, let age):
            let params = ["name": name, "age": age] as [String : Any]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    public var sampleData: Data {
        switch self {
        case .getUser:
            return """
            {
                "code": 200,
                "message": "Success",
                "data": {
                    "id": 1,
                    "name": "John Doe",
                    "age": 30
                }
            }
            """.data(using: .utf8)!
        case .createUser:
            return """
            {
                "code": 200,
                "message": "User created successfully",
                "data": {
                    "id": 2,
                    "name": "Jane Doe",
                    "age": 25
                }
            }
            """.data(using: .utf8)!
        case .logout:
            return """
            {
                "code": 200,
                "message": "Logged out successfully"
            }
            """.data(using: .utf8)!
        }
    }
}
