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
    
    public var code: Int {
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
    
    public var message: String {
        switch self {
        case .apiError(_, let message):
            return message
        case .decodingError:
            return "Data analysis error, please try again later."
        case .underlying(let error):
            return error.localizedDescription
        case .noData:
            return "No data available at the moment, please try again later."
        case .invalidResponse:
            return "Invalid response."
        }
    }
    
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        return message
    }
}
