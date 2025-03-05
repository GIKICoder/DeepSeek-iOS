//
//  DataExts.swift
//  AppFoundation
//
//  Created by GIKI on 2025/1/13.
//

import Foundation
import CommonCrypto

// MARK: - Data Extension
public extension Data {
    // MD5
    var md5: String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        
        _ = self.withUnsafeBytes { body in
            CC_MD5(body.baseAddress, CC_LONG(self.count), &digest)
        }
        
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    // SHA256
    var sha256: String {
        let length = Int(CC_SHA256_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        
        _ = self.withUnsafeBytes { body in
            CC_SHA256(body.baseAddress, CC_LONG(self.count), &digest)
        }
        
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

// 输出格式化 jsonString
extension Data {
    
    public var prettyJSON: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self),
              let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
              let prettyString = String(data: data, encoding: .utf8) else { return nil }
        return prettyString
    }
}
