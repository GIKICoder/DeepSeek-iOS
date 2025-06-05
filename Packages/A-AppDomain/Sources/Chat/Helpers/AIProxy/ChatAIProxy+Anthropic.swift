//
//  ChatAIProxy+Anthropic.swift
//  AppDomain
//
//  Created by 巩柯 on 2025/6/6.
//


import Foundation
import AppServices
import AppComponents
import AppFoundation
import AppInfra
import AIProxy

extension ChatAIProxyClient {
    
    // MARK: - Service Creation Methods
    /// Creates an Anthropic service instance
    internal func createAnthropicService() -> AnthropicService {
        let anthropicService = AIProxy.anthropicDirectService(
            unprotectedAPIKey: "your-anthropic-key"
        )
        return anthropicService
    }
    
    // MARK: - Provider Specific Message Methods
   

    internal func sendAnthropicMessage(
        message: SendAIMessageParam,
        continuation: AsyncThrowingStream<[ChatAIChunk], Error>.Continuation
    ) async throws {
        // Get the DeepSeek service
        guard let service = getService() as? AnthropicService else {
            throw NSError(domain: "ChatAIProxyClient", code: -1, userInfo: ["message": "OpenAI service unavailable"])
        }
        logInfo("Sending request to OpenAI service")
        // Convert generic messages to DeepSeek-specific messages
        var sendMessages: [AnthropicInputMessage] = []
        for aimessage in message.messages {
            switch aimessage {
            case .assistant(let content, let name, let prefix, let reasoningContent):
                sendMessages.append(
                    .init(
                        content: [.text(content)],
                        role: .assistant
                    )
                )
            case .user(let content, let name):
                sendMessages.append(
                    .init(
                        content: [.text(content)],
                        role: .user
                    )
                )
            default:
                logDebug("Unsupported message type: \(aimessage)")
            }
        }
    
        let requestBody = AnthropicMessageRequestBody(
            maxTokens: modelConfig.maxTokens,
            messages: sendMessages,
            model:modelConfig.selectedModel.value,
            temperature: Double(modelConfig.temperature),
            topP: Double(modelConfig.topP)
        )
        if message.stream {
            do {
                let stream = try await service.streamingMessageRequest(body: requestBody)
                for try await chunk in stream {
                    switch chunk {
                    case .text(let text):
                        print(text)
                    case .toolUse(name: let toolName, input: let toolInput):
                        print("Claude wants to call tool \(toolName) with input \(toolInput)")
                    }
                }
            }  catch AIProxyError.unsuccessfulRequest(let statusCode, let responseBody) {
                print("Received non-200 status code: \(statusCode) with response body: \(responseBody)")
            } catch {
                print("Could not use Anthropic's message stream: \(error.localizedDescription)")
            }
        }
    }
    
}
