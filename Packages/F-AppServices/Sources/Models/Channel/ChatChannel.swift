//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/15.
//

import Foundation
import ReerCodable

@Codable
public struct ChatChannel: Codable, Sendable {
    public var  channelId: String = ""
    public var  channelName: String = ""
    public var  createdAt: Int = 0
    public var  creatorUid: String = ""
    public var  status: Int = 0
    public var model: String = ""
}
