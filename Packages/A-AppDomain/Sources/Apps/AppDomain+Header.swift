//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/2/20.
//

import Foundation
import AppInfra
import AppFoundation
import UIKit
import AppComponents
import AppServices

extension AppDomain {

    func setupNetworkConfiguration() {
        NetworkClient.shared.registerHeaderProvider(AuthTokenProvider())
        NetworkClient.shared.registerHeaderProvider(CommonHeaderProvider())
        setupNetworkMonitor()
    }
    
}


class AuthTokenProvider: NetworkClient.HeaderProvider {
    func provideHeaders() -> [String: String] {
        var headers: [String: String] = [:]
        if let activeDeepseek = ModelStorageManager.shared.activeConfig(for: .deepseek) {
            headers["Authorization"] = "Bearer \(activeDeepseek.apiKey)"
            logDebug("Authorization: \(activeDeepseek.apiKey)")
        }
        return headers
    }
}


class CommonHeaderProvider: NetworkClient.HeaderProvider {
    func provideHeaders() -> [String: String] {
        var headers: [String: String] = [:]
        headers["Content-Type"] = "application/json"
        headers["h_ver"] = AppF.appVersion
        let systemVersion = UIDevice.current.systemVersion
        headers["h_os"] = systemVersion
        headers["h_did"] = AppDeviceService.shared.DEVICE_ID
        headers["h_idfa"] = AppDeviceService.shared.IDFA
        headers["h_idfv"] = AppDeviceService.shared.IDFV
        headers["h_language"] = Locale.current.languageCode
        return headers
    }
}


extension AppDomain {
    
    func setupNetworkMonitor() {
        NetworkMonitor.shared.onRequestCompleted = { metrics in
            logDebug("\(metrics)")

        }

        NetworkMonitor.shared.onErrorOccurred = { error in
            logError(error)
        }
    }
    
}
