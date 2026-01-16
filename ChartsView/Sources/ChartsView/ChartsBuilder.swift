import Foundation
import Observation
import DependencyContainer
import TodoUseCase

/// Builder for composing ChartsView with dependencies
@MainActor
@Observable
public final class ChartsBuilder {
    private let container: DIContainer

    public init(container: DIContainer) {
        self.container = container
    }

    /// Build ChartsView with dependencies resolved
    /// - Parameter router: Router for navigation
    /// - Returns: Configured ChartsView
    /// - Throws: DIError if dependencies cannot be resolved
    public func buildChartsView(router: ChartsRouterProtocol) throws -> ChartsView {
        let useCase = try container.requireResolve(TodoUseCaseProtocol.self)
        let viewModel = ChartsViewModel(useCase: useCase, router: router)
        return ChartsView(viewModel: viewModel)
    }
}
