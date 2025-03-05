//
//  AppLogger.swift
//  AppFoundation
//
//  Created by GIKI on 2025/1/11.
//

import Foundation
import os.log

/// 应用日志管理器
@available(iOS 14.0, *)
final public class AppLogger {
    
    // MARK: - 日志级别定义
    
    public enum Level: String {
        case debug = "💚 DEBUG"
        case info = "💙 INFO"
        case warning = "💛 WARNING"
        case error = "❤️ ERROR"
        
        /// 转换为系统日志类型
        var osLogType: OSLogType {
            switch self {
            case .debug:     return .debug
            case .info:      return .info
            case .warning:   return .default
            case .error:     return .error
            }
        }
    }
    
    // MARK: - 属性
    
    /// 单例
    static public let shared = AppLogger()
    
    /// 子系统标识符（通常使用应用的 Bundle ID）
    private let subsystem: String
    
    /// 是否在 Debug 模式下打印详细信息
    private let shouldShowDetails: Bool
    
    /// 内部 LoggerStore Actor
    private let loggerStore: LoggerStore
    
    // MARK: - 初始化
    
    private init(subsystem: String = Bundle.main.bundleIdentifier ?? "com.app.logger",
                 shouldShowDetails: Bool = true) {
        self.subsystem = subsystem
        self.shouldShowDetails = shouldShowDetails
        self.loggerStore = LoggerStore(subsystem: subsystem, shouldShowDetails: shouldShowDetails)
    }
    
    // MARK: - 公共方法
    
    /// 记录调试日志
    public func debug(_ message: String,
               category: String = "default",
               file: String = #file,
               function: String = #function,
               line: Int = #line) {
        Task {
            await loggerStore.log(message: message, level: .debug, category: category, file: file, function: function, line: line)
        }
    }
    
    /// 记录信息日志
    public func info(_ message: String,
              category: String = "default",
              file: String = #file,
              function: String = #function,
              line: Int = #line) {
        Task {
            await loggerStore.log(message: message, level: .info, category: category, file: file, function: function, line: line)
        }
    }
    
    /// 记录警告日志
    public func warning(_ message: String,
                 category: String = "default",
                 file: String = #file,
                 function: String = #function,
                 line: Int = #line) {
        Task {
            await loggerStore.log(message: message, level: .warning, category: category, file: file, function: function, line: line)
        }
    }
    
    /// 记录错误日志
    public func error(_ message: String,
               category: String = "default",
               file: String = #file,
               function: String = #function,
               line: Int = #line) {
        Task {
            await loggerStore.log(message: message, level: .error, category: category, file: file, function: function, line: line)
        }
    }
    
    /// 记录错误日志（带错误对象）
    public func error(_ error: Error,
               message: String? = nil,
               category: String = "default",
               file: String = #file,
               function: String = #function,
               line: Int = #line) {
        let errorMessage = message ?? error.localizedDescription
        let detailedMessage = "\(errorMessage)\nError: \(error)"
        Task {
            await loggerStore.log(message: detailedMessage, level: .error, category: category, file: file, function: function, line: line)
        }
    }
}

// MARK: - 便利扩展

extension AppLogger {
    /// 网络日志分类
    static let network = "network"
    
    /// UI 日志分类
    static let ui = "ui"
    
    /// 业务逻辑日志分类
    static let business = "business"
}

// MARK: - 使用示例

// 基本用法
public extension AppLogger {
    static func examples() {
        // 默认分类使用
        AppLogger.shared.debug("Debug message")
        AppLogger.shared.info("Info message")
        AppLogger.shared.warning("Warning message")
        AppLogger.shared.error("Error message")
        
        // 使用特定分类
        AppLogger.shared.debug("Network request started", category: AppLogger.network)
        AppLogger.shared.info("User interface updated", category: AppLogger.ui)
        
        // 记录错误
        let error = NSError(domain: "com.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"])
        AppLogger.shared.error(error, message: "Failed to process request")
    }
}
