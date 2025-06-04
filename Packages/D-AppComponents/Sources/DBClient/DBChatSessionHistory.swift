//
//  DBChatSessionHistory.swift
//  AppComponents
//
//  Created by GIKI on 2025/6/1.
//

import Foundation
import WCDBSwift
import AppServices

/// Database model for ChatSessionHistory
public final class DBChatSessionHistory: TableCodable {
    public var history_pk: Int = 0  // Primary key for database
    public var id: String = ""
    public var seqId: Int = 0
    public var agent: String = ""
    public var title: String = ""
    public var titleType: String = ""
    public var version: Int = 0
    public var currentMessageId: Int = 0
    public var insertedAt: Double = 0.0
    public var updatedAt: Double = 0.0
    public var character: String? = nil
    public var message: String = ""
    
    // Database specific fields
    public var created_timestamp: Double = Date().timeIntervalSince1970
    public var updated_timestamp: Double = Date().timeIntervalSince1970
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = DBChatSessionHistory
        
        case history_pk
        case id
        case seqId
        case agent
        case title
        case titleType
        case version
        case currentMessageId
        case insertedAt
        case updatedAt
        case character
        case message
        case created_timestamp
        case updated_timestamp
        
        public static let objectRelationalMapping = TableBinding(CodingKeys.self) {
            BindColumnConstraint(history_pk, isPrimary: true, isAutoIncrement: true)
            BindColumnConstraint(id, isNotNull: true)
            BindColumnConstraint(title, isNotNull: true)
            BindColumnConstraint(created_timestamp, isNotNull: true)
            BindColumnConstraint(updated_timestamp, isNotNull: true)
            BindIndex(id, namedWith: "index_history_id")
            BindIndex(updatedAt, namedWith: "index_history_updated_at")
            BindIndex(created_timestamp, namedWith: "index_history_created_timestamp")
        }
    }
    
    public init() {}
    
    // Convert from AppServices ChatSessionHistory
    public convenience init(from sessionHistory: ChatSessionHistory) {
        self.init()
        self.id = sessionHistory.id
        self.seqId = sessionHistory.seqId
        self.agent = sessionHistory.agent
        self.title = sessionHistory.title
        self.titleType = sessionHistory.titleType
        self.version = sessionHistory.version
        self.currentMessageId = sessionHistory.currentMessageId
        self.insertedAt = sessionHistory.insertedAt
        self.updatedAt = sessionHistory.updatedAt
        self.character = sessionHistory.character
        self.message = sessionHistory.message
        self.updated_timestamp = Date().timeIntervalSince1970
    }
    
    // Convert to AppServices ChatSessionHistory
    public func toChatSessionHistory() -> ChatSessionHistory {
        var history = ChatSessionHistory()
        history.id = self.id
        history.seqId = self.seqId
        history.agent = self.agent
        history.title = self.title
        history.titleType = self.titleType
        history.version = self.version
        history.currentMessageId = self.currentMessageId
        history.insertedAt = self.insertedAt
        history.updatedAt = self.updatedAt
        history.character = self.character
        history.message = self.message
        return history
    }
}
