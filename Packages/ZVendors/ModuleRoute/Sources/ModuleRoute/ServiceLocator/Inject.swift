/// A property wrapper that provides a mechanism for automatic dependency injection.
/// It resolves the dependency of type `T` from the service locator or dependency container.
/// The actual resolution strategy depends on how the underlying services are registered
/// (e.g., as singletons or transient objects).
///
/// This property wrapper extends the `Dependency<T>` class, leveraging its resolution mechanism
/// while providing a more convenient syntax for dependency injection.
///
/// Usage:
/// ```
/// @Inject var myService: MyServiceType
/// ```
///
/// Accessing `myService` will automatically resolve `MyServiceType` through the property wrapper.
///
/// - Note: Ensure that the appropriate `ServiceLocator` is set up and the required dependencies
///         are registered before accessing properties marked with `@Inject`.
@propertyWrapper
public final class Inject<T>: Dependency<T> {
    /// The wrapped value of the property wrapper which gets resolved when accessed.
    /// It uses the underlying service locator's resolution mechanism to provide
    /// an instance of type `T`.
    ///
    /// - Returns: An instance of type `T` resolved from the service locator.
    /// - Precondition: The `serviceLocator` must be properly set and capable of resolving type `T`.
    ///                 If resolution fails, a fatal error will be triggered.
    public var wrappedValue: T {
        resolvedWrappedValue()
    }
    
    /// Provides access to the `Inject` instance itself.
    /// This can be useful in scenarios where you need to access or modify the wrapper.
    ///
    /// Usage:
    /// ```
    /// @Inject var myService: MyServiceType
    /// func someFunction() {
    ///     let wrapper = _myService // Access to the Inject<MyServiceType> instance
    /// }
    /// ```
    public var projectedValue: Inject<T> {
        self
    }
}
