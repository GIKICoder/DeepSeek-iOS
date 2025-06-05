import Foundation
import Security

// MARK: - Model Storage Manager
public class ModelStorageManager {
    public static let shared = ModelStorageManager()
    
    private let userDefaults = UserDefaults.standard
    private let configurationsKey = "ModelConfigurations"
    private let currentConfigurationsKey = "ModelConfigurations.current"
    private let usageStatsKey = "UsageStatistics"
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// 获取当前活跃的模型配置
    /// - Returns: 当前活跃的模型配置，如果不存在则返回第一个活跃配置
    public func currentConfig() -> ModelConfiguration? {
        if let current = loadCurrentConfig(), let active = activeConfig(withId: current.providerId) {
            return current
        }
        return loadConfigs().first { $0.isActive }
    }
    
    /// 设置当前活跃的模型配置
    /// - Parameter config: 要设置为当前活跃的模型配置
    public func setCurrent(_ config: ModelConfiguration) {
        saveCurrentConfig(config)
    }
    
    /// 获取所有已保存的模型配置
    /// - Returns: 所有模型配置的数组
    public func allConfigs() -> [ModelConfiguration] {
        return loadConfigs()
    }
    
    /// 获取所有处于活跃状态的模型配置
    /// - Returns: 活跃状态的模型配置数组
    public func activeConfigs() -> [ModelConfiguration] {
        return loadConfigs().filter { $0.isActive }
    }
    
    /// 根据提供商ID获取活跃的模型配置
    /// - Parameter providerID: 模型提供商ID枚举
    /// - Returns: 匹配的活跃模型配置，如果不存在则返回nil
    public func activeConfig(for providerID: ModelProviderID) -> ModelConfiguration? {
        return loadConfigs().first { $0.providerId == providerID.rawValue && $0.isActive }
    }
    
    /// 根据提供商ID字符串获取活跃的模型配置
    /// - Parameter id: 提供商ID字符串
    /// - Returns: 匹配的活跃模型配置，如果不存在则返回nil
    public func activeConfig(withId id: String) -> ModelConfiguration? {
        return loadConfigs().first { $0.providerId == id && $0.isActive }
    }
    
    /// 根据提供商ID获取模型配置（无论是否活跃）
    /// - Parameter providerId: 提供商ID字符串
    /// - Returns: 匹配的模型配置，如果不存在则返回nil
    public func config(for providerId: String) -> ModelConfiguration? {
        return loadConfigs().first { $0.providerId == providerId }
    }
    
    /// 保存或更新模型配置
    /// - Parameter config: 要保存的模型配置
    public func saveConfig(_ config: ModelConfiguration) {
        var configurations = loadConfigs()
        
        // 移除相同providerId的配置
        configurations.removeAll { $0.providerId == config.providerId }
        
        // 添加新配置
        configurations.append(config)
        
        // 保存到UserDefaults
        if let data = try? JSONEncoder().encode(configurations) {
            userDefaults.set(data, forKey: configurationsKey)
        }
    }
    
    /// 删除指定ID的模型配置
    /// - Parameter id: 配置ID
    public func deleteConfig(withId id: String) {
        var configurations = loadConfigs()
        configurations.removeAll { $0.id == id }
        
        if let data = try? JSONEncoder().encode(configurations) {
            userDefaults.set(data, forKey: configurationsKey)
        }
    }
    
    /// 删除指定提供商的模型配置
    /// - Parameter providerId: 提供商ID
    public func removeConfig(for providerId: String) {
        var configurations = loadConfigs()
        configurations.removeAll { $0.providerId == providerId }
        
        if let data = try? JSONEncoder().encode(configurations) {
            userDefaults.set(data, forKey: configurationsKey)
        }
    }
    
    /// 清除所有模型配置
    public func clearAllConfigs() {
        userDefaults.removeObject(forKey: configurationsKey)
    }
    
    /// 切换指定提供商配置的活跃状态
    /// - Parameter providerId: 提供商ID
    public func toggleConfigStatus(for providerId: String) {
        var configurations = loadConfigs()
        
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
                lastUsed: Date(),
                temperature: config.temperature,
                topP: config.topP,
                contextMessageLimit: config.contextMessageLimit
            )
            configurations[index] = newConfig
            
            if let data = try? JSONEncoder().encode(configurations) {
                userDefaults.set(data, forKey: configurationsKey)
            }
        }
    }
    
    /// 保存使用统计数据
    /// - Parameter stats: 使用统计数据
    public func saveUsageStats(_ stats: UsageStatistics) {
        if let data = try? JSONEncoder().encode(stats) {
            userDefaults.set(data, forKey: usageStatsKey)
        }
    }
    
    /// 获取使用统计数据
    /// - Returns: 使用统计数据，如果不存在则返回默认值
    public func getUsageStats() -> UsageStatistics {
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
    
    // MARK: - Private Methods
    
    /// 保存当前活跃的模型配置
    private func saveCurrentConfig(_ config: ModelConfiguration) {
        if let data = try? JSONEncoder().encode(config) {
            userDefaults.set(data, forKey: currentConfigurationsKey)
        }
    }
    
    /// 加载当前活跃的模型配置
    private func loadCurrentConfig() -> ModelConfiguration? {
        guard let data = userDefaults.data(forKey: currentConfigurationsKey),
              let configuration = try? JSONDecoder().decode(ModelConfiguration.self, from: data) else {
            return nil
        }
        return configuration
    }
    
    /// 加载所有模型配置
    private func loadConfigs() -> [ModelConfiguration] {
        guard let data = userDefaults.data(forKey: configurationsKey),
              let configurations = try? JSONDecoder().decode([ModelConfiguration].self, from: data) else {
            return []
        }
        return configurations
    }
    
    // MARK: - Secure API Key Storage
    
    /// 将API密钥安全保存到钥匙串
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
    
    /// 从钥匙串获取API密钥
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
