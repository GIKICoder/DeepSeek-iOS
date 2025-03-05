//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/26.
//

import Foundation
import AppFoundation

// 1. 定义Event结构
public struct MessageEvent {
    /// 事件标识
    public let name: EventName
    /// 消息所在的section
    public let section: ChatSection?
    public let layout: ChatMessageLayout?
    /// 消息在列表中的位置
    public let index: Int?
    /// 事件的回调闭包，使用泛型使回调更灵活
    public let completion: EventCompletion?
    /// 额外数据字典
    public let payload: Payload?
    
    // 事件类型定义
    public struct EventName: Equatable {
        public let value: String
        
        private init(_ value: String) {
            self.value = value
        }
        
        // 预定义的事件类型
        public static let tap = EventName("tap")
        public static let longPress = EventName("longPress")
        public static let select = EventName("select")
        public static let delete = EventName("delete")
        public static let copy = EventName("copy")
        public static let like = EventName("like")
        public static let dislike = EventName("dislike")
        public static let regen = EventName("regen")
        public static let stopGenerate = EventName("stopGenerate")
        

        // 创建自定义事件
        public static func custom(_ name: String) -> EventName {
            return EventName(name)
        }
        
        // 判断相等
        public static func ==(lhs: EventName, rhs: EventName) -> Bool {
            return lhs.value == rhs.value
        }
    }
    
    
    // 定义回调类型
    public typealias EventCompletion = (EventResult) -> Void
    
    // 事件结果类型
    public struct EventResult {
        public let success: Bool
        public let data: Any?
        public let error: Error?
        
        public static func success(_ data: Any? = nil) -> EventResult {
            return EventResult(success: true, data: data, error: nil)
        }
        
        public static func failure(_ error: Error) -> EventResult {
            return EventResult(success: false, data: nil, error: error)
        }
    }
    
    // 额外数据载荷类型
    public struct Payload {
        private var storage: [String: Any]
        
        public init(_ dictionary: [String: Any] = [:]) {
            self.storage = dictionary
        }
        
        public subscript<T>(key: String) -> T? {
            return storage[key] as? T
        }
        
        public mutating func set<T>(_ value: T, for key: String) {
            storage[key] = value
        }
    }
    
    // 构造函数
    public init(
        name: EventName,
        section: ChatSection? = nil,
        layout: ChatMessageLayout? = nil,
        index: Int? = nil,
        completion: EventCompletion? = nil,
        payload: Payload? = nil
    ) {
        self.name = name
        self.section = section
        self.layout = layout
        self.index = index
        self.completion = completion
        self.payload = payload
    }
}

// 1. 定义事件处理的结果类型
public enum HandlerResult {
    case handled    // 事件已处理
    case unhandled  // 事件未处理
}

// 2. 定义事件分发的模式
public enum DispatchMode {
    case interrupt // 中断模式：第一个处理成功后停止
    case broadcast // 广播模式：所有handler都有机会处理
}

// 2. 更新Handler协议
public protocol MessageHandler: AnyObject {
    func handle(_ event: MessageEvent) -> HandlerResult
}

public class MessageHandlerChain {
    private var handlers: [MessageHandler] = []
    
    public init() {}
    
    @discardableResult
    public func append(_ handler: MessageHandler) -> MessageHandlerChain {
        // 检查是否已存在相同类型的handler
        let handlerType = type(of: handler)
        if !handlers.contains(where: { type(of: $0) == handlerType }) {
            handlers.append(handler)
        }
        return self
    }
    
    // 替换已存在的handler
    @discardableResult
    public func replace(_ handler: MessageHandler) -> MessageHandlerChain {
        let handlerType = type(of: handler)
        if let index = handlers.firstIndex(where: { type(of: $0) == handlerType }) {
            handlers[index] = handler
        } else {
            handlers.append(handler)
        }
        return self
    }
    
    // 检查某个类型的handler是否存在
    public func contains<T: MessageHandler>(_ handlerType: T.Type) -> Bool {
        return handlers.contains(where: { type(of: $0) == handlerType })
    }
    
    // 获取特定类型的handler
    public func handler<T: MessageHandler>(of type: T.Type) -> T? {
        return handlers.first(where: { $0 is T }) as? T
    }
    
    public func remove(_ handler: MessageHandler) {
        handlers.removeAll { $0 === handler }
    }
    
    // 根据类型移除handler
    public func remove<T: MessageHandler>(_ handlerType: T.Type) {
        handlers.removeAll { type(of: $0) == handlerType }
    }
    
    @discardableResult
    public func dispatch(_ event: MessageEvent, mode: DispatchMode = .interrupt) -> Bool {
        var hasHandled = false
        
        for handler in handlers {
            let result = handler.handle(event)
            if result == .handled {
                hasHandled = true
                if mode == .interrupt {
                    break
                }
            }
        }
        
        return hasHandled
    }
}
