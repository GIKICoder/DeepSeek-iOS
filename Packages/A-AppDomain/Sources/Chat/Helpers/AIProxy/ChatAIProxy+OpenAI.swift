//
//  ChatAIProxy+OpenAI.swift
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
    
    /// Creates an OpenAI service instance
    internal func createOpenAIService() -> OpenAIService {
        let openAIService = AIProxy.openAIDirectService(
            unprotectedAPIKey: modelConfig.apiKey
        )
        return openAIService
    }
  
    // MARK: - Provider Specific Message Methods
    
    internal func sendOpenAIMessage(
        message: SendAIMessageParam,
        continuation: AsyncThrowingStream<[ChatAIChunk], Error>.Continuation
    ) async throws {
        // Get the DeepSeek service
        guard let service = getService() as? OpenAIService else {
            throw NSError(domain: "ChatAIProxyClient", code: -1, userInfo: ["message": "OpenAI service unavailable"])
        }
        logInfo("Sending request to OpenAI service")
        // Convert generic messages to DeepSeek-specific messages
        var openAIMessages: [OpenAIChatCompletionRequestBody.Message] = []
        for aimessage in message.messages {
            switch aimessage {
            case .assistant(let content, let name, let prefix, let reasoningContent):
                openAIMessages.append(.assistant(content: .text(content), name: name))
            case .system(let content, let name):
                openAIMessages.append(.system(content: .text(content), name: name))
            case .tool(let content, let toolCallID):
                openAIMessages.append(.tool(content: .text(content), toolCallID: toolCallID))
            case .user(let content, let name):
                openAIMessages.append(.user(content: .text(content), name: name))
            }
        }
        
        let requestBody = OpenAIChatCompletionRequestBody(
            model: modelConfig.selectedModel.value,
            messages: openAIMessages,
            stream: message.stream,
            temperature: Double(modelConfig.temperature),
            topP: Double(modelConfig.topP)
        )
        if message.stream {
            do {
                let stream = try await service.streamingChatCompletionRequest(body: requestBody)
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
            } catch AIProxyError.unsuccessfulRequest(let statusCode, let responseBody) {
                print("Received \(statusCode) status code with response body: \(responseBody)")
                continuation.finish(throwing:  NSError(domain: "ChatAIProxyClient", code: statusCode, userInfo: ["message": responseBody]))
            } catch {
                print("Could not create OpenAI streaming chat completion: \(error.localizedDescription)")
                continuation.finish(throwing: error)
            }
        }
    }
    
}
