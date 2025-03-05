//
//  CollectionExts.swift
//  AppFoundation
//
//  Created by GIKI on 2025/1/10.
//

import UIKit

import Foundation

extension Collection {
  public var isNotEmpty: Bool {
    !isEmpty
  }
}

// 为 Dictionary 添加扩展
extension Dictionary {
    
    public func toJsonString() -> String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: []) {
            return String(data: jsonData, encoding: .utf8)
        }
        return nil
    }
}
