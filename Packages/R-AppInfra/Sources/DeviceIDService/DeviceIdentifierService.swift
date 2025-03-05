//
//  DeviceIdentifierService.swift
//  AppInfra
//
//  Created by GIKI on 2025/1/13.
//

import Foundation
import KeychainAccess
import AppFoundation
import AdSupport
import AppTrackingTransparency
import UIKit

public typealias AppDeviceService = DeviceIdentifierService

public final class DeviceIdentifierService: Sendable {
    
    public static var shared = DeviceIdentifierService()
    
    // 添加静态属性来存储配置
    private static var configuredKeychain: Keychain?
    private static var configuredDeviceIdCacheKey: String?
    
    // 添加静态配置方法
    public static func configure(keychain: Keychain?, deviceIdCacheKey: String?) {
        configuredKeychain = keychain
        configuredDeviceIdCacheKey = deviceIdCacheKey
    }
    
    private var device_idfa: String?
    
    private var deviceId: String!
    
    private let deviceIdCacheKey: String
    private let keychain: Keychain?
    private let loggerCategory = "DeviceIdentifierService"
    private let idfaSaveKey = "app.device.idfa"
    
    
    private init() {
        // 在初始化时使用静态配置的值
        self.keychain = DeviceIdentifierService.configuredKeychain
        self.deviceIdCacheKey = DeviceIdentifierService.configuredDeviceIdCacheKey ?? "\(AppFoundation.appBuildVersion).deviceid.cache.key"
        
        logDebug("[DeviceIdentifierService] Initialized with keychain: \(keychain != nil ? "enabled" : "disabled")", category: loggerCategory)
        loadDeviceIDFA()
        loadDeviceIdIfNoneCreateOne()
    }
    
    public var IDFA: String? {
        device_idfa
    }
    
    public var IDFV: String {
        UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    
    public var DEVICE_ID: String {
        deviceId
    }
    
    func loadDeviceIDFA() {
        // 1. 先从 UserDefaults 获取
        if let hidfaFromUserDefaults = UserDefaults.standard.string(forKey: idfaSaveKey) {
            device_idfa = hidfaFromUserDefaults
            logDebug("[DeviceIdentifierService] hidfa loaded from UserDefaults: \(hidfaFromUserDefaults)", category: loggerCategory)
            
            // 如果开启了 Keychain，确保同步到 Keychain
            if let keychain = keychain {
                if (try? keychain.getString(idfaSaveKey)) == nil {
                    do {
                        try keychain.set(hidfaFromUserDefaults, key: idfaSaveKey)
                        logDebug("[DeviceIdentifierService] Synced hidfa to keychain: \(hidfaFromUserDefaults)", category: loggerCategory)
                    } catch {
                        logError("[DeviceIdentifierService] Failed to sync hidfa to keychain: \(error)", category: loggerCategory)
                    }
                }
            }
            return
        }
        
        // 2. 如果 UserDefaults 没有，且启用了 Keychain，尝试从 Keychain 获取
        if let keychain = keychain {
            do {
                if let hidfaFromKeychain = try keychain.getString(idfaSaveKey) {
                    device_idfa = hidfaFromKeychain
                    // 同步到 UserDefaults
                    UserDefaults.standard.set(hidfaFromKeychain, forKey: idfaSaveKey)
                    logDebug("[DeviceIdentifierService] hidfa loaded from Keychain and synced to UserDefaults: \(hidfaFromKeychain)", category: loggerCategory)
                }
            } catch {
                logError("[DeviceIdentifierService] hidfa get failed from keychain: \(error)", category: loggerCategory)
            }
        } else {
            logDebug("[DeviceIdentifierService] Keychain disabled, skip loading hidfa", category: loggerCategory)
        }
    }

    func saveDeviceIDFA(value: String) {
        // 1. 保存到 UserDefaults
        UserDefaults.standard.set(value, forKey: idfaSaveKey)
        device_idfa = value
        logDebug("[DeviceIdentifierService] hidfa saved to UserDefaults: \(value)", category: loggerCategory)
        
        // 2. 如果启用了 Keychain，也保存到 Keychain
        if let keychain = keychain {
            do {
                try keychain.set(value, key: idfaSaveKey)
                logDebug("[DeviceIdentifierService] hidfa saved to Keychain: \(value)", category: loggerCategory)
            } catch {
                logError("[DeviceIdentifierService] hidfa save to keychain failed: \(error)", category: loggerCategory)
            }
        } else {
            logDebug("[DeviceIdentifierService] Keychain disabled, skip saving hidfa to keychain", category: loggerCategory)
        }
    }
    
    @discardableResult
    func loadDeviceIdIfNoneCreateOne() -> String {
        // 1. 从 UserDefaults 获取
        if let didFromUserDefaults = getDidFromUserDefaults {
            logDebug("[DeviceIdentifierService] Found deviceId in UserDefaults: \(didFromUserDefaults)")
            
            // 如果开启了 Keychain，则同步到 Keychain
            if let keychain = keychain {
                if (try? keychain.getString(deviceIdCacheKey)) != nil {
                    deviceId = didFromUserDefaults
                    return didFromUserDefaults
                } else {
                    do {
                        try keychain.set(didFromUserDefaults, key: deviceIdCacheKey)
                        logDebug("[DeviceIdentifierService] Synced deviceId to keychain: \(didFromUserDefaults)")
                    } catch {
                        logError("[DeviceIdentifierService] Failed to sync deviceId to keychain: \(error)")
                    }
                }
            }
            
            deviceId = didFromUserDefaults
            return didFromUserDefaults
        }
        
        // 2. 如果开启了 Keychain，尝试从 Keychain 获取
        if let keychain = keychain,
           let didFromKeychain = try? keychain.getString(deviceIdCacheKey) {
            logDebug("[DeviceIdentifierService] Found deviceId in Keychain: \(didFromKeychain)")
            UserDefaults.standard.set(didFromKeychain, forKey: deviceIdCacheKey)
            deviceId = didFromKeychain
            return didFromKeychain
        }
        
        // 3. 都没有，生成新的 UUID
        let uuid = IDFV.sha256
        logDebug("[DeviceIdentifierService] Generated new deviceId: \(uuid)")
        
        // 4. 写入 UserDefaults
        UserDefaults.standard.set(uuid, forKey: deviceIdCacheKey)
        
        // 5. 如果开启了 Keychain，同时写入 Keychain
        if let keychain = keychain {
            do {
                try keychain.set(uuid, key: deviceIdCacheKey)
                logDebug("[DeviceIdentifierService] Saved new deviceId to keychain: \(uuid)")
            } catch {
                logError("[DeviceIdentifierService] Failed to save new deviceId to keychain: \(error)")
            }
        }
        
        deviceId = uuid
        return uuid
    }
    
    var getDidFromUserDefaults: String? {
        UserDefaults.standard.string(forKey: deviceIdCacheKey)
    }
}

// MARK: - Tracking Authorization
extension DeviceIdentifierService {
    
    public func requestTrackingAuthorization() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                if status == .authorized {
                    self.saveDeviceIDFA(value: ASIdentifierManager.shared().advertisingIdentifier.uuidString)
                }
                logInfo("[DeviceIdentifierService] ATTrackingManager status: \(status)")
            }
        } else {
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                saveDeviceIDFA(value: ASIdentifierManager.shared().advertisingIdentifier.uuidString)
            }
        }
    }
}
