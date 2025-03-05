//
//  File.swift
//  AppComponents
//
//  Created by GIKI on 2025/2/21.
//

import Foundation
import UIKit
import Network
import AppFoundation

/// 配置管理器，负责调度和管理配置更新
public class ConfigManager: NSObject {
    
    // MARK: - 属性
    
    /// 组合配置处理器，聚合多个 ConfigHandler
    fileprivate let compositeHandler: CompositeConfigHandler
    
    /// 上次更新时间，用于冷却期判断
    private var lastUpdateTime: Date?
    
    /// 前台定时更新的时间间隔
    private var updateInterval: TimeInterval {
        didSet {
            if isForeground {
                restartTimer()
            }
        }
    }
    
    /// 冷却期，限制更新频率
    private var cooldownPeriod: TimeInterval
    
    /// 前台状态标记
    private var isForeground: Bool = true
    
    /// 定时器，用于前台定时更新
    private var timer: Timer?
    
    /// 网络状态监测器
    private var pathMonitor: NWPathMonitor?
    
    /// 网络状态队列
    private let networkQueue = DispatchQueue(label: "NetworkMonitor")
    
    /// 标识是否需要在网络恢复后进行配置更新
    private var needsUpdateOnNetworkRecovery: Bool = false
    
    // MARK: - 初始化
    
    /// 初始化配置管理器
    /// - Parameters:
    ///   - updateInterval: 前台定时更新的间隔时间，默认1小时
    ///   - cooldownPeriod: 更新冷却期，默认10分钟
    ///   - handler: 初始的组合配置处理器
    public init(updateInterval: TimeInterval = 3600,
                cooldownPeriod: TimeInterval = 600,
                handler: CompositeConfigHandler) {
        self.updateInterval = updateInterval
        self.cooldownPeriod = cooldownPeriod
        self.compositeHandler = handler
        super.init()
        setupNotifications()
        setupNetworkMonitor()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopUpdating()
        stopNetworkMonitor()
    }
    
    // MARK: - 通知设置
    
    /// 设置应用状态通知监听
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    @objc private func appDidEnterBackground() {
        isForeground = false
        stopUpdating()
        // 可根据需要在切换到后台时触发更新原因，例如：
        // 这里使用 .foreground 作为示例原因
        do {
            try forceUpdate(reason: .background)
        } catch {
            logInfo("后台切换时配置更新失败: \(error)")
        }
    }
    
    @objc private func appWillEnterForeground() {
        isForeground = true
        startTimer()
        // 进入前台时立即检查更新，传递 .foreground 作为原因
        do {
            try forceUpdate(reason: .foreground)
        } catch {
            logInfo("前台切换时配置更新失败: \(error)")
        }
    }
    
    // MARK: - 网络监测设置
    
    /// 设置网络状态监测
    private func setupNetworkMonitor() {
        pathMonitor = NWPathMonitor()
        pathMonitor?.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            if path.status == .satisfied {
                logInfo("网络连接恢复")
                if self.needsUpdateOnNetworkRecovery {
                    do {
                        try self.forceUpdate(reason: .networkRecovery)
                        self.needsUpdateOnNetworkRecovery = false
                    } catch {
                        logInfo("网络恢复时配置更新失败: \(error)")
                    }
                }
            } else {
                logInfo("网络连接不可用")
            }
        }
        pathMonitor?.start(queue: networkQueue)
    }
    
    /// 停止网络状态监测
    private func stopNetworkMonitor() {
        pathMonitor?.cancel()
        pathMonitor = nil
    }
    
    // MARK: - 更新控制
    
    /// 启动更新调度
    public func startUpdating() {
        if isForeground {
            startTimer()
            // 可选择在启动时触发一次定时更新，传递 .timer 作为原因
            do {
                try forceUpdate(reason: .timer)
            } catch {
                logInfo("启动时配置更新失败: \(error)")
            }
        }
    }
    
    /// 停止更新调度
    public func stopUpdating() {
        timer?.invalidate()
        timer = nil
    }
    
    /// 启动定时器
    private func startTimer() {
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: self.updateInterval, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                do {
                    try self.forceUpdate(reason: .timer)
                } catch {
                    logInfo("定时更新失败: \(error)")
                }
            }
        }
    }
    
    /// 重新启动定时器，用于更新时间间隔后
    private func restartTimer() {
        stopUpdating()
        startTimer()
    }
    
    /// 强制更新配置，带有更新原因
    /// - Parameter reason: 更新触发原因
    public func forceUpdate(reason: UpdateReason) throws {
        
        // 如果原因是登录或网络恢复，则不进行冷却期的判断
        if reason != .force
            && reason != .login
            && reason != .networkRecovery {
            guard shouldUpdate() else {
                logInfo("处于冷却期，不进行更新")
                return
            }
        }
        
        // 检查网络状态
        if !isNetworkAvailable() {
            logInfo("网络不可用，无法更新配置")
            // 如果是首次启动且配置未获取，则标记需要在网络恢复后更新
            if compositeHandler.currentConfiguration == nil {
                needsUpdateOnNetworkRecovery = true
            }
            return
        }
        
        do {
            try compositeHandler.update(reason: reason)
            lastUpdateTime = Date()
            logInfo("配置更新成功，原因: \(reason)")
        } catch {
            logInfo("配置更新失败, 原因: \(reason), 错误: \(error)")
            // 如果更新失败且是由于网络问题，可以标记需要在网络恢复后重试
            if isNetworkError(error) && compositeHandler.currentConfiguration == nil {
                needsUpdateOnNetworkRecovery = true
            }
            throw error
        }
    }
    
    /// 用户登录后触发更新
    public func updateOnLogin() throws {
        try forceUpdate(reason: .login)
    }
    
    /// 判断是否应该进行更新
    /// - Returns: 是否应该更新
    private func shouldUpdate() -> Bool {
        guard let lastUpdate = lastUpdateTime else {
            return true
        }
        return Date().timeIntervalSince(lastUpdate) >= cooldownPeriod
    }
    
    /// 获取当前配置
    /// - Returns: 组合配置处理器的配置
    public func getConfiguration() -> Void? {
        return compositeHandler.currentConfiguration
    }
    
    // MARK: - 后台获取
    
    /// 供应用代理调用的后台获取配置方法
    /// - Parameter completion: 完成回调
    public func performBackgroundFetch(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        DispatchQueue.global().async {
            do {
                if self.shouldUpdate() {
                    if self.isNetworkAvailable() {
                        try self.compositeHandler.update(reason: .timer) // 后台获取使用定时更新原因
                        self.lastUpdateTime = Date()
                        logInfo("后台配置更新成功")
                        completion(.newData)
                    } else {
                        logInfo("后台配置更新失败，网络不可用")
                        completion(.failed)
                    }
                } else {
                    logInfo("处于冷却期，后台不进行更新")
                    completion(.noData)
                }
            } catch {
                logInfo("后台配置更新失败: \(error)")
                completion(.failed)
            }
        }
    }
    
    // MARK: - 网络状态辅助方法
    
    /// 检查当前网络是否可用
    /// - Returns: 网络是否可用
    private func isNetworkAvailable() -> Bool {
        guard let path = pathMonitor?.currentPath else { return false }
        return path.status == .satisfied
    }
    
    /// 判断错误是否与网络相关
    /// - Parameter error: 错误对象
    /// - Returns: 是否为网络错误
    private func isNetworkError(_ error: Error) -> Bool {
        let nsError = error as NSError
        let networkErrorCodes = [NSURLErrorNotConnectedToInternet,
                                 NSURLErrorTimedOut,
                                 NSURLErrorCannotFindHost,
                                 NSURLErrorCannotConnectToHost]
        return networkErrorCodes.contains(nsError.code)
    }
    
    // MARK: - Handler 管理
    
    /// 添加一个 ConfigHandler
    /// - Parameter handler: 要添加的处理器
    public func addHandler<H: ConfigHandler>(_ handler: H) {
        compositeHandler.addHandler(handler)
    }
    
    /// 移除一个 ConfigHandler
    /// - Parameter handler: 要移除的处理器
    public func removeHandler<H: ConfigHandler>(_ handler: H) {
        compositeHandler.removeHandler(handler)
    }
}
