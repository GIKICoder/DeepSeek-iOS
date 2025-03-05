//
//  PluginInject.swift
//  ModuleRouteExample
//
//  Created by GIKI on 2025/2/17.
//

import Foundation
import ModuleRoute
import UIKit

@propertyWrapper
internal final class PluginInject<T>: Dependency<T> {

    public var wrappedValue: T {
        resolvedWrappedValue()
    }

    public init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Could not access AppDelegate or cast it to the correct type.")
        }
        super.init(appDelegate.myServiceLocator)
    }
}
