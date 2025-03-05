//
//  NetworkError.swift
//  AppInfra
//
//  Created by GIKI on 2025/1/11.
//

import Foundation

// NetworkError.swift
public enum NetworkError: Error {
    case apiError(code: Int, message: String)
    case decodingError
    case underlying(Error)
    case noData
    case invalidResponse
    // other add
    
    var code: Int {
        switch self {
        case .apiError(let code, _):
            return code
        case .decodingError:
            return -1
        case .underlying(let error):
            return (error as NSError).code
        case .noData:
            return -2
        case .invalidResponse:
            return -3
        }
    }
    
    var message: String {
        switch self {
        case .apiError(_, let message):
            return message
        case .decodingError:
            return "数据解析错误，请稍后重试。"
        case .underlying(let error):
            return error.localizedDescription
        case .noData:
            return "暂无数据，请稍后重试。"
        case .invalidResponse:
            return "无效的响应。"
        }
    }
}
