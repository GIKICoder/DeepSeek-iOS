import Foundation

/// Error thrown when a dependency cannot be resolved
struct ResolutionError: LocalizedError, CustomStringConvertible {
    let message: String
    
    public var description: String {
        errorDescription
    }

    var errorDescription: String {
        localizedDescription
    }
    
    public var localizedDescription: String {
        message
    }
}
