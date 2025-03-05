/// A module for organizing and registering dependencies
open class ServiceLocatorModule {
    public init() {}

    weak var locator: ServiceLocator!

    /// Override this method to register dependencies for this module
    open func build() {
        // Method designed to be overridden where one can put registration logic during module building phase
    }
}
