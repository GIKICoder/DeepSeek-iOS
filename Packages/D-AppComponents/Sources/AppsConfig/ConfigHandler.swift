//
//  File.swift
//  AppComponents
//
//  Created by GIKI on 2025/2/21.
//

import Foundation

/// 配置更新触发原因
public enum UpdateReason: CustomStringConvertible {
    case force             // 强制更新
    case timer             // 定时更新
    case login             // 登录触发
    case networkRecovery   // 网络恢复
    case foreground        // 前台启动或切回前台
    case background        // 前台启动或切回前台

    public var description: String {
        switch self {
        case .force:
            return "Force Update"
        case .timer:
            return "Timer Update"
        case .login:
            return "Login Trigger"
        case .networkRecovery:
            return "Network Recovery Trigger"
        case .foreground:
            return "Foreground Trigger"
        case .background:
            return "background Trigger"
        }
    }
}

/// 配置处理器协议，负责实际的配置更新逻辑
public protocol ConfigHandler {
    associatedtype Configuration
    /// 当前的配置，供外部同步获取
    var currentConfiguration: Configuration? { get }
    
    /// 更新配置的方法，带有更新原因
    func update(reason: UpdateReason) throws
}


import Foundation

/// 组合配置处理器，聚合多个不同类型的 ConfigHandler
public class CompositeConfigHandler: ConfigHandler {
    public typealias Configuration = Void // 无特定统一配置类型
    
    fileprivate var handlers: [AnyConfigHandler] = []
    
    public init() {}
    
    /// 当前的配置，组合所有子处理器的配置
    public var currentConfiguration: Void? {
        return ()
    }
    
    /// 添加一个 ConfigHandler
    public func addHandler<H: ConfigHandler>(_ handler: H) {
        let anyHandler = AnyConfigHandler(handler)
        handlers.append(anyHandler)
    }
    
    /// 移除一个 ConfigHandler
    public func removeHandler<H: ConfigHandler>(_ handler: H) {
        handlers.removeAll { $0.isEqual(to: handler) }
    }
    
    /// 更新所有子处理器，传递更新原因
    public func update(reason: UpdateReason) throws {
        for handler in handlers {
            do {
                try handler.update(reason: reason)
                print("Handler \(handler) 更新成功")
            } catch {
                print("Handler \(handler) 更新失败: \(error)")
            }
        }
    }
}

/// 类型擦除包装器，使得不同具体类型的 ConfigHandler 可存储在同一数组中
fileprivate class AnyConfigHandler: ConfigHandler {
    typealias Configuration = Void
    
    private let _update: (UpdateReason) throws -> Void
    private let identifier: ObjectIdentifier
    
    var currentConfiguration: Void? {
        return ()
    }
    
    init<H: ConfigHandler>(_ handler: H) {
        _update = handler.update(reason:)
        identifier = ObjectIdentifier(handler as AnyObject)
    }
    
    func update(reason: UpdateReason) throws {
        try _update(reason)
    }
    
    func isEqual(to handler: any ConfigHandler) -> Bool {
        return identifier == ObjectIdentifier(handler as AnyObject)
    }
}

