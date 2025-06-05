//
//  ChatAIProxyClient.swift
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


/// A client actor that manages AI service interactions based on model configuration
/// Thread-safe by design using Swift concurrency
public actor ChatAIProxyClient {
    
    // MARK: - Properties
    
    /// The current model configuration
    internal var modelConfig: ModelConfiguration

    
    // Services dictionary to cache initialized services
    internal var services: [String: Any] = [:]
    
    // MARK: - Initialization
    
    /// Initializes the client with a specific model configuration
    /// - Parameter modelConfig: The model configuration to use
    public init(modelConfig: ModelConfiguration) {
        self.modelConfig = modelConfig
        logDebug("ModelConfig: \(modelConfig.providerId),\(modelConfig.apiKey)")
    }
    
    // MARK: - Service Management
    
    /// Updates the current model configuration
    /// - Parameter modelConfig: The new model configuration to use
    public func updateModelConfig(_ modelConfig: ModelConfiguration) {
        self.modelConfig = modelConfig
        // Clear cached services when config changes
        services.removeAll()
    }
    
    /// Gets the appropriate service for the current model configuration
    /// - Returns: The service appropriate for the current provider
    public func getService() -> Any? {
        let providerId = modelConfig.providerId
        
        // Return cached service if available
        if let service = services[providerId] {
            return service
        }
        
        // Create and cache a new service based on provider type
        let service = createService(for: providerId)
        if let service = service {
            services[providerId] = service
        }
        
        return service
    }
    
    /// Creates a service for the specified provider ID
    /// - Parameter providerId: The provider ID to create a service for
    /// - Returns: The appropriate service or nil if not supported
    private func createService(for providerId: String) -> Any? {
        guard let provider = ModelProviderID(rawValue: providerId) else {
            logError("Unsupported provider ID: \(providerId)")
            return nil
        }
        
        switch provider {
        case .deepseek:
            return createDeepSeekService()
        case .openai:
            return createOpenAIService()
        case .anthropic:
            return createAnthropicService()
        case .google:
            return createGoogleService()
        case .local:
            return createLocalService()
        }
    }
    
    // MARK: - Service Creation Methods
    
    /// Creates an OpenAI service instance
    private func createOpenAIService() -> Any? {
        // Placeholder for OpenAI service creation
        // Implementation would depend on the OpenAI service protocol
        logInfo("Creating OpenAI service with base URL: \(modelConfig.baseURL)")
        return nil
    }
    
    /// Creates an Anthropic service instance
    private func createAnthropicService() -> Any? {
        // Placeholder for Anthropic service creation
        logInfo("Creating Anthropic service with base URL: \(modelConfig.baseURL)")
        return nil
    }
    
    /// Creates a Google service instance
    private func createGoogleService() -> Any? {
        // Placeholder for Google service creation
        logInfo("Creating Google service with base URL: \(modelConfig.baseURL)")
        return nil
    }
    
    /// Creates a local service instance
    private func createLocalService() -> Any? {
        // Placeholder for local service creation
        logInfo("Creating local service with base URL: \(modelConfig.baseURL)")
        return nil
    }
    
    // MARK: - Sending Messages API
    
    /// Sends a message and returns an AsyncThrowingStream of ChatAIChunk objects
    /// - Parameter message: Parameters for the message to send
    /// - Returns: An AsyncThrowingStream that emits stream chunks as they arrive
    public func sendMessage(_ message: SendAIMessageParam) -> AsyncThrowingStream<[ChatAIChunk], Error> {
        return AsyncThrowingStream { continuation in
            guard let provider = ModelProviderID(rawValue: modelConfig.providerId) else {
                continuation.finish(throwing: NSError(domain: "ChatAIProxyClient", code: -1, userInfo: ["message": "Invalid provider ID"]))
                return
            }
            
            // Handle request based on provider type
            Task {
                do {
                    switch provider {
                    case .deepseek:
                        try await sendDeepSeekMessage(message: message, continuation: continuation)
                    case .openai:
                        try await sendOpenAIMessage(message: message, continuation: continuation)
                    case .anthropic:
                        try await sendAnthropicMessage(message: message, continuation: continuation)
                    case .google:
                        try await sendGoogleMessage(message: message, continuation: continuation)
                    case .local:
                        try await sendLocalMessage(message: message, continuation: continuation)
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Provider Specific Message Methods
    
    private func sendOpenAIMessage(
        message: SendAIMessageParam,
        continuation: AsyncThrowingStream<[ChatAIChunk], Error>.Continuation
    ) async throws {
        // Placeholder for OpenAI implementation
        logInfo("Sending request to OpenAI service")
        throw NSError(domain: "ChatAIProxyClient", code: -1, userInfo: ["message": "OpenAI service not implemented"])
    }
    
    private func sendAnthropicMessage(
        message: SendAIMessageParam,
        continuation: AsyncThrowingStream<[ChatAIChunk], Error>.Continuation
    ) async throws {
        // Placeholder for Anthropic implementation
        logInfo("Sending request to Anthropic service")
        throw NSError(domain: "ChatAIProxyClient", code: -1, userInfo: ["message": "Anthropic service not implemented"])
    }
    
    private func sendGoogleMessage(
        message: SendAIMessageParam,
        continuation: AsyncThrowingStream<[ChatAIChunk], Error>.Continuation
    ) async throws {
        // Placeholder for Google implementation
        logInfo("Sending request to Google service")
        throw NSError(domain: "ChatAIProxyClient", code: -1, userInfo: ["message": "Google service not implemented"])
    }
    
    private func sendLocalMessage(
        message: SendAIMessageParam,
        continuation: AsyncThrowingStream<[ChatAIChunk], Error>.Continuation
    ) async throws {
        // Placeholder for local implementation
        logInfo("Sending request to local service")
        throw NSError(domain: "ChatAIProxyClient", code: -1, userInfo: ["message": "Local service not implemented"])
    }
    
    // MARK: - Legacy Helper Methods (for backward compatibility)
    
    /// Helper method to send a chat completion request using the appropriate service
    /// - Parameters:
    ///   - messages: The messages to send
    ///   - stream: Whether to stream the response
    ///   - completion: Completion handler
    public func sendChatCompletionRequest(
        messages: [SendAIMessage],
        stream: Bool = false,
        completion: @escaping (Result<Any, Error>) -> Void
    ) {
        Task {
            do {
                let messageStream = sendMessage(SendAIMessageParam(messages: messages, stream: stream))
                
                if stream {
                    // For streaming requests, we return the stream itself
                    completion(.success(messageStream))
                } else {
                    // For non-streaming, wait for the single result
                    let result = try await messageStream.first { _ in true }
                    completion(.success(result?.first?.content ?? ""))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Sends a chat completion request using async/await
    /// - Parameters:
    ///   - messages: The messages to send
    ///   - stream: Whether to stream the response
    /// - Returns: The chat completion response
    public func sendChatCompletionRequest(
        messages: [SendAIMessage],
        stream: Bool = false
    ) async throws -> Any {
        if stream {
            return sendMessage(SendAIMessageParam(messages: messages, stream: true))
        } else {
            let messageStream = sendMessage(SendAIMessageParam(messages: messages, stream: false))
            if let result = try await messageStream.first(where: { _ in true }) {
                return result.first?.content ?? ""
            } else {
                throw NSError(domain: "ChatAIProxyClient", code: -3, userInfo: ["message": "Empty response"])
            }
        }
    }
}

/// Logger type for diagnostic purposes
struct Logger {
    let subsystem: String
    let category: String
    
    func error(_ message: String) {
        // Implementation would log to appropriate system
        print("[\(category)] ERROR: \(message)")
    }
    
    func info(_ message: String) {
        // Implementation would log to appropriate system
        print("[\(category)] INFO: \(message)")
    }
}
