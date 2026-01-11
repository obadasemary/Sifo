import Foundation

/// Errors that can occur in the use case layer
public enum TodoError: Error, LocalizedError, Sendable {
    case validation(String)
    case notFound
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .validation(let message):
            return message
        case .notFound:
            return "Todo not found"
        case .unknown(let message):
            return message
        }
    }
}
