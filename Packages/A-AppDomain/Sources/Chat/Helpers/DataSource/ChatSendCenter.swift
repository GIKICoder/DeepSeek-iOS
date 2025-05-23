//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/16.
//

import Foundation
import AppInfra
import AppFoundation
import ReerCodable
import AppServices

public struct SendMessageParam {
    var channelId: String
    var content: String
    var model: String
    var isNewChat: Bool
    var upload: Int?
    var imageUrls: [String]?
    var promptTemplateId: String?
    var reMessageId: String?
    var messageId: String?
    var searchSwitch: Bool
    
    public func toData() -> Data? {
        return try? JSONSerialization.data(withJSONObject: toDictionary(), options: [])
    }
    
    public func toJson() -> String? {
        guard let data = toData() else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    fileprivate func toDictionary() -> [String: Any] {
        var params: [String: Any] = [
            "model": "deepseek-chat",
            "stream" : true
        ]
        var messages: [[String: Any]] = []
        messages = [
                  [ "role" : "system",
                    "content" : "You are a helpful assistant."],
                  ["role" : "user",
                    "content": content]
                ]
        params["messages"] = messages
        return params
    }
    
}

@Codable
public struct StreamChunk: Codable {
    // This struct would need properties to match the JSON structure:
    var id: String = ""
    var object: String = ""
    var created: Int = 0
    var model: String = ""
    var system_fingerprint: String = ""
    var choices: [Choice] = []
}

public extension StreamChunk {
    
    var first: Bool {
        return choices.first?.delta.role == "assistant"
    }
    
    var last: Bool {
        return choices.last?.finish_reason == "stop"
    }
    
    var content:String {
        return choices.first?.delta.content ?? ""
    }
}

@Codable
public struct Choice: Codable {
    var index: Int = 0
    var delta: Delta = Delta(content: "")
    var logprobs: String?
    var finish_reason: String?
}

@Codable
public struct Delta: Codable {
    var content: String = ""
    var role: String = ""
}

// MARK: - ChatSendCenter

public actor ChatSendCenter {
    public static let shared = ChatSendCenter()
    
    private init() {}
    
    // Active sending tasks 存储 (GEventSource, SendEventHandler) 元组
    private var activeSendTasks: [String: (source: GEventSource, handler: SendEventHandler)] = [:]
    
    // Send message via GEventSource using AsyncThrowingStream
    public func sendMessage(_ message: SendMessageParam) -> AsyncThrowingStream<[StreamChunk], Error> {
        let channelId = message.channelId
        
        let baseUrl = AppEnvironment.urlWithPath("/v1/chat/completions")
        guard let sendURL = URL(string: baseUrl) else {
            return AsyncThrowingStream { continuation in
                continuation.finish(throwing: SendError.invalidURL)
            }
        }
        
        var configuration = GEventSource.Configuration(url: sendURL)
        configuration.shouldRetryOnDisconnect = false
        configuration.headers = NetworkClient.shared.getHeaders()
        configuration.body = message.toData()
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    // 检查是否已经有发送任务在进行
                    try await self.checkAndAddSendTask(channelId: channelId)
                    
                    // 创建 SendEventHandler，并在接收消息时向流中发送数据
                    let eventHandler = SendEventHandler { result in
                        Task {
                            switch result {
                            case .success(let chatMessages) where !chatMessages.isEmpty:
                                continuation.yield(chatMessages)
                                if let lastMessage = chatMessages.last,lastMessage.last{
                                    continuation.finish()
                                }
                            case .success:
                                // 当收到 success 但没有消息时，结束流
                                continuation.finish()
                            case .failure(let error):
                                continuation.finish(throwing: error)
                            }
                        }
                    }
                    
                    // 初始化 GEventSource
                    let eventSource = GEventSource(configuration: configuration, eventHandler: eventHandler)
                    
                    // 存储 activeSendTasks 以保持强引用
                    await self.addSendTask(channelId: channelId, source: eventSource, handler: eventHandler)
                    
                    // 连接 SSE
                    eventSource.connect()
                    
                    // 处理流终止时的清理
                    continuation.onTermination = { _ in
                        Task {
                            await self.removeSendTask(for: channelId)
                        }
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    
    // 添加发送任务
    private func addSendTask(channelId: String, source: GEventSource, handler: SendEventHandler) async {
        activeSendTasks[channelId] = (source: source, handler: handler)
    }
    
    // 检查并添加发送任务
    private func checkAndAddSendTask(channelId: String) async throws {
        if activeSendTasks[channelId] != nil {
            throw SendError.alreadySending
        }
        // 其他可能的检查逻辑可以添加在这里
    }
    
    // 移除发送任务
    private func removeSendTask(for channelId: String) async {
        if let task = activeSendTasks[channelId] {
            task.source.close()
            activeSendTasks.removeValue(forKey: channelId)
            logUI("移除SSE发送任务")
        }
        
        // 为了消除 'No async operations occur within await expression' 警告，添加一个占位的 async 调用
        await Task.yield()
    }
    
    // 停止发送任务
    public func stopSendTask(channelId: String) {
        Task {
            await self.removeSendTask(for: channelId)
        }
    }
    
    // 发送错误枚举
    public enum SendError: Error, LocalizedError {
        case alreadySending
        case invalidURL
        case sendFailed
        case invalidMessageFormat
        
        public var errorDescription: String? {
            switch self {
            case .alreadySending:
                return "该频道当前已有一个正在发送的任务。"
            case .invalidURL:
                return "无效的URL。"
            case .sendFailed:
                return "发送消息失败。"
            case .invalidMessageFormat:
                return "消息格式无效。"
            }
        }
    }
    
    // MARK: - SendEventHandler
    
    /// `SendEventHandler` 处理发送消息的回调。
    class SendEventHandler: GEventSource.EventHandler {
        let onReceive: (Result<[StreamChunk], Error>) -> Void
        
        init(onReceive: @escaping (Result<[StreamChunk], Error>) -> Void) {
            self.onReceive = onReceive
        }
        
        func onOpen(eventSource: GEventSource) {
            logNetwork("发送任务连接已打开。")
        }
        
        func onMessage(eventSource: GEventSource, event: GEventSource.MessageEvent) {
            logNetwork("接收到消息：\(event.event) - \(event.data)")
            // 处理服务器的消息
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let data = Data(event.data.utf8)
                let chatMessage = try decoder.decode(StreamChunk.self, from: data)
                onReceive(.success([chatMessage]))
                logNetwork("接收到消息并回调：\(chatMessage)")
            } catch {
                onReceive(.failure(error))
                logNetwork("接收到消息decode失败：\(error)")
            }
        }
        
        func onComment(eventSource: GEventSource, comment: String) {
            logNetwork("接收到注释：\(comment)")
        }
        
        func onError(eventSource: GEventSource, error: Error) {
            logNetwork("接收到Error：\(error)")
            onReceive(.failure(error))
        }
        
        func onComplete(eventSource: GEventSource, error: Error?) {
            
            if let error = error {
                logNetwork("发送任务连接出现错误 \(error)")
                onReceive(.failure(error))
            } else {
                logNetwork("发送任务连接已正常关闭。")
                // 调用结束 使用 continuation.finish()
//                onReceive(.success([]))
            }
        }
    }
}
