//
//  DBChatMessage.swift
//  AppComponents
//
//  Created by 巩柯 on 2025/6/1.
//

import Foundation
import WCDBSwift
import AppServices

// MARK: - Database Table Models

/// Database model for ChatMessage
public final class DBChatMessage: TableCodable {
    public var message_id: Int = 0
    public var parent_id: Int? = nil
    public var id: String = ""
    public var model: String = ""
    public var role: String = ""
    public var content: String = ""
    public var thinking_enabled: Bool = false
    public var thinking_content: String = ""
    public var thinking_elapsed_secs: Double? = nil
    public var ban_edit: Bool = false
    public var ban_regenerate: Bool = false
    public var status: String = ""
    public var accumulated_token_usage: Int = 0
    public var files: String = "" // JSON string
    public var tips: String = "" // JSON string
    public var inserted_at: Double = 0
    public var search_enabled: Bool = false
    public var search_status: String = ""
    public var search_results: String = "" // JSON string
    public var imageUrls: String = "" // JSON string
    public var channelId: String = ""
    public var qaMsg: String = "" // JSON string
    
    // Database specific fields
    public var created_timestamp: Double = Date().timeIntervalSince1970
    public var updated_timestamp: Double = Date().timeIntervalSince1970
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = DBChatMessage
        
        case message_id
        case parent_id
        case id
        case model
        case role
        case content
        case thinking_enabled
        case thinking_content
        case thinking_elapsed_secs
        case ban_edit
        case ban_regenerate
        case status
        case accumulated_token_usage
        case files
        case tips
        case inserted_at
        case search_enabled
        case search_status
        case search_results
        case imageUrls
        case channelId
        case qaMsg
        case created_timestamp
        case updated_timestamp
        
        public static let objectRelationalMapping = TableBinding(CodingKeys.self) {
            BindColumnConstraint(message_id, isPrimary: true, isAutoIncrement: true)
            BindColumnConstraint(channelId, isNotNull: true)
            BindColumnConstraint(id, isNotNull: true)
            BindColumnConstraint(role, isNotNull: true)
            BindColumnConstraint(created_timestamp, isNotNull: true)
            BindColumnConstraint(updated_timestamp, isNotNull: true)
            BindIndex(channelId, namedWith: "index_channelId")
            BindIndex(id, namedWith: "index_message_id_unique")
            BindIndex(created_timestamp, namedWith: "index_created_timestamp")
        }
    }
    
    public init() {}
    
    // Convert from AppServices ChatMessage
    public convenience init(from chatMessage: ChatMessage) {
        self.init()
        self.id = chatMessage.id
        self.model = chatMessage.model
        self.role = chatMessage.role
        self.content = chatMessage.content
        self.thinking_enabled = chatMessage.thinking_enabled
        self.thinking_content = chatMessage.thinking_content
        self.thinking_elapsed_secs = chatMessage.thinking_elapsed_secs
        self.ban_edit = chatMessage.ban_edit
        self.ban_regenerate = chatMessage.ban_regenerate
        self.status = chatMessage.status
        self.accumulated_token_usage = chatMessage.accumulated_token_usage
        self.inserted_at = chatMessage.inserted_at
        self.search_enabled = chatMessage.search_enabled
        self.search_status = chatMessage.search_status
        self.channelId = chatMessage.channelId
        
        // Convert arrays to JSON strings
        if let filesData = try? JSONEncoder().encode(chatMessage.files) {
            self.files = String(data: filesData, encoding: .utf8) ?? "[]"
        }
        if let tipsData = try? JSONEncoder().encode(chatMessage.tips) {
            self.tips = String(data: tipsData, encoding: .utf8) ?? "[]"
        }
        if let searchResultsData = try? JSONEncoder().encode(chatMessage.search_results) {
            self.search_results = String(data: searchResultsData, encoding: .utf8) ?? "[]"
        }
        if let imageUrlsData = try? JSONEncoder().encode(chatMessage.imageUrls) {
            self.imageUrls = String(data: imageUrlsData, encoding: .utf8) ?? "[]"
        }
        if let qaMsgData = try? JSONEncoder().encode(chatMessage.qaMsg) {
            self.qaMsg = String(data: qaMsgData, encoding: .utf8) ?? "[]"
        }
        
        self.updated_timestamp = Date().timeIntervalSince1970
    }
    
    // Convert to AppServices ChatMessage
    public func toChatMessage() -> ChatMessage {
        var message = ChatMessage()
        message.message_id = self.message_id
        message.parent_id = self.parent_id
        message.id = self.id
        message.model = self.model
        message.role = self.role
        message.content = self.content
        message.thinking_enabled = self.thinking_enabled
        message.thinking_content = self.thinking_content
        message.thinking_elapsed_secs = self.thinking_elapsed_secs
        message.ban_edit = self.ban_edit
        message.ban_regenerate = self.ban_regenerate
        message.status = self.status
        message.accumulated_token_usage = self.accumulated_token_usage
        message.inserted_at = self.inserted_at
        message.search_enabled = self.search_enabled
        message.search_status = self.search_status
        message.channelId = self.channelId
        
        // Convert JSON strings back to arrays
        if let filesData = self.files.data(using: .utf8),
           let files = try? JSONDecoder().decode([String].self, from: filesData) {
            message.files = files
        }
        if let tipsData = self.tips.data(using: .utf8),
           let tips = try? JSONDecoder().decode([String].self, from: tipsData) {
            message.tips = tips
        }
        if let searchResultsData = self.search_results.data(using: .utf8),
           let searchResults = try? JSONDecoder().decode([String].self, from: searchResultsData) {
            message.search_results = searchResults
        }
        if let imageUrlsData = self.imageUrls.data(using: .utf8),
           let imageUrls = try? JSONDecoder().decode([String].self, from: imageUrlsData) {
            message.imageUrls = imageUrls
        }
        if let qaMsgData = self.qaMsg.data(using: .utf8),
           let qaMsg = try? JSONDecoder().decode([String].self, from: qaMsgData) {
            message.qaMsg = qaMsg
        }
        
        return message
    }
}
