import Foundation

/// An open base class representing a dependency that can be resolved from a service locator.
/// This class provides a generic mechanism to resolve instances of type `T` using a `ServiceLocator`.
///
/// Subclasses should utilize the `resolvedWrappedValue()` method to obtain the resolved instance
/// based on the configuration of the service locator.
open class Dependency<T> {
    /// A weak reference to the service locator used to resolve instances of type `T`.
    /// This is deliberately weak to avoid retain cycles.
    internal weak var serviceLocator: ServiceLocator?
    
    /// The file where this dependency was created.
    let file: String
    
    /// The file ID where this dependency was created.
    let fileId: String
    
    /// The function where this dependency was created.
    let function: String
    
    /// The line number where this dependency was created.
    let line: Int

    /// Initializes a new dependency with a reference to a service locator.
    ///
    /// - Parameters:
    ///   - serviceLocator: The service locator used to resolve instances of type `T`.
    ///   - file: The file where this dependency is being initialized. Defaults to the current file.
    ///   - fileId: The file ID where this dependency is being initialized. Defaults to the current file ID.
    ///   - function: The function where this dependency is being initialized. Defaults to the current function.
    ///   - line: The line number where this dependency is being initialized. Defaults to the current line number.
    public init(_ serviceLocator: ServiceLocator, _ file: String = #file, _ fileId: String = #fileID, _ function: String = #function, _ line: Int = #line) {
        self.serviceLocator = serviceLocator
        self.file = file
        self.fileId = fileId
        self.function = function
        self.line = line
    }

    /// Resolves and returns the wrapped value from the associated service locator.
    ///
    /// This method attempts to resolve an instance of type `T` using the provided `serviceLocator`.
    /// The resolution process will either fetch an existing instance or create a new one,
    /// depending on how `T` was registered within the `ServiceLocator`.
    ///
    /// - Returns: The resolved instance of type `T`.
    /// - Throws: An error if the dependency cannot be resolved.
    /// - Precondition: The `serviceLocator` property must not be nil when this method is called.
    public func resolvedWrappedValue() -> T {
        guard let serviceLocatorScope = serviceLocator else {
            fatalError("ServiceLocator is nil. Ensure that it is set before attempting to resolve dependencies.")
        }

        do {
            return try serviceLocatorScope.resolve(file, fileId, function, line)
        } catch {
            fatalError("Failed to resolve dependency of type \(T.self): \(error)")
        }
    }
}
