/// Represents a dependency with its associated factory method in a service locator pattern.
/// This struct encapsulates the information needed to create and identify a dependency.
struct DependencyWithKey {
    /// The key used to identify the dependency, typically the type name.
    /// This key is used by the service locator to look up the appropriate factory
    /// when resolving dependencies.
    ///
    /// - Note: It's common to use the fully qualified name of the type as the key
    ///         to ensure uniqueness across different modules or namespaces.
    public let key: String

    /// A closure that creates an instance of the dependency.
    /// This factory method is invoked by the service locator when the dependency
    /// needs to be resolved.
    ///
    /// - Returns: An instance of Any, which should be cast to the appropriate type
    ///            when used. The use of Any allows for flexibility in the types
    ///            of dependencies that can be registered.
    ///
    /// - Important: The factory closure should be designed to create a new instance
    ///              each time it's called, unless implementing a singleton pattern.
    public let factory: () -> Any

    /// Initializes a new DependencyWithKey instance.
    ///
    /// - Parameters:
    ///   - key: A string identifier for the dependency.
    ///   - factory: A closure that creates an instance of the dependency.
    public init(key: String, factory: @escaping () -> Any) {
        self.key = key
        self.factory = factory
    }
}
