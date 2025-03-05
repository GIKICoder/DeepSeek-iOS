//
//  NetworkProvider.swift
//  AppInfra
//
//  Created by GIKI on 2025/1/11.
//

// NetworkProvider.swift
import Foundation
import Moya
import AppFoundation
import ReerCodable

public class NetworkProvider<T: TargetType> {
    
    private let provider: MoyaProvider<T>
    private let jsonDecoder: JSONDecoder
    private var cancellable: Cancellable?
    
    public init(provider: MoyaProvider<T> = MoyaProvider<T>(), jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.provider = provider
        self.jsonDecoder = jsonDecoder
    }
    
    public func cancel() {
        cancellable?.cancel()
    }
    
    // MARK: - Completion Handler 回调方式
    @discardableResult
    public func request<Model: Codable>(_ target: T,
                                        type: Model.Type,
                                        completion: @escaping (Result<Model, NetworkError>) -> Void) -> Cancellable {
        let cancellable = provider.request(target) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                do {
#if DEBUG
                    if let prettyString = response.data.prettyJSON {
                        logNetwork(prettyString)
                    }
#endif
                    let apiResponse = try self.jsonDecoder.decode(APIResponse<Model>.self, from: response.data)
                    if apiResponse.isSuccess {
                        if let data = apiResponse.data {
                            completion(.success(data))
                        } else {
                            // 如果 Model 是 VoidData，返回 ()
                            if Model.self == VoidData.self {
                                completion(.success(() as! Model))
                            } else {
                                completion(.failure(.noData))
                            }
                        }
                    } else {
                        completion(.failure(.apiError(code: apiResponse.code, message: apiResponse.message)))
                    }
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                completion(.failure(.underlying(error)))
            }
        }
        self.cancellable = cancellable
        return cancellable
    }
    
    // MARK: - Async/Await 回调方式
    @discardableResult
    public func requestAsync<Model: Codable & Sendable>(_ target: T) async throws -> Model {
        return try await withCheckedThrowingContinuation { continuation in
            cancellable = request(target, type: Model.self) { result in
                switch result {
                case .success(let model):
                    continuation.resume(returning: model)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - 请求 APIResponse 包装的模型（Completion Handler）
    @discardableResult
    public func requestWrapped<Model: Decodable & Sendable>(_ target: T,
                                                            type: Model.Type,
                                                            completion: @escaping (Result<APIResponse<Model>, NetworkError>) -> Void) -> Cancellable {
        return provider.request(target) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                do {
                    let apiResponse = try self.jsonDecoder.decode(APIResponse<Model>.self, from: response.data)
                    if apiResponse.isSuccess {
                        completion(.success(apiResponse))
                    } else {
                        completion(.failure(.apiError(code: apiResponse.code, message: apiResponse.message)))
                    }
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                completion(.failure(.underlying(error)))
            }
        }
    }
    
    // MARK: - 请求 APIResponse 包装的模型（Async/Await）
    @discardableResult
    public func requestWrappedAsync<Model: Decodable & Sendable>(_ target: T) async -> (response: APIResponse<Model>?, error: NetworkError?) {
        await withCheckedContinuation { continuation in
            cancellable = requestWrapped(target, type: Model.self) { result in
                switch result {
                case .success(let apiResponse):
                    continuation.resume(returning: (apiResponse, nil))
                case .failure(let error):
                    continuation.resume(returning: (nil, error))
                }
            }
        }
    }
}

// MARK: - Network + Raw
extension NetworkProvider {
    /// 发送请求并返回原始响应数据
    /// - Parameters:
    ///   - target: 网络请求目标
    ///   - progress: 进度回调
    ///   - completion: 完成回调，返回原始Response和可选的解析后的JSON数据
    @discardableResult
    public func requestRaw(_ target: T,
                           progress: ProgressBlock? = nil,
                           completion: @escaping (Result<(response: Response, json: Any?), NetworkError>) -> Void) -> Cancellable {
        return provider.request(target, progress: progress) { result in
            switch result {
            case .success(let response):
#if DEBUG
                if let prettyString = response.data.prettyJSON {
                    logNetwork(prettyString)
                }
#endif
                
                // 尝试解析JSON，但不强制
                var jsonObject: Any? = nil
                if let json = try? JSONSerialization.jsonObject(with: response.data) {
                    jsonObject = json
                }
                
                completion(.success((response, jsonObject)))
                
            case .failure(let error):
                completion(.failure(.underlying(error)))
            }
        }
    }
    
    /// 异步发送请求并返回原始响应数据
    /// - Parameters:
    ///   - target: 网络请求目标
    ///   - progress: 进度回调
    /// - Returns: 包含原始Response和可选JSON数据的元组
    @discardableResult
    public func requestRawAsync(_ target: T,
                                progress: ProgressBlock? = nil) async throws -> (response: Response, json: Any?) {
        try await withCheckedThrowingContinuation { continuation in
            cancellable = provider.request(target, progress: progress) { result in
                switch result {
                case .success(let response):
#if DEBUG
                    if let prettyString = response.data.prettyJSON {
                        logNetwork(prettyString)
                    }
#endif
                    
                    var jsonObject: Any? = nil
                    if let json = try? JSONSerialization.jsonObject(with: response.data) {
                        jsonObject = json
                    }
                    
                    continuation.resume(returning: (response, jsonObject))
                    
                case .failure(let error):
                    continuation.resume(throwing: NetworkError.underlying(error))
                }
            }
        }
    }
    
    /**
     // 使用 requestRaw
     provider.requestRaw(target, progress: { progress in
     print("Progress: \(progress.progress)")
     }) { result in
     // 处理结果
     }
     
     // 使用 requestRawAsync
     try await provider.requestRawAsync(target) { progress in
     print("Progress: \(progress.progress)")
     }
     */
}
