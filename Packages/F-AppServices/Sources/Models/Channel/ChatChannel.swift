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
@frozen public struct ChatChannel: Codable, Sendable {
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
    
    public var  channelId: String {
        set {
            id = newValue
        }
        get {
            id
        }
    }
    public var model: String = ""
    
}

