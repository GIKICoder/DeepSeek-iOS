//
//  StorageService.swift
//  AppInfra
//
//  Created by GIKI on 2025/1/13.
//

// StoreService.swift
import Foundation
import Cache
import AppFoundation

// 为 StorageService 定义别名
public typealias AppCache = StorageService


public class StorageService {
    
    public static let shared = StorageService()
    
    public let standard = UserDefaults.standard
    public var storage: Storage<String, Data>?
    
    private init() {
        
        let cacheName = AppFoundation.appBundleID+".app.cache"
        let diskConfig = DiskConfig(
            name: cacheName,
            expiry: .date(Date().addingTimeInterval(3600 * 24 * 30)),
            maxSize: 500 * 1024 * 1024,
            directory: try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                    appropriateFor: nil, create: true).appendingPathComponent("appPreferences"),
            protectionType: .complete
        )
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 100, totalCostLimit: 0)
        storage = try? Storage(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            fileManager: FileManager.default,
            transformer: TransformerFactory.forData()
        )
    }
}


extension StorageService {
    public static var storage: Storage<String, Data>? {
        self.shared.storage
    }
    
    public static var standard: UserDefaults {
        self.shared.standard
    }
}

extension StorageService {
    // 获取指定类型的 storage
    public static func storage<T: Codable>(ofType type: T.Type) -> Storage<String, T>? {
        return storage?.transformCodable(ofType: type)
    }
    
    public static func setObject<T: Codable>(_ object: T, forKey key: String, completion: @escaping (Result<(), Error>) -> Void) {
        do {
            let data = try JSONEncoder().encode(object)
            storage?.async.setObject(data, forKey: key, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    public static func object<T: Codable>(forKey key: String, completion: @escaping (Result<T, Error>) -> Void) {
        storage?.async.object(forKey: key) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let object = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(object))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    
    // 检查对象是否存在
    public static func objectExists(forKey key: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        storage?.async.objectExists(forKey: key, completion: completion)
    }
    
    public static func removeObject(forKey key: String, completion: @escaping (Result<(), Error>) -> Void) {
        storage?.async.removeObject(forKey: key, completion: completion)
    }
}

extension StorageService {
    // 存储对象
    public static func setObject<T: Codable>(_ object: T, forKey key: String) async throws {
        let data = try JSONEncoder().encode(object)
        try await storage?.async.setObject(data, forKey: key)
    }
    
    // 获取对象
    public static func object<T: Codable>(forKey key: String) async throws -> T {
        guard let data = try await storage?.async.object(forKey: key) else {
            throw StorageError.notFound
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    // 检查对象是否存在
    public static func objectExists(forKey key: String) async throws -> Bool {
        try await storage?.async.objectExists(forKey: key) ?? false
    }
    
    // 删除指定对象
    public static func removeObject(forKey key: String) async throws {
        try await storage?.async.removeObject(forKey: key)
    }
}
