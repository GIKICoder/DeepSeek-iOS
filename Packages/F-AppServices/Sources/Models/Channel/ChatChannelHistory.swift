//
//  ChatChannelHistory.swift
//  AppServices
//
//  Created by GIKI on 2025/1/22.
//

import Foundation
import ReerCodable


@Codable
public struct ChatChannelHistory: Codable, Sendable {
    public var channel:ChatChannel = ChatChannel()
    public var message:ChatMessage?
}

extension ChatChannelHistory: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(channel.channelId)
    }
    
    public static func == (lhs: ChatChannelHistory, rhs: ChatChannelHistory) -> Bool {
        lhs.channel.channelId == rhs.channel.channelId
    }
}
