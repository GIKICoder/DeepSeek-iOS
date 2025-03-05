//
//  File.swift
//  ModuleRoute
//
//  Created by GIKI on 2025/2/17.
//

import Foundation
import UIKit

public final class MRNavigatorLocator {
    
    static let shared = MRNavigatorLocator()
    
    var serviceLocator: ServiceLocator?
    
}

@propertyWrapper
public final class MRInject<T>: Dependency<T> {

    
    public var wrappedValue: T {
        resolvedWrappedValue()
    }

    public init() {
        guard let serviceLocator = MRNavigatorLocator.shared.serviceLocator else {
            fatalError("Could not access AppDelegate or cast it to the correct type.")
        }
        super.init(serviceLocator)
    }
}
