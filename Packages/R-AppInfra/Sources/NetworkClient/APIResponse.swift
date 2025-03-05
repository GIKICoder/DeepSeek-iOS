//
//  APIResponse.swift
//  AppInfra
//
//  Created by GIKI on 2025/1/11.
//

// APIResponse.swift
import Foundation
import ReerCodable

public struct VoidData: Codable {}

@Codable
public struct APIResponse<D: Codable>: Codable {
    public let code: Int
    public let message: String
    public let data: D?

//    enum CodingKeys: String, CodingKey {
//        case code
//        case message
//        case data
//    }

    // 判断响应是否成功
    public var isSuccess: Bool {
        return code == 200
    }
}


