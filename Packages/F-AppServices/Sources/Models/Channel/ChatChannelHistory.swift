//
//  ChatChannelHistory.swift
//  AppServices
//
//  Created by GIKI on 2025/1/22.
//

import Foundation
import ReerCodable


@Codable
@DefaultInstance
public struct ChatChannelHistory: Codable, Sendable {
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
}


extension ChatChannelHistory: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: ChatChannelHistory, rhs: ChatChannelHistory) -> Bool {
        lhs.id == rhs.id
    }
}

@Codable
public struct ChatHistoryWarp: Codable, Sendable {
    public var chat_sessions: [ChatChannelHistory] = []
}
