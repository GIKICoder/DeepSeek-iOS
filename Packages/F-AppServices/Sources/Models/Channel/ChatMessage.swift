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
    public var message_id: Int = 0
    public var parent_id: Int? = nil
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
    public var files: [String] = []
    public var tips: [String] = []
    public var inserted_at: Double = 0
    public var search_enabled: Bool = false
    public var search_status: String = ""
    public var search_results: [String] = []
    
    public var imageUrls: [String] = []
    public var channelId: String = ""
    public var qaMsg: [String] = []
}

public extension ChatMessage {
    
    var aiMessage: Bool  {
        role == "ASSISTANT"
    }
    
    var loadingMessage: Bool  {
        role == "LOCAL_AI"
    }
    
    var fakeMessage: Bool  {
        role == "FAKE"
    }
    
    var messageId: String {
        "\(message_id)"
    }
    
    var last: Bool {
        true
    }
}

@Codable
@DefaultInstance
@Copyable
@frozen public struct ChatSearchResult: Codable, Sendable {
    public var url: String = ""
    public var title: String = ""
    public var snippet: String = ""
    public var cite_index: Int? = nil
    public var published_at: Double = 0
    public var site_name: String? = nil
    public var site_icon: String = ""
}
