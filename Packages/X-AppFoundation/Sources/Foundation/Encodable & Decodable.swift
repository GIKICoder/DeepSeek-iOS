//
//  Encodable & Decodable.swift
//  AppFoundation
//
//  Created by GIKI on 2025/1/10.
//

import Foundation

extension Decodable {
  public static func decode<T: Decodable>(data: Data?) -> T? {
    guard let data else {
      return nil
    }
    return try? JSONDecoder().decode(T.self, from: data)
  }
}

extension Encodable {
  public var data: Data? {
    try? JSONEncoder().encode(self)
  }
}

extension Array where Element: Decodable {
  public static func decode(data: Data?) -> [Element]? {
    guard let data else {
      return nil
    }
    return try? JSONDecoder().decode([Element].self, from: data)
  }
}

extension Array where Element: Encodable {
  public var data: Data? {
    try? JSONEncoder().encode(self)
  }
}
