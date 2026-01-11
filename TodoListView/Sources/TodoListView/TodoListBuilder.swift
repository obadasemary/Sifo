import Foundation
import Observation
import DependencyContainer
import TodoUseCase

/// Builder for composing TodoListView with dependencies
@MainActor
@Observable
public final class TodoListBuilder {
    private let container: DIContainer

    public init(container: DIContainer) {
        self.container = container
    }

    /// Build TodoListView with dependencies resolved
    /// - Parameter router: Router for navigation
    /// - Returns: Configured TodoListView
    /// - Throws: DIError if dependencies cannot be resolved
    public func buildTodoListView(router: TodoListRouterProtocol) throws -> TodoListView {
        let useCase = try container.requireResolve(TodoUseCaseProtocol.self)
        let viewModel = TodoListViewModel(useCase: useCase, router: router)
        return TodoListView(viewModel: viewModel)
    }
}
