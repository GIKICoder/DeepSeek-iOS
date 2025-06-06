//
//  ChatAIProxy+DeepSeek.swift
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

extension ChatAIProxyClient {
    // MARK: - Service Creation Methods
    
    /// Creates a DeepSeek service instance
    internal func createDeepSeekService() -> DeepSeekService {
        let deepSeekService = AIProxy.deepSeekDirectService(
            unprotectedAPIKey: modelConfig.apiKey
        )
        return deepSeekService
    }
    
    // MARK: - Provider Specific Message Methods
    
    internal func sendDeepSeekMessage(
        message: SendAIMessageParam,
        continuation: AsyncThrowingStream<[ChatAIChunk], Error>.Continuation
    ) async throws {
        // Get the DeepSeek service
        guard let service = getService() as? DeepSeekService else {
            throw NSError(domain: "ChatAIProxyClient", code: -1, userInfo: ["message": "DeepSeek service unavailable"])
        }
        
        
        logInfo("Preparing request to DeepSeek service")
        
        // Convert generic messages to DeepSeek-specific messages
        var deepSeekMessages: [DeepSeekChatCompletionRequestBody.Message] = []
        for aimessage in message.messages {
            switch aimessage {
            case .assistant(let content, let name, let prefix, let reasoningContent):
                deepSeekMessages.append(.assistant(content: content, name: name, prefix: prefix, reasoningContent: reasoningContent))
            case .system(let content, let name):
                deepSeekMessages.append(.system(content: content, name: name))
            case .tool(let content, let toolCallID):
                deepSeekMessages.append(.tool(content: content, toolCallID: toolCallID))
            case .user(let content, let name):
                deepSeekMessages.append(.user(content: content, name: name))
            }
        }
        
        // Create the request body
        let requestBody = DeepSeekChatCompletionRequestBody(
            messages: deepSeekMessages,
            model: modelConfig.currentModel.value,
            stream: message.stream,
            temperature: Double(modelConfig.temperature),
            topP: Double(modelConfig.topP)
        )
        
        if message.stream {
            do {
                // Streaming request
                let stream = try await service.streamingChatCompletionRequest(
                    body: requestBody,
                    secondsToWait: 360
                )
                
                var accumulatedContent = ""
                var chunkId: String = ""
                // Process the stream
                for try await chunk in stream {
                    let delta = chunk.choices.first?.delta.content ?? ""
                    logDebug("delta:\(delta)")
                    accumulatedContent += delta
                    chunkId = chunk.id ?? ""
                    let streamChunk = ChatAIChunk(
                        id: chunkId,
                        content: delta,
                        isComplete: false,
                        usage: chunk.usage
                    )
                    
                    continuation.yield([streamChunk])
                }
                
                // Send final completion
                let finalChunk = ChatAIChunk(
                    id: chunkId,
                    content: accumulatedContent,
                    isComplete: true,
                    usage: nil
                )
                
                continuation.yield([finalChunk])
                continuation.finish()
            } catch {
                logError("Streaming request failed: \(error)")
                continuation.finish(throwing: error)
            }
        } else {
            do {
                // Non-streaming request - send complete response at once
                let response = try await service.chatCompletionRequest(
                    body: requestBody,
                    secondsToWait: 120
                )
                
                let content = response.choices.first?.message.content ?? ""
                
                let streamChunk = ChatAIChunk(
                    id: response.id,
                    content: content,
                    isComplete: true,
                    usage: response.usage
                )
                
                continuation.yield([streamChunk])
                continuation.finish()
            } catch {
                logError("Non-streaming request failed: \(error)")
                continuation.finish(throwing: error)
            }
        }
    }
    
}
