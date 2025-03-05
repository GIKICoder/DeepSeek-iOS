//
//  AppLogger.swift
//  AppFoundation
//
//  Created by GIKI on 2025/1/11.
//

import Foundation

// MARK: - Global Logging Functions

/// 记录调试级别的日志信息
/// - Parameters:
///   - message: 日志消息
///   - category: 日志分类，默认为 "default"
///   - file: 调用的文件名，默认为当前文件
///   - function: 调用的函数名，默认为当前函数
///   - line: 调用的代码行号，默认为当前行
public func logDebug(
    _ message: String,
    category: String = "default",
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    AppLogger.shared.debug(message, category: category, file: file, function: function, line: line)
}

/// 记录信息级别的日志信息
/// - Parameters:
///   - message: 日志消息
///   - category: 日志分类，默认为 "default"
///   - file: 调用的文件名，默认为当前文件
///   - function: 调用的函数名，默认为当前函数
///   - line: 调用的代码行号，默认为当前行
public func logInfo(
    _ message: String,
    category: String = "default",
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    AppLogger.shared.info(message, category: category, file: file, function: function, line: line)
}

/// 记录警告级别的日志信息
/// - Parameters:
///   - message: 日志消息
///   - category: 日志分类，默认为 "default"
///   - file: 调用的文件名，默认为当前文件
///   - function: 调用的函数名，默认为当前函数
///   - line: 调用的代码行号，默认为当前行
public func logWarning(
    _ message: String,
    category: String = "default",
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    AppLogger.shared.warning(message, category: category, file: file, function: function, line: line)
}

/// 记录错误级别的日志信息
/// - Parameters:
///   - message: 日志消息
///   - category: 日志分类，默认为 "default"
///   - file: 调用的文件名，默认为当前文件
///   - function: 调用的函数名，默认为当前函数
///   - line: 调用的代码行号，默认为当前行
public func logError(
    _ message: String,
    category: String = "default",
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    AppLogger.shared.error(message, category: category, file: file, function: function, line: line)
}

/// 记录错误对象的日志信息
/// - Parameters:
///   - error: 错误对象
///   - message: 可选的额外错误描述信息
///   - category: 日志分类，默认为 "default"
///   - file: 调用的文件名，默认为当前文件
///   - function: 调用的函数名，默认为当前函数
///   - line: 调用的代码行号，默认为当前行
public func logError(
    _ error: Error,
    message: String? = nil,
    category: String = "default",
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    AppLogger.shared.error(error, message: message, category: category, file: file, function: function, line: line)
}


// MARK: - Convenience Type Specific Logging

/// 记录网络相关的日志信息
/// - Parameters:
///   - message: 日志消息
///   - level: 日志级别，默认为 .info
///   - file: 调用的文件名，默认为当前文件
///   - function: 调用的函数名，默认为当前函数
///   - line: 调用的代码行号，默认为当前行
public func logNetwork(
    _ message: String,
    level: AppLogger.Level = .info,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    switch level {
    case .debug:
        logDebug(message, category: AppLogger.network, file: file, function: function, line: line)
    case .info:
        logInfo(message, category: AppLogger.network, file: file, function: function, line: line)
    case .warning:
        logWarning(message, category: AppLogger.network, file: file, function: function, line: line)
    case .error:
        logError(message, category: AppLogger.network, file: file, function: function, line: line)
    }
}

/// 记录UI相关的日志信息
/// - Parameters:
///   - message: 日志消息
///   - level: 日志级别，默认为 .info
///   - file: 调用的文件名，默认为当前文件
///   - function: 调用的函数名，默认为当前函数
///   - line: 调用的代码行号，默认为当前行
public func logUI(
    _ message: String,
    level: AppLogger.Level = .info,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    switch level {
    case .debug:
        logDebug(message, category: AppLogger.ui, file: file, function: function, line: line)
    case .info:
        logInfo(message, category: AppLogger.ui, file: file, function: function, line: line)
    case .warning:
        logWarning(message, category: AppLogger.ui, file: file, function: function, line: line)
    case .error:
        logError(message, category: AppLogger.ui, file: file, function: function, line: line)
    }
}
