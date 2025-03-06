//
//  ChatDataCenter.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/16.
//
import Foundation
import Combine
import ReerCodable
import AppInfra
import AppServices
import AppFoundation
import UIKit


// MARK: - ChatEntrance
public class ChatEntrance {
    public var channel: ChatChannel?
    public var source: String?
    public var model: String = "Standard"
    public var templateId: String?
    public var fileURL: URL?
    public var uploadFileURL: String?
    
    public init(channel: ChatChannel? = nil, source: String? = nil) {
        self.channel = channel
        self.source = source
    }
}


// MARK: - ChatSendState
public enum ChatSendState {
    case normal
    case generating
    case finished
    case error(Error)
    
    public var isGenerating: Bool {
        if case .generating = self {
            return true
        }
        return false
    }
    public var isSuccess: Bool {
        if case .normal = self {
            return true
        } else if case .finished = self {
            return true
        }
        return false
    }
    
}

// MARK: - ChatSectionsState
public struct ChatSectionsState {
    let state: ChatDataState
    var sections: [ChatSection]
}


// MARK: - ChatDataState
public enum ChatDataState {
    case initial
    case loading
    case loaded(initial:Bool)
    case updated(sections: [ChatSection])
    case empty
    case error(Error)
}

// MARK: - ChatDataError
public enum ChatDataError: Error {
    case invalidChannelId
    case networkError(Error)
    case emptyResponse
}

// MARK: - ChatDataCenter
public class ChatDataCenter {
    // MARK: - Properties
    public let entrance: ChatEntrance
    private let chatAPI: NetworkProvider<ChatApi> = NetworkProvider<ChatApi>()
    
    public private(set) var messagesPublisher = CurrentValueSubject<[ChatMessage], Never>([])
    
    // Modified sectionsPublisher to carry state information
    public private(set) var sectionsPublisher = CurrentValueSubject<ChatSectionsState, Never>(ChatSectionsState(state: .initial, sections: []))
    
    // New publisher to track sendMessageWith function's state
    public private(set) var sendMessageStatePublisher = CurrentValueSubject<ChatSendState, Never>(.normal)
    
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    private var isLoading = false
    public private(set) var hasMoreData = true
    
    private var currentTask: Task<Void, Never>?
    private var isCancelled = false
    
    // MARK: - Initialization
    public init(entrance: ChatEntrance) {
        self.entrance = entrance
        // Initialize with the current sections state
        initializeData()
    }
    
    // MARK: - Public API
    
    public var channel: ChatChannel? {
        get { entrance.channel }
        set { entrance.channel = newValue }
    }
    
    // MARK: - Public Accessors
    /// 获取当前所有消息
    public var messages: [ChatMessage] {
        messagesPublisher.value
    }
    
    /// 获取当前所有分区
    public var sections: [ChatSection] {
        sectionsPublisher.value.sections
    }
    
    /// 当前更新的section
    public var updateSections: [ChatSection] {
        if case .updated(let sections) = sectionsPublisher.value.state {
            return sections
        }
        return []
    }
    
    /// 获取消息流
    public var messagesStream: AnyPublisher<[ChatMessage], Never> {
        messagesPublisher.eraseToAnyPublisher()
    }
    
    /// 获取分区流
    public var sectionsStream: AnyPublisher<ChatSectionsState, Never> {
        sectionsPublisher.eraseToAnyPublisher()
    }
    
    public var currentSendState: ChatSendState {
        sendMessageStatePublisher.value
    }
    
    /// 获取发送状态数据流
    public var sendStateStream: AnyPublisher<ChatSendState, Never> {
        sendMessageStatePublisher.eraseToAnyPublisher()
    }
    
    /// Retrieves the ChatMessage immediately before the message with the specified messageID.
    /// - Parameter messageID: The unique identifier of the current message.
    /// - Returns: The previous ChatMessage if it exists, otherwise nil.
    public func getPreviousMessage(of messageID: String) -> ChatMessage? {
        let messages = messagesPublisher.value
        guard let currentIndex = messages.firstIndex(where: { $0.messageId == messageID }) else {
            print("ChatMessage with ID \(messageID) not found.")
            return nil
        }
        
        // 检查当前消息是否有前一个消息
        if currentIndex > 0 {
            return messages[currentIndex - 1]
        } else {
            // 当前消息就是第一条消息，没有上一个消息
            return nil
        }
    }
    
    /// Updates an existing ChatMessage by messageID.
    public func updateChatMessage(by messageID: String, with updatedMessage: ChatMessage) {
        var currentMessages = messagesPublisher.value
        if let index = currentMessages.firstIndex(where: { $0.messageId == messageID }) {
            currentMessages[index] = updatedMessage
            messagesPublisher.send(currentMessages)
        } else {
            print("ChatMessage with ID \(messageID) not found.")
        }
    }
    
    /// Deletes a ChatMessage by messageID.
    @discardableResult
    public func deleteChatMessage(by messageID: String) -> Int {
        var currentMessages = messagesPublisher.value
        if let index = currentMessages.firstIndex(where: { $0.messageId == messageID }) {
            currentMessages.remove(at: index)
            messagesPublisher.send(currentMessages)
            return index
        } else {
            print("ChatMessage with ID \(messageID) not found.")
            return -1
        }
    }
    
    /// Updates the ChatSection containing the ChatMessage with the specified messageID.
    public func updateChatSection(by messageID: String, with updatedSection: ChatSection) {
        var currentState = sectionsPublisher.value
        if let index = currentState.sections.firstIndex(where: { section in
            section.message.messageId == messageID
        }) {
            currentState.sections[index] = updatedSection
            sectionsPublisher.send(currentState)
        } else {
            print("ChatSection containing ChatMessage with ID \(messageID) not found.")
        }
    }
    
    /// Deletes the ChatSection containing the ChatMessage with the specified messageID.
    @discardableResult
    public func deleteChatSection(by messageID: String) -> Int  {
        var currentState = sectionsPublisher.value
        if let index = currentState.sections.firstIndex(where: { section in
            section.message.messageId == messageID
        }) {
            currentState.sections.remove(at: index)
            sectionsPublisher.send(currentState)
            return index
        } else {
            print("ChatSection containing ChatMessage with ID \(messageID) not found.")
            return -1
        }
    }
    
}

// MARK: - ChatDataCenter + Fetch

extension ChatDataCenter {
    
    // MARK: - Public Fetch
    
    @discardableResult
    public func initializeData() -> AnyPublisher<ChatSectionsState, Never> {
        guard !isLoading else {
            return sectionsPublisher.eraseToAnyPublisher()
        }
        
        return loadMessages(isInitial: true)
    }
    
    @discardableResult
    public func loadMoreMessages() -> AnyPublisher<ChatSectionsState, Never> {
        guard !isLoading && hasMoreData else {
            return sectionsPublisher.eraseToAnyPublisher()
        }
        
        return loadMessages(isInitial: false)
    }
    
    // MARK: - Public Message Manipulation
    
    /// 追加消息到消息列表
    /// - Parameter newMessages: <#newMessages description#>
    public func prependMessages(_ newMessages: [ChatMessage]) {
        guard !newMessages.isEmpty else { return }
        
        // 获取当前的消息列表
        var currentMessages = messagesPublisher.value
        
        // 获取现有消息的所有 messageId 以便去重
        let existingMessageIds = Set(currentMessages.map { $0.messageId })
        
        // 过滤掉已经存在的消息
        let uniqueNewMessages = newMessages.filter { !existingMessageIds.contains($0.messageId) }
        
        // 如果过滤后没有新消息，则返回
        guard !uniqueNewMessages.isEmpty else { return }
        
        // 将新消息插入到当前消息列表的最前面
        currentMessages.insert(contentsOf: uniqueNewMessages, at: 0)
        messagesPublisher.send(currentMessages)
        
        // 获取当前的分区列表
        var currentSections = sectionsPublisher.value.sections
        
        // 遍历新的唯一消息，创建或更新分区
        var newSections: [ChatSection] = []
        for message in uniqueNewMessages {
            // 创建新的分区并插入到分区列表的最前面
            let newSection = ChatAssembly.assembleSection(message, dataCenter: self)
            newSections.append(newSection)
        }
        currentSections.insert(contentsOf: newSections, at: 0)
        // 更新分区状态并发送
        let newState = ChatSectionsState(state: .loaded(initial: false), sections: currentSections)
        sectionsPublisher.send(newState)
    }
    
    
    /// 手动追加消息并同步更新分区
    public func appendMessages(_ newMessages: [ChatMessage],isInitial: Bool) {
        guard !newMessages.isEmpty else { return }
        
        var currentMessages = messagesPublisher.value
        currentMessages.append(contentsOf: newMessages)
        messagesPublisher.send(currentMessages)
        
        // 增量更新分区
        incrementallyUpdateSections(with: newMessages, isInitial: isInitial)
    }
    
    // MARK: - Private Methods
    private func loadMessages(isInitial: Bool) -> AnyPublisher<ChatSectionsState, Never> {
        guard let channelId = channel?.channelId, !channelId.isEmpty else {
            let emptyState = ChatSectionsState(state: .empty, sections: sectionsPublisher.value.sections)
            sectionsPublisher.send(emptyState)
            return sectionsPublisher.eraseToAnyPublisher()
        }
        
        isLoading = true
        let loadingState = ChatSectionsState(state: .loading, sections: sectionsPublisher.value.sections)
        sectionsPublisher.send(loadingState)
        
        let beforeMessage = isInitial ? nil : messagesPublisher.value.first
        let params = MessagesParams(
            channelId: channelId,
            id: Int64(beforeMessage?.message_id ?? -1),
            beforeMessageId: beforeMessage?.messageId,
            pageSize: 10
        )
        
        return fetchMessages(with: params,isInitial: isInitial)
    }
    
    private func fetchMessages(with params: MessagesParams,isInitial: Bool) -> AnyPublisher<ChatSectionsState, Never> {
        Future { [weak self] promise in
            
            if let channelHistory = self?.loadJSON(filename: params.channelId) as ChatChannelWrap? {
                self?.appendMessages(channelHistory.chat_messages, isInitial: isInitial)
                let loadedState = ChatSectionsState(state: .loaded(initial: isInitial),
                                                  sections: self?.sectionsPublisher.value.sections ?? [])
                promise(.success(loadedState))
            }
            /*
            self?.chatAPI.request(.messages(params), type: ChatChannelWrap.self) { result in
                self?.isLoading = false
                switch result {
                case .success(let channelWrap):
                    let channel = channelWrap.channel
                    
                    self?.channel = channel
                    let newMessages = self?.processMessages(channelWrap.message, channel: channel) ?? []
                    self?.hasMoreData = !newMessages.isEmpty
                    if isInitial {
                        self?.appendMessages(newMessages,isInitial: isInitial)
                    } else {
                        self?.prependMessages(newMessages)
                    }
                    
                    let loadedState = ChatSectionsState(state: .loaded(initial: isInitial), sections: self?.sectionsPublisher.value.sections ?? [])
                    promise(.success(loadedState))
                    
                case .failure(let error):
                
                    let errorState = ChatSectionsState(state: .error(ChatDataError.networkError(error)), sections: self?.sectionsPublisher.value.sections ?? [])
                    promise(.success(errorState))
                }
            }
             */
        }
        .eraseToAnyPublisher()
    }
    
    private func processMessages(_ messages: [ChatMessage], channel: ChatChannel) -> [ChatMessage] {
        return messages
    }

    
    /// 增量更新分区
    /// - Parameters:
    ///   - messages: 需要更新的消息
    ///   - isInitial: 是否是初始化数据加载
    private func incrementallyUpdateSections(with messages: [ChatMessage], isInitial:Bool = false) {
        var currentSections = sectionsPublisher.value.sections
        
        for message in messages {
            // 查找是否有对应的分区
            if let lastSectionIndex = currentSections.lastIndex(where: { $0.message.messageId == message.messageId }) {
                let newSection = ChatAssembly.assembleSection(message,dataCenter: self)
                currentSections[lastSectionIndex] = newSection
            } else {
                // 创建新的分区
                let newSection = ChatAssembly.assembleSection(message,dataCenter: self)
                currentSections.append(newSection)
            }
        }
        
        let newState = ChatSectionsState(state: .loaded(initial: isInitial), sections: currentSections)
        sectionsPublisher.send(newState)
    }
    
   
}

// MARK: - ChatData + Send

extension ChatDataCenter {
    
    public func stopMessageGenerate() {
        
       
        guard currentSendState.isGenerating else {
            return
        }
        guard let channelId = channel?.channelId else {
            return
        }
        Task{
            await ChatSendCenter.shared.stopSendTask(channelId: channelId)
            isCancelled = true
            currentTask?.cancel()
            currentTask = nil
            sendMessageStatePublisher.send(.finished)
            if let section = updateSections.last {
                let saveApi = ChatApi.saveMessage(messageId: section.message.messageId, content: section.message.content)
                try await chatAPI.requestRawAsync(saveApi)
            }
        }
    }
    
    /// 发送文本消息
    /// - Parameter text: 要发送的文本内容
    public func sendMessageWith(text: String?, imageUrl: String?) {
        
        isCancelled = false
        currentTask = Task {
            do {
                let localMessageId: String = String(Int.random(in: 50000...100000))
                let loadingMessageId: String = String(Int.random(in: 50000...100000))
                // 1. 创建本地消息（优先执行）
                let localMessage = createLocalMessage(text: text,imageUrl: imageUrl, messageId:localMessageId)
                appendMessages([localMessage], isInitial: false)
                
                // 2. 检查 channel 状态并处理
                let currentChannel: ChatChannel
                if channel == nil {
                    // 需要先创建 channel
                    let createParams = CreateChannelParams(
                        model: entrance.model,
                        message: text ?? "",
                        channelId: nil,
                        templateId: entrance.templateId,
                        extra: [:]
                    )
                    // 创建 channel
                    currentChannel = try await createChannel(params: createParams)
                    self.channel = currentChannel // 保存 channel
                    
                    // 创建加载中消息
                    let loadingMessage = createLoadingMessage(channel: currentChannel,messageId:loadingMessageId)
                    appendMessages([loadingMessage], isInitial: false)
                } else {
                    currentChannel = channel!
                    // 创建加载中消息
                    let loadingMessage = createLoadingMessage(channel:currentChannel,messageId:loadingMessageId)
                    appendMessages([loadingMessage], isInitial: false)
                }
                
                // 3. 构建发送参数
                var sendParam = SendMessageParam(
                    channelId: currentChannel.channelId,
                    content: text ?? "",
                    model: currentChannel.model,
                    isNewChat: false,
                    searchSwitch: false
                )
                if let imageUrl {
                    sendParam.imageUrls = [imageUrl]
                }
                
                // 4. 发送消息并处理流
                sendMessageStatePublisher.send(.generating)
                let messageStream = await ChatSendCenter.shared.sendMessage(sendParam)
                
                // 5. 处理消息流
                for try await chatMessages in messageStream {
                    if Task.isCancelled || isCancelled { return }
                    guard !chatMessages.isEmpty else { continue }
                    
                    if chatMessages.count > 1 {
                        await replaceMessages(
                            localMessageId: localMessageId,
                            loadingMessageId: loadingMessageId,
                            with: chatMessages
                        )
                    } else if let updatedMessage = chatMessages.first {
                        logUI("Received messages: \(updatedMessage.content)")
                        await updateSingleMessage(updatedMessage)
                    }
                }
                logUI("消息接收完成")
                sendMessageStatePublisher.send(.finished)
                updateGenerateSection()
            } catch {
                logUI("发送消息时出错：\(error)")
                sendMessageStatePublisher.send(.error(error))
                updateGenerateSection()
            }
        }
    }
    
    /// 替换本地消息和加载中消息
    /// - Parameters:
    ///   - localMessageId: 本地消息的 ID
    ///   - loadingMessageId: 加载中消息的 ID
    ///   - newMessages: 新接收到的消息数组
    private func replaceMessages(localMessageId: String, loadingMessageId: String, with newMessages: [ChatMessage]) async {
        var currentMessages = messagesPublisher.value
        
        // 找到本地消息和加载中消息的索引
        guard let localIndex = currentMessages.firstIndex(where: { $0.messageId == localMessageId }),
              let loadingIndex = currentMessages.firstIndex(where: { $0.messageId == loadingMessageId }) else {
            logUI("找不到需要替换的消息")
            sendMessageStatePublisher.send(.error(ChatDataError.networkError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Messages not found for replacement."]))))
            return
        }
        
        // 移除原有的本地消息和加载中消息
        currentMessages.remove(at: loadingIndex)
        currentMessages.remove(at: localIndex)
        
        if let localMessage = newMessages[safe: 0],
           let loadingMessage = newMessages[safe: 1] {
            // 添加新接收到的消息
            currentMessages.insert(localMessage, at: localIndex)
            currentMessages.insert(loadingMessage, at: loadingIndex)
            // 更新消息发布器
            messagesPublisher.send(currentMessages)
            var currentSections = sectionsPublisher.value.sections
            var updates: [ChatSection] = []
            // 查找是否有对应的分区
            if let lastSectionLocalIndex = currentSections.lastIndex(where: { $0.message.messageId == localMessageId }) {
                
                let newSection = ChatAssembly.assembleSection(localMessage,dataCenter: self)
                currentSections[lastSectionLocalIndex] = newSection
                updates.append(newSection)
            }
            if let lastSectionLoadingIndex = currentSections.lastIndex(where: { $0.message.messageId == loadingMessageId }) {
                let newSection = ChatAssembly.assembleSection(loadingMessage,dataCenter: self)
                currentSections[lastSectionLoadingIndex] = newSection
                updates.append(newSection)
            }
            let newState = ChatSectionsState(state: .updated(sections:updates), sections: currentSections)
            sectionsPublisher.send(newState)
        }
    }
    
    /// 更新单个消息内容
    /// - Parameter updatedMessage: 更新后的消息
    private func updateSingleMessage(_ updatedMessage: ChatMessage) async {
        var currentMessages = messagesPublisher.value
        
        if let index = currentMessages.firstIndex(where: { $0.messageId == updatedMessage.messageId }) {
            currentMessages[index].content += updatedMessage.content
            if updatedMessage.qaMsg.count > 0 {
                currentMessages[index].qaMsg = updatedMessage.qaMsg
            }
            if updatedMessage.content.isNotEmpty {
                currentMessages[index].content = updatedMessage.content
            }
            messagesPublisher.send(currentMessages)
            
            var currentSections = sectionsPublisher.value.sections
            // 查找是否有对应的分区
            if let lastSectionIndex = currentSections.lastIndex(where: { $0.message.messageId == updatedMessage.messageId }) {
                let newSection = ChatAssembly.assembleSection(currentMessages[index],dataCenter: self)
                currentSections[lastSectionIndex] = newSection
                logDebug("update section: \(newSection.message)")
                let newState = ChatSectionsState(state: .updated(sections: [newSection]), sections: currentSections)
                sectionsPublisher.send(newState)
            } else {
                // 创建新的分区
                let newSection = ChatAssembly.assembleSection(currentMessages[index],dataCenter: self)
                currentSections.append(newSection)
                logDebug("update section: \(newSection.message)")
                let newState = ChatSectionsState(state: .updated(sections: [newSection]), sections: currentSections)
                sectionsPublisher.send(newState)
            }
        } else {
            // 如果未找到对应的消息，可以选择添加或忽略
            logUI("无法找到需要更新的消息，消息ID: \(updatedMessage.messageId)")
            sendMessageStatePublisher.send(.error(ChatDataError.networkError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Updated message not found."]))))
        }
    }
    
    /// 刷新最后一个section
    private func updateGenerateSection() {
        
        guard let section = updateSections.last else {
            return
        }
        Task {
            await reloadSingleMessage(section.message)
        }
    }
    
    /// 更新单个消息内容
    /// - Parameter updatedMessage: 更新后的消息
    private func reloadSingleMessage(_ updatedMessage: ChatMessage) async {
        var currentSections = sectionsPublisher.value.sections
        // 查找是否有对应的分区
        if let lastSectionIndex = currentSections.lastIndex(where: { $0.message.messageId == updatedMessage.messageId }) {
            let newSection = ChatAssembly.assembleSection(updatedMessage,dataCenter: self)
            currentSections[lastSectionIndex] = newSection
            let newState = ChatSectionsState(state: .updated(sections: [newSection]), sections: currentSections)
            sectionsPublisher.send(newState)
        } else {
            // 创建新的分区
            let newSection = ChatAssembly.assembleSection(updatedMessage,dataCenter: self)
            currentSections.append(newSection)
            let newState = ChatSectionsState(state: .updated(sections: [newSection]), sections: currentSections)
            sectionsPublisher.send(newState)
        }
    }
}

// MARK: - Helper Methods
private extension ChatDataCenter {
    func createLocalMessage(text: String?, imageUrl:String?, messageId:String) -> ChatMessage {
        var localMessage = ChatMessage.default
        localMessage.message_id = Int(messageId) ?? 0
        localMessage.role = "LOCAL_USER"
        localMessage.content = text ?? ""
        if let imageUrl {
            localMessage.imageUrls = [imageUrl]
        }
        return localMessage
    }
    
    func createLoadingMessage(channel: ChatChannel, messageId:String) -> ChatMessage {
        var loadingMessage = ChatMessage.default
        loadingMessage.message_id = Int(messageId) ?? 0
        loadingMessage.role = "LOCAL_AI"
        loadingMessage.content = "Loading..."
        loadingMessage.model = channel.model
        loadingMessage.channelId = channel.channelId
        return loadingMessage
    }
}

// MARK: - ChatData + Channel
public extension ChatDataCenter {
    /// 创建channel
    func createChannel(params: CreateChannelParams) async throws -> ChatChannel {
        // 创建请求
        let target = ChatApi.createChannel(params)
        let channel: ChatChannel = try await chatAPI.requestAsync(target)
        return channel
    }
    
    /// 创建channel
    func createFileChannel(params: CreateFileChannelParams) async throws -> ChatChannel {
        // 创建请求
        let target = ChatApi.createFileChannel(params)
        let channel: ChatChannel = try await chatAPI.requestAsync(target)
        return channel
    }
}

// MARK: - ChatData + Regen
public extension ChatDataCenter {
    
    func regenMessage(section:ChatSection) {
         
        guard let channel = self.channel else {return}
        let regen = section.message
        guard let userMessage = getPreviousMessage(of:regen.messageId) else { return }
        
        
        let loadingMessageId = UUID().uuidString
        let loadingMessage = createLoadingMessage(channel: channel, messageId: loadingMessageId)

        updateChatMessage(by: section.message.messageId, with: loadingMessage)
        
        let newSection = ChatAssembly.assembleSection(loadingMessage,dataCenter: self)
        updateChatSection(by: section.message.messageId, with: newSection)
        
        Task {
            do{
                // 3. 构建发送参数
                var sendParam = SendMessageParam(
                    channelId: channel.channelId,
                    content: userMessage.content,
                    model: channel.model,
                    isNewChat: false,
                    searchSwitch: false
                )
                if let imageUrl = userMessage.imageUrls.first {
                    sendParam.imageUrls = [imageUrl]
                }
                sendParam.messageId = userMessage.messageId
                sendParam.reMessageId = regen.messageId
                
                // 4. 发送消息并处理流
                sendMessageStatePublisher.send(.generating)
                let messageStream = await ChatSendCenter.shared.sendMessage(sendParam)
                
                // 5. 处理消息流
                for try await chatMessages in messageStream {
                    guard !chatMessages.isEmpty else { continue }
                    
                    if chatMessages.count > 1 {
                        await replaceMessages(
                            localMessageId: userMessage.messageId,
                            loadingMessageId: loadingMessageId,
                            with: chatMessages
                        )
                    } else if let updatedMessage = chatMessages.first {
                        logUI("Received messages: \(updatedMessage.content)")
                        await updateSingleMessage(updatedMessage)
                    }
                }
                logUI("消息接收完成")
                sendMessageStatePublisher.send(.finished)
                updateGenerateSection()
            } catch {
                logUI("regenMessage 出现异常: \(error)")
            }
        }
        
    }
}

public extension ChatDataCenter {
    
    // 通过Bundle读取JSON文件
    func loadJSON<T: Codable>(filename: String) -> T? {
        guard let path = Bundle.main.path(forResource: filename, ofType: "json") else {
            print("找不到文件: \(filename)")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            let result = try decoder.decode(DPResponse<T>.self, from: data)
            return result.data?.biz_data
        } catch {
            print("解码失败: \(error)")
            return nil
        }
    }
}
