//
//  NetworkMonitor.swift
//  R-AppInfra
//
//  Created by GIKI on 2025/4/11.
//


import Foundation
import Moya
import ReerCodable

// 网络请求监控数据模型
public struct NetworkMetrics {
    public let requestKind: String = "https"
    public let requestMethod: String
    public let requestURL: String
    public let responseSize: Int
    public let responseStartTime: TimeInterval
    public let responseStatusCode: Int
    public let startTime: TimeInterval
    public let stopTime: TimeInterval
    public let error: Error?
    
    public var duration: TimeInterval {
        return stopTime - startTime
    }
    
    public init(
        requestMethod: String,
        requestURL: String,
        responseSize: Int,
        responseStartTime: TimeInterval,
        responseStatusCode: Int,
        startTime: TimeInterval,
        stopTime: TimeInterval,
        error: Error?
    ) {
        self.requestMethod = requestMethod
        self.requestURL = requestURL
        self.responseSize = responseSize
        self.responseStartTime = responseStartTime
        self.responseStatusCode = responseStatusCode
        self.startTime = startTime
        self.stopTime = stopTime
        self.error = error
    }
}

extension NetworkMetrics {
    public func toJSON() -> [String: Any] {
        var json: [String: Any] = [
            "requestKind": requestKind,
            "requestMethod": requestMethod,
            "requestURL": requestURL,
            "responseSize": responseSize,
            "responseStartTime": responseStartTime,
            "responseStatusCode": responseStatusCode,
            "startTime": startTime,
            "stopTime": stopTime,
            "duration": duration
        ]
        
        // 处理可选类型的error
        if let error = error {
            json["error"] = error.localizedDescription
        }
        
        return json
    }
}

// 网络监控
public class NetworkMonitor {
    public static let shared = NetworkMonitor()
    private init() {}
    
    private let queue = DispatchQueue(label: "com.networkmonitor.queue")
    
    // 监控回调
    public var onRequestCompleted: ((NetworkMetrics) -> Void)?
    public var onErrorOccurred: ((Error) -> Void)?
    
    // 记录网络请求数据
    public func record(_ metrics: NetworkMetrics) {
        queue.async {
            self.onRequestCompleted?(metrics)
        }
    }
    
    // 记录错误
    public func recordError(_ error: Error) {
        queue.async {
            self.onErrorOccurred?(error)
        }
    }
}

@Codable
struct MonitorResponse: Codable {
    let code: Int
    let message: String
}

// 网络监控插件
public class NetworkMonitorPlugin: PluginType {
    private var requestStartTime: TimeInterval = 0
    
    public init() {}
    
    public func willSend(_ request: RequestType, target: TargetType) {
        requestStartTime = Date().timeIntervalSince1970
    }


    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        let stopTime = Date().timeIntervalSince1970
        
        switch result {
        case .success(let response):
            do {
                // 解析 response.data
                let apiResponse = try JSONDecoder().decode(MonitorResponse.self, from: response.data)
                
                // 检查状态码，如果不是 200 则视为错误
                if apiResponse.code != 200 {
                    let error = NSError(
                        domain: "APIError",
                        code: apiResponse.code,
                        userInfo: [NSLocalizedDescriptionKey: apiResponse.message]
                    )
                    
                    let metrics = NetworkMetrics(
                        requestMethod: response.request?.method?.rawValue ?? "UNKNOWN",
                        requestURL: response.request?.url?.absoluteString ?? "",
                        responseSize: response.data.count,
                        responseStartTime: stopTime - 1,
                        responseStatusCode: apiResponse.code,
                        startTime: requestStartTime,
                        stopTime: stopTime,
                        error: error
                    )
                    NetworkMonitor.shared.record(metrics)
                    NetworkMonitor.shared.recordError(error)
                    return
                }
                
                // 成功情况下的处理
                let metrics = NetworkMetrics(
                    requestMethod: response.request?.method?.rawValue ?? "UNKNOWN",
                    requestURL: response.request?.url?.absoluteString ?? "",
                    responseSize: response.data.count,
                    responseStartTime: stopTime - 1,
                    responseStatusCode: response.statusCode,
                    startTime: requestStartTime,
                    stopTime: stopTime,
                    error: nil
                )
                NetworkMonitor.shared.record(metrics)
                
            } catch {
                // JSON 解析错误处理
                let metrics = NetworkMetrics(
                    requestMethod: response.request?.method?.rawValue ?? "UNKNOWN",
                    requestURL: response.request?.url?.absoluteString ?? "",
                    responseSize: response.data.count,
                    responseStartTime: stopTime - 1,
                    responseStatusCode: response.statusCode,
                    startTime: requestStartTime,
                    stopTime: stopTime,
                    error: error
                )
                NetworkMonitor.shared.record(metrics)
                NetworkMonitor.shared.recordError(error)
            }
            
        case .failure(let error):
            let metrics = NetworkMetrics(
                requestMethod: target.method.rawValue,
                requestURL: target.baseURL.appendingPathComponent(target.path).absoluteString,
                responseSize: 0,
                responseStartTime: stopTime,
                responseStatusCode: 0,
                startTime: requestStartTime,
                stopTime: stopTime,
                error: error
            )
            NetworkMonitor.shared.record(metrics)
            NetworkMonitor.shared.recordError(error)
        }
    }
}
