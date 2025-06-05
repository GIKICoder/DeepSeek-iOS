//
//  SendAIMessageParam.swift
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

/// Structure to encapsulate message sending parameters
public struct SendAIMessageParam {
    public var channelId: String = UUID().uuidString
    public let messages: [SendAIMessage]
    public let stream: Bool
    
    public init(messages: [SendAIMessage], stream: Bool = true) {
        self.messages = messages
        self.stream = stream
    }
}

///
public enum SendAIMessage: Encodable {
    /// Messages sent by the model in response to user messages
    ///
    /// - Parameters:
    ///   - content: The contents of the assistant message. Can be a single string or multiple strings
    ///   - name: An optional name for the participant. Provides the model information to differentiate
    ///           between participants of the same role.
    ///   - prefix: (Beta) Set this to true to force the model to start its answer by the
    ///             content of the supplied prefix in this assistant message. You must set
    ///             base_url="https://api.deepseek.com/beta" to use this feature.
    ///   - reasoningContent: (Beta) Used for the deepseek-reasoner model in the Chat Prefix Completion feature
    ///                       as the input for the CoT in the last assistant message.  When using this feature,
    ///                       the prefix parameter must be set to true.
    case assistant(
        content: String,
        name: String? = nil,
        prefix: Bool? = nil,
        reasoningContent: String? = nil
    )

    /// Developer-provided instructions that the model should follow.
    ///
    /// - Parameters:
    ///   - content: The contents of the system message.
    ///   - name: An optional name for the participant. Provides the model information to differentiate
    ///           between participants of the same role.
    case system(
        content: String,
        name: String? = nil
    )

    /// - Parameters:
    ///   - content: The contents of the tool message.
    ///   - toolCallID: Tool call that this message is responding to.
    case tool(
        content: String,
        toolCallID: String
    )

    /// Messages sent by an end user, containing prompts or additional context information.
    ///
    /// - Parameters:
    ///   - content: The contents of the user message.
    ///   - name: An optional name for the participant. Provides the model information to differentiate
    ///           between participants of the same role.
    case user(
        content: String,
        name: String? = nil
    )

    var role: String {
        switch self {
        case .assistant: return "assistant"
        case .system: return "system"
        case .tool: return "tool"
        case .user: return "user"
        }
    }
    private enum RootKey: String, CodingKey {
        case content
        case name
        case prefix
        case reasoningContent = "reasoning_content"
        case role
        case toolCallID = "tool_call_id"
    }
}
