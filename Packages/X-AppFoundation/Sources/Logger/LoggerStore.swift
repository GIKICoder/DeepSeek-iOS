//
//  File.swift
//  AppFoundation
//
//  Created by GIKI on 2025/1/13.
//

import Foundation
import os.log

@available(iOS 14.0, *)
actor LoggerStore {
    private let subsystem: String
    private var loggers: [String: Logger]
    private let shouldShowDetails: Bool
    
    init(subsystem: String, shouldShowDetails: Bool) {
        self.subsystem = subsystem
        self.loggers = [:]
        self.shouldShowDetails = shouldShowDetails
    }
    
    /// 获取或创建指定分类的 Logger
    private func getLogger(for category: String) -> Logger {
        if let existingLogger = loggers[category] {
            return existingLogger
        }
        let logger = Logger(subsystem: subsystem, category: category)
        loggers[category] = logger
        return logger
    }
    
    /// 构建日志消息
    private func buildLogMessage(message: String,
                                 level: AppLogger.Level,
                                 file: String,
                                 function: String,
                                 line: Int) -> String {
#if DEBUG
        if shouldShowDetails {
            let filename = (file as NSString).lastPathComponent
            return "[\(level.rawValue)] [\(filename):\(line)] \(function) → \(message)"
        }
#endif
        return "[\(level.rawValue)] \(message)"
    }
    
    /// 记录日志
    func log(message: String,
             level: AppLogger.Level,
             category: String,
             file: String,
             function: String,
             line: Int) {
        let logger = getLogger(for: category)
        let logMessage = buildLogMessage(message: message, level: level, file: file, function: function, line: line)
        logger.log(level:level.osLogType, "\(logMessage)")
    }
}
