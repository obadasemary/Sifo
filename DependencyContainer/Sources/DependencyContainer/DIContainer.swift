import Foundation
import Observation

/// A simple dependency injection container that stores and resolves dependencies
@MainActor
@Observable
public final class DIContainer {
    private var services: [String: Any] = [:]

    public init() {}

    /// Register a service instance for a given type
    /// - Parameters:
    ///   - type: The protocol or class type to register
    ///   - instance: The concrete implementation
    public func register<T>(_ type: T.Type, _ instance: T) {
        let key = String(describing: type)
        services[key] = instance
    }

    /// Resolve a previously registered service
    /// - Parameter type: The type to resolve
    /// - Returns: The registered instance
    /// - Throws: DIError.notRegistered if the type hasn't been registered
    public func requireResolve<T>(_ type: T.Type) throws -> T {
        let key = String(describing: type)
        guard let service = services[key] as? T else {
            throw DIError.notRegistered(type: String(describing: type))
        }
        return service
    }

    /// Resolve a previously registered service (optional variant)
    /// - Parameter type: The type to resolve
    /// - Returns: The registered instance, or nil if not found
    public func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        return services[key] as? T
    }
}

/// Errors that can occur during dependency resolution
public enum DIError: Error, LocalizedError {
    case notRegistered(type: String)

    public var errorDescription: String? {
        switch self {
        case .notRegistered(let type):
            return "Type '\(type)' has not been registered in the DI container"
        }
    }
}
