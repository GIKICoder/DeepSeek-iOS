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
    
    // 判断响应是否成功
    public var isSuccess: Bool {
        return code == 200
    }
}


@Codable
public struct DPResponse<D: Codable>: Codable {
    public var code: Int = 0
    public var message: String = ""
    public var data: DPBizWrapper<D>?
    
    // 判断响应是否成功
    public var isSuccess: Bool {
        return code == 200
    }
}

@Codable
public struct DPBizWrapper<T: Codable>: Codable {
    public var biz_code: Int = 0
    public var biz_msg: String = ""
    public var biz_data: T?
}


