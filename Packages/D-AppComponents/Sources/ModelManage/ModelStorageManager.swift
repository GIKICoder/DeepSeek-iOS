import Foundation
import Security

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
            iconName: "brain",
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
            iconName: "robot",
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
            iconName: "magnifyingglass",
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
            iconName: "gem",
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

// MARK: - Model Storage Manager
public class ModelStorageManager {
    static let shared = ModelStorageManager()
    
    private let userDefaults = UserDefaults.standard
    private let configurationsKey = "ModelConfigurations"
    private let usageStatsKey = "UsageStatistics"
    
    private init() {}
    
    // MARK: - Model Configurations
    func saveConfiguration(_ config: ModelConfiguration) {
        var configurations = loadConfigurations()
        
        // 移除相同providerId的配置
        configurations.removeAll { $0.providerId == config.providerId }
        
        // 添加新配置
        configurations.append(config)
        
        // 保存到UserDefaults
        if let data = try? JSONEncoder().encode(configurations) {
            userDefaults.set(data, forKey: configurationsKey)
        }
    }
    
    func loadConfigurations() -> [ModelConfiguration] {
        guard let data = userDefaults.data(forKey: configurationsKey),
              let configurations = try? JSONDecoder().decode([ModelConfiguration].self, from: data) else {
            return []
        }
        return configurations
    }
    
    func getAllConfigurations() -> [ModelConfiguration] {
        return loadConfigurations()
    }
    
    func getActiveConfigurations() -> [ModelConfiguration] {
        return loadConfigurations().filter { $0.isActive }
    }
    
    func getConfiguration(for providerId: String) -> ModelConfiguration? {
        return loadConfigurations().first { $0.providerId == providerId }
    }
    
    func deleteConfiguration(withId id: String) {
        var configurations = loadConfigurations()
        configurations.removeAll { $0.id == id }
        
        if let data = try? JSONEncoder().encode(configurations) {
            userDefaults.set(data, forKey: configurationsKey)
        }
    }
    
    func removeConfiguration(for providerId: String) {
        var configurations = loadConfigurations()
        configurations.removeAll { $0.providerId == providerId }
        
        if let data = try? JSONEncoder().encode(configurations) {
            userDefaults.set(data, forKey: configurationsKey)
        }
    }
    
    func clearAllConfigurations() {
        userDefaults.removeObject(forKey: configurationsKey)
    }
    
    func toggleConfigurationStatus(for providerId: String) {
        var configurations = loadConfigurations()
        
        if let index = configurations.firstIndex(where: { $0.providerId == providerId }) {
            let config = configurations[index]
            let newConfig = ModelConfiguration(
                id: config.id,
                providerId: config.providerId,
                apiKey: config.apiKey,
                baseURL: config.baseURL,
                selectedModel: config.selectedModel,
                isActive: !config.isActive,
                createdAt: config.createdAt,
                lastUsed: Date()
            )
            configurations[index] = newConfig
            
            if let data = try? JSONEncoder().encode(configurations) {
                userDefaults.set(data, forKey: configurationsKey)
            }
        }
    }
    
    // MARK: - Usage Statistics
    func saveUsageStatistics(_ stats: UsageStatistics) {
        if let data = try? JSONEncoder().encode(stats) {
            userDefaults.set(data, forKey: usageStatsKey)
        }
    }
    
    func getUsageStatistics() -> UsageStatistics {
        guard let data = userDefaults.data(forKey: usageStatsKey),
              let stats = try? JSONDecoder().decode(UsageStatistics.self, from: data) else {
            return UsageStatistics(
                todayRequests: 0,
                monthlyRequests: 0,
                monthlyLimit: 10000,
                averageResponseTime: 0.0,
                lastUpdated: Date()
            )
        }
        return stats
    }
    
    // MARK: - Secure API Key Storage
    private func saveAPIKeyToKeychain(_ apiKey: String, for providerId: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "apikey_\(providerId)",
            kSecAttrService as String: "DeepSeek-ModelManage",
            kSecValueData as String: apiKey.data(using: .utf8) ?? Data()
        ]
        
        // 删除旧的记录
        SecItemDelete(query as CFDictionary)
        
        // 添加新记录
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private func getAPIKeyFromKeychain(for providerId: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "apikey_\(providerId)",
            kSecAttrService as String: "DeepSeek-ModelManage",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let data = item as? Data,
              let apiKey = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return apiKey
    }
}
