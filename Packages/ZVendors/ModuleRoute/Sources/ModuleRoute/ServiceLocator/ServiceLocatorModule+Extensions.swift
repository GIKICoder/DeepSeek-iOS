public extension ServiceLocatorModule {
    /// Internal method to build the module
    final internal func buildInternal(locator: ServiceLocator) {
        self.locator = locator
        build()
    }

    /// Registers a factory for creating instances of a specified type
    final func factory<T>(_  type: T.Type = T.self, _ factory: @escaping () -> T) {
        locator.factory(type, factory)
    }

    /// Registers a singleton factory for a specified type
    final func single<T>(_ type: T.Type = T.self, _ factory: @escaping () -> T) {
        locator.single(type, factory)
    }

    /// Resolves an instance of the specified type
    final func resolve<T>() -> T {
        try! locator.resolve()
    }

    /// Registers a sub-module
    final func module(_ closure: @escaping () -> ServiceLocatorModule) {
        locator.module(closure)
    }
}
