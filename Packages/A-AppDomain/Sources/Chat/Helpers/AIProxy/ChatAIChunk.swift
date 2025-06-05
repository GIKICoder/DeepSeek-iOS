//
//  ChatAIChunk.swift
//  AppDomain
//
//  Created by GIKI on 2025/6/5.
//

import Foundation
import AppServices
import AppComponents
import AppFoundation
import AppInfra
import AIProxy


/// Stream chunk for handling streaming responses
public struct ChatAIChunk {
    public let id: String
    public let content: String
    public let isComplete: Bool
    public let usage: Any?
    
    public init(id: String,content: String, isComplete: Bool = false, usage: Any? = nil) {
        self.id = id
        self.content = content
        self.isComplete = isComplete
        self.usage = usage
    }
}
