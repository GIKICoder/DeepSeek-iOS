//
//  Result+Exts.swift
//  AppFoundation
//
//  Created by GIKI on 2025/1/10.
//

import Foundation

extension Result {
    public var isSuccess: Bool {
        guard case .success = self else { return false }
        return true
    }
    
    public var isFailure: Bool {
        !isSuccess
    }
    
    public var success: Success? {
        guard case let .success(value) = self else { return nil }
        return value
    }
    
    public var failure: Failure? {
        guard case let .failure(error) = self else { return nil }
        return error
    }
}
