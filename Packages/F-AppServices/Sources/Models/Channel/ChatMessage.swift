//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/15.
//

import Foundation
import ReerCodable

@Codable
@DefaultInstance
@Copyable
@frozen public struct ChatMessage: Codable, Sendable {
    public var  channelId: String = ""
    public var  content: String = ""
    public var  createdAt: Int64 = 0
    public var  deleted: Bool = false
    public var  finalContent: String = ""
    public var  messageId: String = ""
    public var  msgStatus: String = ""
    public var  roleEnum: String = ""
    public var  uid: String = ""
    public var  qaMsg: [String] = []
    public var  imageUrls: [String] = []
    public var  mediaType: String = ""
    public var  id: Int = 0
    public var  model: String = ""
    public var  last: Bool = false
}


public extension ChatMessage {
    
    var aiMessage: Bool  {
        roleEnum == "AI"
    }
    
    var loadingMessage: Bool  {
        roleEnum == "LOCAL_AI"
    }
    
    var fakeMessage: Bool  {
        roleEnum == "FAKE"
    }
}
