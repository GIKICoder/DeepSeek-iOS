import Foundation

// MARK: - Model Provider
public struct ModelProvider: Codable, Equatable {
    let id: String
    let name: String
    let displayName: String
    let iconName: String
    let iconColor: String
    let website: String
    let baseURL: String
    let description: String
    let supportModels: [String]
    
    static let allProviders: [ModelProvider] = [
        ModelProvider(
            id: "openai",
            name: "OpenAI",
            displayName: "OpenAI",
            iconName: "openai_ic",
            iconColor: "systemGreen",
            website: "https://openai.com",
            baseURL: "https://api.openai.com/v1",
            description: "领先的人工智能研究公司",
            supportModels: ["gpt-4", "gpt-4-turbo", "gpt-3.5-turbo"]
        ),
        ModelProvider(
            id: "anthropic",
            name: "Anthropic",
            displayName: "Claude",
            iconName: "claude_ic",
            iconColor: "systemBlue",
            website: "https://anthropic.com",
            baseURL: "https://api.anthropic.com/v1",
            description: "专注于AI安全的研究公司",
            supportModels: ["claude-3-opus", "claude-3-sonnet", "claude-3-haiku"]
        ),
        ModelProvider(
            id: "deepseek",
            name: "DeepSeek",
            displayName: "DeepSeek",
            iconName: "deepseek_ic",
            iconColor: "systemPurple",
            website: "https://deepseek.com",
            baseURL: "https://api.deepseek.com/v1",
            description: "深度推理AI模型",
            supportModels: ["deepseek-chat", "deepseek-coder"]
        ),
        ModelProvider(
            id: "google",
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
            id: "local",
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
    let id: String
    let providerId: String
    let apiKey: String
    let baseURL: String
    let selectedModel: String
    var isActive: Bool
    let createdAt: Date
    let lastUsed: Date
    
    var provider: ModelProvider? {
        ModelProvider.allProviders.first { $0.id == providerId }
    }
}

// MARK: - Usage Statistics
public struct UsageStatistics: Codable {
    let todayRequests: Int
    let monthlyRequests: Int
    let monthlyLimit: Int
    let averageResponseTime: Double
    let lastUpdated: Date
}
