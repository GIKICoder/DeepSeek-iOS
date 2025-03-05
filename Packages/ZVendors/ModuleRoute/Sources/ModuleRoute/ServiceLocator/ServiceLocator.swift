import Foundation

/// A service locator that manages dependency injection for an application
public class ServiceLocator {
    static var enableLogging: Bool = false
    
    /// Stores factories for eagerly created singletons
    private var singletonFactories: [DependencyWithKey] = []
    /// Stores already created singleton instances
    private var singletons: [String: Any] = [:]
    /// Stores factories for non-singleton dependencies
    private var factories: [String: () -> Any] = [:]
    
    /// Lock for thread-safe access to factories
    private let factoryLock = NSRecursiveLock()
    /// Lock for thread-safe access to singletons
    private let singleLock = NSRecursiveLock()
    /// Lock for thread-safe module registration
    private var moduleLock = NSRecursiveLock()
    
    /// Registers a factory closure that will be used to create an instance of a service.
    /// - Parameters:
    ///   - type: The type of the service to register.
    ///   - factory: A closure that returns an instance of the service.
    internal func factory<T>(_ type: T.Type = T.self, _ factory: @escaping () -> T) {
        let key = String(describing: type)
        factoryLock.lock()
        defer { factoryLock.unlock() }
        
        guard factories[key] == nil else {
            fatalError("[factory] Factory for \(key) already exists.")
        }
        
        factories[key] = factory
    }
    
    /// Registers a singleton factory closure that will be used to create and cache an instance of a service.
    /// - Parameters:
    ///   - type: The type of the singleton service to register.
    ///   - factory: A closure that creates and returns a single instance of the service.
    public func single<T>(_ type: T.Type = T.self, _ factory: @escaping () -> T) {
        let key = String(describing: type)
        singleLock.lock()
        defer { singleLock.unlock() }
        guard singletons[key] == nil else {
            fatalError("[single] Factory for \(key) already exists.")
        }
        singletonFactories.append(DependencyWithKey(key: key, factory: factory))
    }
    
    /// Resolves and returns an instance of the specified type.
    /// - Parameters:
    ///   - file: The file where the resolution is requested (default: current file)
    ///   - fileId: The file ID where the resolution is requested (default: current file ID)
    ///   - function: The function where the resolution is requested (default: current function)
    ///   - line: The line number where the resolution is requested (default: current line)
    /// - Returns: An instance of the specified type
    /// - Throws: `ResolutionError` if the dependency cannot be resolved
    public func resolve<T>(_ file: String = #file, _ fileId: String = #fileID, _ function: String = #function, _ line: Int = #line) throws -> T {
        let key = String(describing: T.self)
        Self.log("[\(file)][resolve] \(key) by \(fileId)#\(function):\(line)")
        
        if let singletonInstance = singletons[key] as? T {
            return singletonInstance
        } else if let factoryInstance = factories[key]?() as? T {
            return factoryInstance
        } else {
            throw ResolutionError(message: "No registered factory for \(key)")
        }
    }
    
    /// Registers a module with the service locator
    /// - Parameter closure: A closure that returns a `ServiceLocatorModule`
    internal func module(_ closure: @escaping () -> ServiceLocatorModule) {
        moduleLock.lock()
        defer { moduleLock.unlock() }
        closure().buildInternal(locator: self)
    }
    
    /// Builds all eagerly loaded singletons
    /// - Parameter file: The file where the build is initiated (default: current file)
    @MainActor
    public func build(_ file: String = #file) async {
        let filename = file
        for dependency in singletonFactories {
            Self.log("[\(filename)][build] \(dependency.key)")
            singletons[dependency.key] = dependency.factory()
        }
    }
    
    /// Resets the ServiceLocator to its initial state
    public func reset() {
        factoryLock.lock()
        singleLock.lock()
        moduleLock.lock()
        defer {
            factoryLock.unlock()
            singleLock.unlock()
            moduleLock.unlock()
        }
        
        singletonFactories.removeAll()
        singletons.removeAll()
        factories.removeAll()
        
        Self.log("[reset] ServiceLocator has been reset")
    }
    
    /// Logs a message if logging is enabled
    /// - Parameter message: The message to log
    private static func log(_ message: String) {
        if Self.enableLogging {
            print("[ServiceLocator]\(message)")
        }
    }
    
    public func register<T>(_ factory: @escaping () -> T) {
        let key = String(describing: T.self)
        single(T.self, factory)
    }
}

/// Initializes and configures a new `ServiceLocator` optionally with provided modules configuration closures.
/// - Parameter closure: An optional closure returning one or more configured modules.
/// - Returns: A fully initialized `ServiceLocator` object ready to use in your application.
public func startServiceLocator(_ closure: (() -> ServiceLocatorModule)? = nil) -> ServiceLocator {
    let serviceLocator = ServiceLocator()
    if let modules = closure?() {
        serviceLocator.module {
            modules
        }
    }
    return serviceLocator
}
