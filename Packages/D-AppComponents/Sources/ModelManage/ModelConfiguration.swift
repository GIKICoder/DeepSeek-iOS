import Foundation

public enum ModelProviderID: String {
    public typealias RawValue = String
    
    case openai = "openai"
    case anthropic = "anthropic"
    case deepseek = "deepseek"
    case google = "google"
    case local = "local"
}

// MARK: - Model Provider
public struct ModelProvider: Codable, Equatable {
    public let id: String
    public let name: String
    public let displayName: String
    public let iconName: String
    public let iconColor: String
    public let website: String
    public let baseURL: String
    public let description: String
    public let supportModels: [String]
    
    static let allProviders: [ModelProvider] = [
        ModelProvider(
            id: ModelProviderID.openai.rawValue,
            name: "OpenAI",
            displayName: "OpenAI",
            iconName: "openai_ic",
            iconColor: "systemGreen",
            website: "https://openai.com",
            baseURL: "https://api.openai.com/v1",
            description: "领先的人工智能研究公司",
            supportModels: ["gpt-4o","gpt-4.1","gpt-4.1 mini","o1 mini","03 mini","o3","o4 mini","o4"]
        ),
        ModelProvider(
            id: ModelProviderID.anthropic.rawValue,
            name: "Anthropic",
            displayName: "Claude",
            iconName: "claude_ic",
            iconColor: "systemBlue",
            website: "https://anthropic.com",
            baseURL: "https://api.anthropic.com/v1",
            description: "Claude是由Anthropic开发的AI助手，专注于提供有用、无害且诚实的对话体验。",
            supportModels: ["claude-opus-4-0","claude-sonnet-4-0","claude-3-7-sonnet-latest","claude-3-5-sonnet-latest","claude-3-5-haiku-latest","claude-3-opus-latest"]
        ),
        ModelProvider(
            id: ModelProviderID.deepseek.rawValue,
            name: "DeepSeek",
            displayName: "DeepSeek",
            iconName: "deepseek_ic",
            iconColor: "systemPurple",
            website: "https://deepseek.com",
            baseURL: "https://api.deepseek.com/v1",
            description: "深度推理AI模型",
            supportModels: ["deepseek-chat", "deepseek-reasoner"]
        ),
        ModelProvider(
            id: ModelProviderID.google.rawValue,
            name: "Google",
            displayName: "Gemini",
            iconName: "geminiai_ic",
            iconColor: "systemRed",
            website: "https://ai.google.dev",
            baseURL: "https://generativelanguage.googleapis.com/v1",
            description: "Google的多模态AI模型",
            supportModels: ["gemini-pro", "gemini-pro-vision"]
        ),
        ModelProvider(
            id: ModelProviderID.local.rawValue,
            name: "Local",
            displayName: "本地模型",
            iconName: "cpu",
            iconColor: "systemOrange",
            website: "",
            baseURL: "http://localhost:8080/v1",
            description: "本地运行的AI模型",
            supportModels: ["local-assistant"]
        )
    ]
}

// MARK: - Model Configuration
public struct ModelConfiguration: Codable, Equatable {
    public let id: String
    public let providerId: String
    public let apiKey: String
    public let baseURL: String
    public let selectedModel: String
    public var isActive: Bool
    public let createdAt: Date
    public let lastUsed: Date
    
    // Advanced Settings
    public let temperature: Float
    public let topP: Float
    public let contextMessageLimit: Float
    
    public var provider: ModelProvider? {
        ModelProvider.allProviders.first { $0.id == providerId }
    }
}

// MARK: - Usage Statistics
public struct UsageStatistics: Codable {
    public let todayRequests: Int
    public let monthlyRequests: Int
    public let monthlyLimit: Int
    public let averageResponseTime: Double
    public let lastUpdated: Date
}
