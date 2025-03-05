//
//  FeedHandlerChain.swift
//  FeedListWrapper
//
//  Created by GIKI on 2024/8/31.
//

import Foundation

// MARK: - FeedHandlerChain

public enum FeedHandlerChainMode {
    case firstResponder
    case allResponders
}

public protocol FeedHandleable: AnyObject {
    func canHandle(event: FeedEvent) -> Bool
    func handle(event: FeedEvent)
}

// MARK: - WeakFeedHandleable Wrapper
private class WeakFeedHandleable {
    weak var handler: FeedHandleable?
    
    init(handler: FeedHandleable) {
        self.handler = handler
    }
}

public enum FeedEventType: Equatable {
    case itemTapped
    case itemLongPress
    case reloadData(animate: Bool = true)
    case reloadIndex(animate: Bool = true)
    case performUpdates(animate: Bool = true)
    case reloadObjects(animate: Bool = true)
    case loadNewData
    case loadMoreData
    case removeObjects
    case insertObjectsAtIndex
    case custom(String)

    var stringValue: String {
        switch self {
        case .itemTapped: return "item_tapped"
        case .itemLongPress: return "item_long_press"
        case let .reloadData(animate): return "reload_all_\(animate ? "animated" : "not_animated")"
        case let .reloadIndex(animate): return "reload_index_\(animate ? "animated" : "not_animated")"
        case let .performUpdates(animate): return "reload_all_if_need_\(animate ? "animated" : "not_animated")"
        case let .reloadObjects(animate): return "reload_objects_\(animate ? "animated" : "not_animated")"
        case .loadNewData: return "load_new_data"
        case .loadMoreData: return "load_more_data"
        case .removeObjects: return "remove_objects"
        case .insertObjectsAtIndex: return "insert_objects_at_index"
        case let .custom(value): return value
        }
    }

    init(stringValue: String) {
        switch stringValue {
        case "item_tapped": self = .itemTapped
        case "item_long_press": self = .itemLongPress
        case "reload_all_animated": self = .reloadData(animate: true)
        case "reload_all_not_animated": self = .reloadData(animate: false)
        case "reload_index_animated": self = .reloadIndex(animate: true)
        case "reload_index_not_animated": self = .reloadIndex(animate: false)
        case "reload_all_if_need_animated": self = .performUpdates(animate: true)
        case "reload_all_if_need_not_animated": self = .performUpdates(animate: false)
        case "reload_objects_animated": self = .reloadObjects(animate: true)
        case "reload_objects_not_animated": self = .reloadObjects(animate: false)
        case "load_new_data": self = .loadNewData
        case "load_more_data": self = .loadMoreData
        case "remove_objects": self = .removeObjects
        case "insert_objects_at_index": self = .insertObjectsAtIndex
        default: self = .custom(stringValue)
        }
    }
}

public typealias FeedEventCallback = (Result<Any, any Error>) -> Void

public struct FeedEvent {
    public let type: FeedEventType
    public let sectionBean: FeedListSectionBean?
    public let index: Int
    public let extraData: Any?
    public let callback: FeedEventCallback?

    public init(type: FeedEventType, sectionBean: FeedListSectionBean? = nil, index: Int = 0, extraData: Any? = nil, callback: FeedEventCallback? = nil) {
        self.type = type
        self.sectionBean = sectionBean
        self.index = index
        self.extraData = extraData
        self.callback = callback
    }

    public init(type: FeedEventType) {
        self.init(type: type, sectionBean: nil, index: 0, extraData: nil, callback: nil)
    }

    public init(type: FeedEventType, sectionBean: FeedListSectionBean) {
        self.init(type: type, sectionBean: sectionBean, index: 0, extraData: nil, callback: nil)
    }

    public init(type: FeedEventType, sectionBean: FeedListSectionBean, index: Int) {
        self.init(type: type, sectionBean: sectionBean, index: index, extraData: nil, callback: nil)
    }
}



// MARK: - FeedHandlerChain Class
public class FeedHandlerChain {
    // 强引用的处理器数组
    private var strongHandlers: [FeedHandleable] = []
    
    // 弱引用的处理器数组
    private var weakHandlers: [WeakFeedHandleable] = []
    
    public init() {}
    
    /// 添加一个强引用的处理器
    public func addHandler(_ handler: any FeedHandleable) {
        strongHandlers.append(handler)
    }
    
    /// 添加一个弱引用的处理器
    public func addWeakHandler(_ handler: any FeedHandleable) {
        weakHandlers.append(WeakFeedHandleable(handler: handler))
    }
    
    /// 移除指定的处理器（强引用和弱引用）
    public func removeHandler(_ handler: any FeedHandleable) {
        // 移除强引用的处理器
        strongHandlers.removeAll { $0 as AnyObject === handler as AnyObject }
        
        // 移除弱引用的处理器
        weakHandlers.removeAll { $0.handler as AnyObject === handler as AnyObject }
    }
    
    /// 处理事件
    public func handle(_ event: FeedEvent, mode: FeedHandlerChainMode = .firstResponder) {
        switch mode {
        case .firstResponder:
            // 再处理弱引用的处理器
            for weakHandler in weakHandlers.reversed() {
                if let handler = weakHandler.handler, handler.canHandle(event: event) {
                    handler.handle(event: event)
                    return
                }
            }
            
            // 先处理强引用的处理器
            for handler in strongHandlers.reversed() {
                if handler.canHandle(event: event) {
                    handler.handle(event: event)
                    return
                }
            }
        
        case .allResponders:
            // 处理强引用的处理器
            for handler in strongHandlers.reversed() {
                if handler.canHandle(event: event) {
                    handler.handle(event: event)
                }
            }
            
            // 处理弱引用的处理器，并清理已释放的处理器
            weakHandlers = weakHandlers.filter { weakHandler in
                if let handler = weakHandler.handler {
                    if handler.canHandle(event: event) {
                        handler.handle(event: event)
                    }
                    return true
                }
                return false
            }
        }
    }
    
    /// 仅处理第一个可以响应的处理器
    public func handleFirst(_ event: FeedEvent) {
        handle(event, mode: .firstResponder)
    }
    
    /// 处理所有可以响应的处理器
    public func handleAll(_ event: FeedEvent) {
        handle(event, mode: .allResponders)
    }
}
