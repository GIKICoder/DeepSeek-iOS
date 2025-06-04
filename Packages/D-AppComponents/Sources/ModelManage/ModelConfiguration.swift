import Foundation

public enum ModelProviderID: String {
    public typealias RawValue = String
    
    case openai = "openai"
    case anthropic = "anthropic"
    case deepseek = "deepseek"
    case google = "google"
    case local = "local"
}

// MARK: - AI Model
public struct AIModel: Codable, Equatable {
    public let name: String
    public let value: String
    public let avatar: String
    public let description: String
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
    public let supportModels: [AIModel]
    
    public static let allProviders: [ModelProvider] = [
        ModelProvider(
            id: ModelProviderID.openai.rawValue,
            name: "OpenAI",
            displayName: "OpenAI",
            iconName: "openai_ic",
            iconColor: "systemGreen",
            website: "https://openai.com",
            baseURL: "https://api.openai.com/v1",
            description: "领先的人工智能研究公司",
            supportModels: [
                AIModel(name: "GPT-4o", value: "gpt-4o", avatar: "gpt-4o_avatar", description: "OpenAI最先进的大规模语言模型"),
                AIModel(name: "GPT-4.1", value: "gpt-4.1", avatar: "gpt-4o_avatar", description: "GPT-4的改进版本"),
                AIModel(name: "GPT-4.1-mini", value: "gpt-4.1 mini", avatar: "gpt-4o_avatar", description: "GPT-4.1的轻量版本"),
                AIModel(name: "o1-mini", value: "o1 mini", avatar: "o1-mini_avatar", description: "OpenAI的小型语言模型"),
                AIModel(name: "o3-Mini", value: "03 mini", avatar: "o3-mini_avatar", description: "OpenAI的中型语言模型"),
                AIModel(name: "o3", value: "o3", avatar: "o3-mini_avatar", description: "OpenAI的标准语言模型"),
                AIModel(name: "o4-Mini", value: "o4 mini", avatar: "o3-mini_avatar", description: "OpenAI的大型语言模型精简版"),
                AIModel(name: "o4", value: "o4", avatar: "o3-mini_avatar", description: "OpenAI的顶级大型语言模型")
            ]
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
            supportModels: [
                AIModel(name: "Claude-3 Opus", value: "claude-opus-4-0", avatar: "claude_avatar", description: "Claude-3系列中最强大的模型"),
                AIModel(name: "Claude-3 Sonnet", value: "claude-sonnet-4-0", avatar: "claude_avatar", description: "Claude-3系列中平衡性能和效率的模型"),
                AIModel(name: "Claude-3.7 Sonnet", value: "claude-3-7-sonnet-latest", avatar: "claude_avatar", description: "Claude-3.7版本的Sonnet模型"),
                AIModel(name: "Claude-3.5 Sonnet", value: "claude-3-5-sonnet-latest", avatar: "claude_avatar", description: "Claude-3.5版本的Sonnet模型"),
                AIModel(name: "Claude-3.5 Haiku", value: "claude-3-5-haiku-latest", avatar: "claude_avatar", description: "Claude-3.5版本的Haiku模型，更快速和高效"),
                AIModel(name: "Claude-3 Opus Latest", value: "claude-3-opus-latest", avatar: "claude_avatar", description: "Claude-3 Opus的最新版本")
            ]
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
            supportModels: [
                AIModel(name: "DeepSeek-V3", value: "deepseek-chat", avatar: "deepseek_avatar", description: "DeepSeek的对话型AI模型"),
                AIModel(name: "DeepSeek-R1", value: "deepseek-reasoner", avatar: "deepseek_avatar", description: "DeepSeek的推理型AI模型")
            ]
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
            supportModels: [
                AIModel(name: "Gemini Pro", value: "gemini-pro", avatar: "geminiai_ic", description: "Gemini的高性能文本模型"),
                AIModel(name: "Gemini Pro Vision", value: "geminiai_ic", avatar: "gemini_avatar", description: "Gemini的多模态模型，支持图像理解")
            ]
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
            supportModels: [
                AIModel(name: "本地助手", value: "local-assistant", avatar: "local_avatar", description: "在本地设备上运行的AI助手模型")
            ]
        )
    ]
}

// MARK: - Model Configuration
public struct ModelConfiguration: Codable, Equatable {
    public let id: String
    public let providerId: String
    public let apiKey: String
    public let baseURL: String
    public let selectedModel: AIModel
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
