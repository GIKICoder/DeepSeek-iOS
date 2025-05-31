//
//  DBChatChannel.swift
//  AppComponents
//
//  Created by 巩柯 on 2025/6/1.
//

import Foundation
import WCDBSwift
import AppServices

/// Database model for ChatChannel
public final class DBChatChannel: TableCodable {
    public var channel_pk: Int = 0  // Primary key for database
    public var id: String = ""
    public var seq_id: Int = 0
    public var agent: String = ""
    public var character: String? = nil
    public var title: String = ""
    public var title_type: String = ""
    public var version: Int = 0
    public var current_message_id: Int = 0
    public var inserted_at: Double = 0
    public var updated_at: Double = 0
    public var model: String = ""
    
    // Database specific fields
    public var created_timestamp: Double = Date().timeIntervalSince1970
    public var updated_timestamp: Double = Date().timeIntervalSince1970
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = DBChatChannel
        
        case channel_pk
        case id
        case seq_id
        case agent
        case character
        case title
        case title_type
        case version
        case current_message_id
        case inserted_at
        case updated_at
        case model
        case created_timestamp
        case updated_timestamp
        
        public static let objectRelationalMapping = TableBinding(CodingKeys.self) {
            BindColumnConstraint(channel_pk, isPrimary: true, isAutoIncrement: true)
            BindColumnConstraint(id, isNotNull: true, isUnique: true)
            BindColumnConstraint(title, isNotNull: true)
            BindColumnConstraint(created_timestamp, isNotNull: true)
            BindColumnConstraint(updated_timestamp, isNotNull: true)
            BindIndex(id, namedWith: "index_channel_id_unique")
            BindIndex(updated_at, namedWith: "index_updated_at")
            BindIndex(created_timestamp, namedWith: "index_created_timestamp")
        }
    }
    
    public init() {}
    
    // Convert from AppServices ChatChannel
    public convenience init(from chatChannel: ChatChannel) {
        self.init()
        self.id = chatChannel.id
        self.seq_id = chatChannel.seq_id
        self.agent = chatChannel.agent
        self.character = chatChannel.character
        self.title = chatChannel.title
        self.title_type = chatChannel.title_type
        self.version = chatChannel.version
        self.current_message_id = chatChannel.current_message_id
        self.inserted_at = chatChannel.inserted_at
        self.updated_at = chatChannel.updated_at
        self.model = chatChannel.model
        self.updated_timestamp = Date().timeIntervalSince1970
    }
    
    // Convert to AppServices ChatChannel
    public func toChatChannel() -> ChatChannel {
        var channel = ChatChannel()
        channel.id = self.id
        channel.seq_id = self.seq_id
        channel.agent = self.agent
        channel.character = self.character
        channel.title = self.title
        channel.title_type = self.title_type
        channel.version = self.version
        channel.current_message_id = self.current_message_id
        channel.inserted_at = self.inserted_at
        channel.updated_at = self.updated_at
        channel.model = self.model
        return channel
    }
}
