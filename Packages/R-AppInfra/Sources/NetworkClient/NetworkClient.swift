//
//  NetworkClient.swift
//  AppInfra
//
//  Created by GIKI on 2025/1/11.
//

public final class NetworkClient {
    
    // MARK: - Types
    
    /// Header Provider
    public protocol HeaderProvider: AnyObject {
            /// 动态提供 headers
        func provideHeaders() -> [String: String]
    }
    
    // MARK: - Singleton
    
    public static let shared = NetworkClient()
    private init() {}
    
    // MARK: - Properties
    
    public var currentBaseURL: String {
        get {
            AppEnvironment.BaseUrl()
        }
    }
    /// 静态自定义 headers
    private var staticHeaders: [String: String] = [:]

    /// 动态 header 提供器数组
    private var headerProviders: [HeaderProvider] = []
    
    // MARK: - Public Methods
    
    /// 注册 header 提供器
    public func registerHeaderProvider(_ provider: HeaderProvider) {
        headerProviders.append(provider)
    }
    
    /// 移除 header 提供器
    public func removeHeaderProvider(_ provider: HeaderProvider) {
        headerProviders.removeAll(where: { $0 === (provider as AnyObject) })
    }
    
    /// 添加静态 header
    public func addStaticHeader(key: String, value: String) {
        staticHeaders[key] = value
    }
    
    /// 移除静态 header
    public func removeStaticHeader(forKey key: String) {
        staticHeaders.removeValue(forKey: key)
    }
    
    /// 获取完整的 headers
    public func getHeaders() -> [String: String] {
        var headers = staticHeaders
        
        // 添加基础 headers
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
    
        // 获取所有动态 header 提供器的 headers
        headerProviders.forEach { provider in
            let dynamicHeaders = provider.provideHeaders()
            headers.merge(dynamicHeaders) { _, new in new }
        }
        
        return headers
    }
}
