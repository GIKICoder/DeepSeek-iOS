//
//  NetworkAPI.swift
//  AppInfra
//
//  Created by GIKI on 2025/1/11.
//

import Foundation
import Moya

// 定义参数转换协议
public protocol JSONParameter {
    func toJSON() -> [String: Any]
}

public protocol NetworkAPI: TargetType {
    /// 继承 NetworkAPI 会默认实现公参. 如果接口需要添加额外的header
    /// 添加在customHeaders 中即可
    var customHeaders: [String: String] { get }
}

public extension NetworkAPI {
    
    var baseURL: URL {
        return URL(string: NetworkClient.shared.currentBaseURL)!
    }
    
    var headers: [String: String]?  {
        var headers = NetworkClient.shared.getHeaders()
        headers.merge(customHeaders) { current, _ in current }
        return headers
    }
    
    // 默认实现，可以根据需要重写
    var customHeaders: [String : String] {
        return [:]
    }
    

    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        return ""
    }

    /// The HTTP method used in the request.
    var method: Moya.Method {
        return .get
    }

    /// Provides stub data for use in testing. Default is `Data()`.
    var sampleData: Data {
        return Data()
    }

    /// The type of HTTP task to be performed.
    var task: Task {
        return .requestPlain
    }
    
    // 添加便利方法处理编码方式
    func encodeParameters(_ parameters: [String: Any]) -> Task {
        let encoding: ParameterEncoding = method == .get ? URLEncoding.queryString : JSONEncoding.default
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
}

