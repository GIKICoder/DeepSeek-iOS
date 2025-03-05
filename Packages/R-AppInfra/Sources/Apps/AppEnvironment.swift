//
//  File.swift
//  AppInfra
//
//  Created by GIKI on 2025/1/14.
//

import Foundation


enum Environment: Int {
    case production = 1
    case boe
    case gray
    case doc
}

enum Constants {
    static let serverKey = "app.server.environment"
}

public enum AppEnvironment {
    
    public static func urlWithPath(_ path: String) -> String {
        // 获取基础 URL
        let baseUrl = serverEnvironment.baseURL
        
        // 确保路径以斜杠开头，并移除可能存在的多余斜杠
        let sanitizedPath = path.hasPrefix("/") ? path : "/" + path
        
        // 构建完整 URL
        return baseUrl + sanitizedPath
    }
    
    public static func BaseUrl() -> String {
        
        return serverEnvironment.baseURL
    }
    
    public static var serverEnvironment: ServerEnvironment {
        get {
            if !AppEnvironment.isTestFlight, !AppEnvironment.isDebug {
                return .production
            }
            if let value = UserDefaults.standard.string(forKey: Constants.serverKey) {
                return ServerEnvironment(rawValue: value) ?? .production
            } else {
                return .production
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Constants.serverKey)
        }
    }
    
    public static var isStaging: Bool {
#if DEBUG
        //
        return serverEnvironment != .production
#else
        return false
#endif
    }
    
    public static var isProduction: Bool {
#if DEBUG
        return serverEnvironment == .production
#else
        return false
#endif
    }
    
    public static var isSimulator: Bool {
#if targetEnvironment(simulator)
        return true
#else
        return false
#endif
    }
    
    public static var isDevice: Bool {
        !isSimulator
    }
    
    public static var isTestFlight: Bool {
        let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        return isTestFlight
        
#if TEST_FLIGHT
        return true
#endif
        return false
        
    }
    
    public static var isDebug: Bool {
#if DEBUG
        return true
#else
        return false
#endif
    }
    
    public static var isMainApp: Bool {
        Bundle.main.bundlePath.hasSuffix(".app")
    }
    
    public static var isExtension: Bool {
        Bundle.main.bundlePath.hasSuffix(".appex")
    }
    
    public static var isAppClip: Bool {
        Bundle.main.bundlePath.hasSuffix(".appclip")
    }
    
    public static var isApp: Bool {
        isMainApp || isExtension || isAppClip
    }
    
    public static var isTesting: Bool {
        AppEnvironment.isDebug || AppEnvironment.isTestFlight
    }
    
    public static func envValue(for key: String) -> String? {
        if let value = Bundle.main.infoDictionary?[key] as? String {
            return value
        }
        return nil
    }
}

public enum ServerEnvironment: String, CaseIterable {
    case boe
    case gray
    case doc
    case production
    
    // 从 Info.plist 获取 URL，如果获取失败则使用默认值
    var baseURL: String {
        let bundle = Bundle.main
        let defaultBaseURL = "https://www.example.com"
        
        switch self {
        case .boe:
            if let url = bundle.infoDictionary?["API_BASE_URL_BOE"] as? String {
                return "https://" + url
            }
            return defaultBaseURL + "/boe"
            
        case .gray:
            if let url = bundle.infoDictionary?["API_BASE_URL_GRAY"] as? String {
                return "https://" + url
            }
            return defaultBaseURL + "/gray"
            
        case .doc:
            if let url = bundle.infoDictionary?["API_BASE_URL_DOC"] as? String {
                return "https://" + url
            }
            return defaultBaseURL + "/doc"
            
        case .production:
            if let url = bundle.infoDictionary?["API_BASE_URL_PRODUCTION"] as? String {
                return "https://" + url
            }
            return defaultBaseURL + "/production"
        }
    }
    
    // 显示名称
    public var showName: String {
        switch self {
        case .boe:
            return "测试环境: " + self.baseURL
        case .production:
            return "线上环境: " + self.baseURL
        case .gray:
            return "灰度环境: " + self.baseURL
        case .doc:
            return "文档测试环境: " + self.baseURL
        }
    }
}
