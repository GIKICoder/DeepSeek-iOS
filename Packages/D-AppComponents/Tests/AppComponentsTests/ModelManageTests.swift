import XCTest
@testable import AppComponents

final class ModelManageTests: XCTestCase {
    
    var storageManager: ModelStorageManager!
    
    override func setUp() {
        super.setUp()
        storageManager = ModelStorageManager.shared
        // Clear any existing configurations for clean tests
        storageManager.clearAllConfigurations()
    }
    
    override func tearDown() {
        // Clean up after tests
        storageManager.clearAllConfigurations()
        super.tearDown()
    }
    
    func testModelProviderInitialization() {
        // Test that all providers are correctly initialized
        let providers = ModelProvider.allProviders
        XCTAssertEqual(providers.count, 5, "Should have 5 providers")
        
        // Check OpenAI provider
        let openAI = providers.first { $0.id == "openai" }
        XCTAssertNotNil(openAI, "OpenAI provider should exist")
        XCTAssertEqual(openAI?.displayName, "OpenAI")
        XCTAssertEqual(openAI?.baseURL, "https://api.openai.com/v1")
        XCTAssertTrue(openAI?.supportModels.contains("gpt-4") ?? false)
        
        // Check DeepSeek provider
        let deepSeek = providers.first { $0.id == "deepseek" }
        XCTAssertNotNil(deepSeek, "DeepSeek provider should exist")
        XCTAssertEqual(deepSeek?.displayName, "DeepSeek")
        XCTAssertEqual(deepSeek?.baseURL, "https://api.deepseek.com/v1")
    }
    
    func testModelConfigurationCreation() {
        let provider = ModelProvider.allProviders.first { $0.id == "openai" }!
        let configuration = ModelConfiguration(
            id: "test-config",
            providerId: provider.id,
            apiKey: "test-api-key",
            baseURL: provider.baseURL,
            selectedModel: "gpt-4",
            isActive: true,
            createdAt: Date(),
            lastUsed: Date()
        )
        
        XCTAssertEqual(configuration.providerId, "openai")
        XCTAssertEqual(configuration.apiKey, "test-api-key")
        XCTAssertEqual(configuration.baseURL, "https://api.openai.com/v1")
        XCTAssertEqual(configuration.selectedModel, "gpt-4")
        XCTAssertTrue(configuration.isActive)
        XCTAssertEqual(configuration.provider?.id, provider.id)
    }
    
    func testModelStorageManagerSaveAndLoad() {
        let provider = ModelProvider.allProviders.first { $0.id == "anthropic" }!
        let configuration = ModelConfiguration(
            id: "test-config-anthropic",
            providerId: provider.id,
            apiKey: "test-api-key-anthropic",
            baseURL: provider.baseURL,
            selectedModel: "claude-3-opus",
            isActive: true,
            createdAt: Date(),
            lastUsed: Date()
        )
        
        // Save configuration
        storageManager.saveConfiguration(configuration)
        
        // Load configurations
        let loadedConfigurations = storageManager.loadConfigurations()
        XCTAssertEqual(loadedConfigurations.count, 1, "Should have one configuration")
        
        let loadedConfig = loadedConfigurations.first!
        XCTAssertEqual(loadedConfig.id, configuration.id)
        XCTAssertEqual(loadedConfig.providerId, configuration.providerId)
        XCTAssertEqual(loadedConfig.selectedModel, configuration.selectedModel)
        XCTAssertEqual(loadedConfig.baseURL, configuration.baseURL)
        XCTAssertTrue(loadedConfig.isActive)
    }
    
    func testModelStorageManagerUpdate() {
        let provider = ModelProvider.allProviders.first { $0.id == "google" }!
        var configuration = ModelConfiguration(
            id: "test-config-google",
            providerId: provider.id,
            apiKey: "original-api-key",
            baseURL: provider.baseURL,
            selectedModel: "gemini-pro",
            isActive: true,
            createdAt: Date(),
            lastUsed: Date()
        )
        
        // Save original configuration
        storageManager.saveConfiguration(configuration)
        
        // Update configuration
        let updatedConfiguration = ModelConfiguration(
            id: configuration.id,
            providerId: configuration.providerId,
            apiKey: "updated-api-key",
            baseURL: "https://custom.api.url/v1",
            selectedModel: "gemini-pro-vision",
            isActive: false,
            createdAt: configuration.createdAt,
            lastUsed: Date()
        )
        
        storageManager.saveConfiguration(updatedConfiguration)
        
        // Verify update
        let loadedConfigurations = storageManager.loadConfigurations()
        XCTAssertEqual(loadedConfigurations.count, 1, "Should still have one configuration")
        
        let loadedConfig = loadedConfigurations.first!
        XCTAssertEqual(loadedConfig.apiKey, "updated-api-key")
        XCTAssertEqual(loadedConfig.baseURL, "https://custom.api.url/v1")
        XCTAssertEqual(loadedConfig.selectedModel, "gemini-pro-vision")
        XCTAssertFalse(loadedConfig.isActive)
    }
    
    func testModelStorageManagerDelete() {
        let provider = ModelProvider.allProviders.first { $0.id == "local" }!
        let configuration = ModelConfiguration(
            id: "test-config-local",
            providerId: provider.id,
            apiKey: "test-local-key",
            baseURL: provider.baseURL,
            selectedModel: "local-assistant",
            isActive: true,
            createdAt: Date(),
            lastUsed: Date()
        )
        
        // Save configuration
        storageManager.saveConfiguration(configuration)
        XCTAssertEqual(storageManager.loadConfigurations().count, 1)
        
        // Delete configuration
        storageManager.deleteConfiguration(withId: configuration.id)
        XCTAssertEqual(storageManager.loadConfigurations().count, 0)
    }
    
    func testUsageStatisticsCreation() {
        let stats = UsageStatistics(
            todayRequests: 50,
            monthlyRequests: 1500,
            monthlyLimit: 10000,
            averageResponseTime: 2.5,
            lastUpdated: Date()
        )
        
        XCTAssertEqual(stats.todayRequests, 50)
        XCTAssertEqual(stats.monthlyRequests, 1500)
        XCTAssertEqual(stats.monthlyLimit, 10000)
        XCTAssertEqual(stats.averageResponseTime, 2.5)
    }
}
