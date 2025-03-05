//
//  GEventSource.swift
//
//
//  Created by GIKI on 2024/12/29.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/**
 // 创建配置和事件源
 let url = URL(string: "https://example.com/sse")!
 var configuration = EventSource.Configuration(url: url)
 configuration.shouldRetryOnDisconnect = false // 设置为不自动重连
 let eventHandler = MyEventHandler()
 
 let eventSource = EventSource(configuration: configuration, eventHandler: eventHandler)
 eventSource.connect()
 
 class MyEventHandler: EventSource.EventHandler {
 func onOpen(eventSource: EventSource) {
 print("连接已打开")
 }
 
 func onMessage(eventSource: EventSource, event: EventSource.MessageEvent) {
 print("接收到消息：\(event.event) - \(event.data)")
 }
 
 func onComment(eventSource: EventSource, comment: String) {
 print("接收到注释：\(comment)")
 }
 
 func onError(eventSource: EventSource, error: Error) {
 print("发生错误：\(error.localizedDescription)")
 }
 
 func onComplete(eventSource: EventSource, error: Error?) {
 if let error = error {
 print("连接已关闭，错误：\(error.localizedDescription)")
 } else {
 print("连接已正常关闭")
 }
 }
 }
 
 */


// MARK: - GEventSource

/// `GEventSource` 用于处理 Server-Sent Events（SSE）的客户端。
public class GEventSource: NSObject {
    // MARK: Types
    
    /// 配置类，用于初始化 `GEventSource`。
    public struct Configuration {
        /// 请求的 URL。
        public let url: URL
        /// 请求的 HTTP 方法，默认是 "POST"。
        public var method: String = "POST"
        /// 请求的 HTTP 头。
        public var headers: [String: String] = [:]
        /// 请求的 HTTP Body。
        public var body: Data?
        /// 初始的 `Last-Event-ID`，用于断点续传。
        public var lastEventId: String?
        /// 是否在连接断开后自动重连，默认为 `true`。
        public var shouldRetryOnDisconnect: Bool = false
        /// 重连时间间隔（秒），用于处理连接中断后的重试机制。
        public var reconnectInterval: TimeInterval = 3.0
        /// 超时时间（秒），用于处理连接超时。
        public var timeoutInterval: TimeInterval = 60.0
        
        
        /// 初始化配置。
        public init(url: URL) {
            self.url = url
        }
    }
    
    /// SSE 消息事件。
    public struct MessageEvent {
        /// 事件类型。
        public let event: String
        /// 数据。
        public var data: String
        /// 最后的事件 ID。
        public let lastEventId: String?
    }
    
    /// 事件回调协议。
    public protocol EventHandler: AnyObject {
        /// 当连接打开时调用。
        func onOpen(eventSource: GEventSource)
        /// 当接收到消息时调用。
        func onMessage(eventSource: GEventSource, event: MessageEvent)
        /// 当接收到注释时调用。
        func onComment(eventSource: GEventSource, comment: String)
        /// 当发生错误时调用。
        func onError(eventSource: GEventSource, error: Error)
        /// 当连接关闭时调用。
        func onComplete(eventSource: GEventSource, error: Error?)
    }
    
    // MARK: Properties
    
    private let configuration: Configuration
    private weak var eventHandler: EventHandler?
    private var task: URLSessionDataTask?
    private var session: URLSession!
    private var isConnecting: Bool = false
    private var isClosed: Bool = false
    private var lastEventId: String?
    private var dataBuffer = Data()
    private var utf8LineParser = UTF8LineParser()
    private var eventParser = EventParser()
    private var queue = DispatchQueue(label: "com.eventsource.queue")
    
    // MARK: Initialization
    
    /// 初始化 `GEventSource`。
    /// - Parameters:
    ///   - configuration: 配置信息。
    ///   - eventHandler: 事件处理器。
    public init(configuration: Configuration, eventHandler: EventHandler) {
        self.configuration = configuration
        self.eventHandler = eventHandler
        self.lastEventId = configuration.lastEventId
        
        super.init()
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.timeoutInterval
        sessionConfig.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        self.session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
    }
    
    deinit {
        close()
    }
    
    // MARK: Public Methods
    
    /// 开始连接。
    public func connect() {
        guard !isConnecting else { return }
        isConnecting = true
        isClosed = false
        
        var request = URLRequest(url: configuration.url)
        request.httpMethod = configuration.method
        request.allHTTPHeaderFields = configuration.headers
        request.httpBody = configuration.body
        
        // 设置 SSE 特有的 Header
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        
        if let lastEventId = lastEventId {
            request.setValue(lastEventId, forHTTPHeaderField: "Last-Event-ID")
        }
        
        task = session.dataTask(with: request)
        task?.resume()
    }
    
    /// 关闭连接。
    public func close() {
        isClosed = true
        task?.cancel()
        session.invalidateAndCancel()
    }
}

// MARK: - URLSessionDataDelegate

extension GEventSource: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard !isClosed else { return }
        
        queue.async {
            self.dataBuffer.append(data)
            self.parseData()
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        isConnecting = false
        if let error = error as NSError?, error.code != NSURLErrorCancelled {
            // 连接由于错误而断开（非用户取消）
            eventHandler?.onError(eventSource: self, error: error)
            if configuration.shouldRetryOnDisconnect {
                reconnect()
            } else {
                // 不重连，通知连接已完成，并传递错误
                eventHandler?.onComplete(eventSource: self, error: error)
            }
        } else {
            // 连接被正常关闭
            eventHandler?.onComplete(eventSource: self, error: nil)
            close()
        }
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        isConnecting = false
        if let error = error {
            eventHandler?.onError(eventSource: self, error: error)
        }
        eventHandler?.onComplete(eventSource: self, error: error)
    }
    
    // MARK: Private Methods
    private func parseData() {
        let lines = utf8LineParser.append(dataBuffer)
        dataBuffer.removeAll()
        
        for line in lines {
            eventParser.parse(line: line)
        }
        
        // 检查是否有完整的事件需要触发
        if let events = eventParser.retrieveEvents() {
            for event in events {
                switch event {
                case .event(let messageEvent):
                    self.lastEventId = messageEvent.lastEventId
                    self.eventHandler?.onMessage(eventSource: self, event: messageEvent)
                case .comment(let comment):
                    self.eventHandler?.onComment(eventSource: self, comment: comment)
                }
            }
        }
    }
    
    
    private func reconnect() {
        guard !isClosed else { return }
        // 延迟重连
        DispatchQueue.global().asyncAfter(deadline: .now() + configuration.reconnectInterval) { [weak self] in
            self?.connect()
        }
    }
}

// MARK: - UTF8LineParser

/// 负责将接收到的 Data 数据解析成完整的 UTF-8 字符串，并按行分割。
class UTF8LineParser {
    private var buffer = Data()
    private var decodedString = ""
    private var currentIndex = String.Index(utf16Offset: 0, in: "")
    
    /// 添加新数据并返回完整的行数组。
    func append(_ data: Data) -> [String] {
        // 将新数据添加到缓冲区
        buffer.append(data)
        var lines = [String]()
        
        // 尝试将缓冲区解码为字符串
        var validPrefixLength = 0
        var tempString = ""
        var foundValidUTF8 = false
        
        // 使用尽可能多的有效 UTF-8 字符解码
        while validPrefixLength <= buffer.count {
            let end = buffer.count - validPrefixLength
            // 确保范围有效
            if end < 0 {
                break
            }
            
            let subData: Data
            if end == 0 {
                subData = Data()
            } else {
                subData = buffer.prefix(end)
            }
            
            if let string = String(data: subData, encoding: .utf8) {
                tempString = string
                foundValidUTF8 = true
                break
            }
            validPrefixLength += 1
        }
        
        // 更新缓冲区，只保留未解码的数据
        if foundValidUTF8 {
            let removeLength = buffer.count - validPrefixLength
            if removeLength > 0 {
                buffer.removeFirst(removeLength)
            }
        } else {
            // 如果没有找到有效的 UTF-8 字符，清空缓冲区
            buffer.removeAll()
        }
        
        // 将解码的字符串添加到已解码的字符串中
        decodedString.append(tempString)
        
        // 按行分割已解码的字符串
        let components = decodedString.components(separatedBy: "\n")
        // 保留最后一个不完整的行
        decodedString = components.last ?? ""
        // 返回完整的行
        lines = Array(components.dropLast())
        
        return lines
    }
    
    
    /// 重置解析器状态，一般在连接关闭时调用。
    func reset() {
        buffer.removeAll()
        decodedString = ""
        currentIndex = String.Index(utf16Offset: 0, in: "")
    }
}


// MARK: - EventParser

// 负责解析 SSE 事件的数据和字段。
// EventParser
class EventParser {
    enum EventType {
        case event(GEventSource.MessageEvent)
        case comment(String)
    }
    
    private var events = [EventType]()
    private var currentEvent = GEventSource.MessageEvent(event: "message", data: "", lastEventId: nil)
    
    func parse(line: String) {
        if line.isEmpty {
            // 空行，表示事件结束，准备触发事件
            if !currentEvent.data.isEmpty {
                // 移除最后一个换行符
                if currentEvent.data.hasSuffix("\n") {
                    currentEvent.data.removeLast()
                }
                let eventCopy = currentEvent
                events.append(.event(eventCopy))
                currentEvent = GEventSource.MessageEvent(event: "message", data: "", lastEventId: currentEvent.lastEventId)
            }
        } else if line.hasPrefix(":") {
            // 注释行
            let comment = String(line.dropFirst())
            events.append(.comment(comment))
        } else {
            // 解析字段和值
            let components = line.components(separatedBy: ":")
            let field = components[0]
            let value = components.dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
            
            switch field {
            case "event":
                currentEvent = GEventSource.MessageEvent(event: value, data: currentEvent.data, lastEventId: currentEvent.lastEventId)
            case "data":
                currentEvent.data.append(value)
                currentEvent.data.append("\n")
            case "id":
                currentEvent = GEventSource.MessageEvent(event: currentEvent.event, data: currentEvent.data, lastEventId: value)
            case "retry":
                // 可在此处理重新连接时间
                break
            default:
                break
            }
        }
    }
    
    /// 返回所有已解析的事件，并清空事件列表。
    func retrieveEvents() -> [EventType]? {
        guard !events.isEmpty else { return nil }
        let result = events
        events.removeAll()
        return result
    }
    
    /// 重置解析器状态，一般在连接关闭时调用。
    func reset() {
        events.removeAll()
        currentEvent = GEventSource.MessageEvent(event: "message", data: "", lastEventId: nil)
    }
}

