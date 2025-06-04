//
//  DBClientError.swift
//  AppComponents
//
//  Created by GIKI on 2025/6/1.
//

import Foundation

// MARK: - DBClientError

public enum DBClientError: LocalizedError {
    case databaseNotInitialized
    case tableNotFound(String)
    case insertFailed(Error)
    case queryFailed(Error)
    case updateFailed(Error)
    case deleteFailed(Error)
    case migrationFailed(Error)
    case invalidData(String)
    
    public var errorDescription: String? {
        switch self {
        case .databaseNotInitialized:
            return "Database not initialized"
        case .tableNotFound(let table):
            return "Table '\(table)' not found"
        case .insertFailed(let error):
            return "Insert operation failed: \(error.localizedDescription)"
        case .queryFailed(let error):
            return "Query operation failed: \(error.localizedDescription)"
        case .updateFailed(let error):
            return "Update operation failed: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Delete operation failed: \(error.localizedDescription)"
        case .migrationFailed(let error):
            return "Database migration failed: \(error.localizedDescription)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        }
    }
}
