//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/17.
//

import Foundation
import ReerCodable


@Codable
public struct ChatChannelWrap: Codable, Sendable {
    public var chat_session:ChatChannel = ChatChannel()
    public var chat_messages:[ChatMessage] = []
}

extension ChatChannelWrap: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(chat_session.channelId)
    }
    public static func == (lhs: ChatChannelWrap, rhs: ChatChannelWrap) -> Bool {
        lhs.chat_session.channelId == rhs.chat_session.channelId
    }
}
