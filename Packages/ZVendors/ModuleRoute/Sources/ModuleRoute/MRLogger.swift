//
//  File.swift
//  ModuleRoute
//
//  Created by GIKI on 2025/2/15.
//

import Foundation

public protocol MRLogger {
    func log(level: MRLogLevel, message: String, metadata: [String: Any]?)
}

public enum MRLogLevel {
    case debug, info, warning, error
}

class DefaultLogger: MRLogger {
    func log(level: MRLogLevel, message: String, metadata: [String: Any]?) {
        #if DEBUG
        print("[\(level)] \(message) \(metadata ?? [:])")
        #endif
    }
}
