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
    public var channel:ChatChannel = ChatChannel()
    public var message:[ChatMessage] = []
}

extension ChatChannelWrap: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(channel.channelId)
    }
    public static func == (lhs: ChatChannelWrap, rhs: ChatChannelWrap) -> Bool {
        lhs.channel.channelId == rhs.channel.channelId
    }
}
