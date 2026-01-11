import Foundation
import Observation
import DependencyContainer
import TodoUseCase

/// Builder for composing TodoDetailView with dependencies
@MainActor
@Observable
public final class TodoDetailBuilder {
    private let container: DIContainer

    public init(container: DIContainer) {
        self.container = container
    }

    /// Build TodoDetailView with dependencies resolved
    /// - Parameter existingTodo: Optional todo to edit (nil for new todo)
    /// - Returns: Configured TodoDetailView
    /// - Throws: DIError if dependencies cannot be resolved
    public func buildTodoDetailView(existingTodo: TodoItemAdapter? = nil) throws -> TodoDetailView {
        let useCase = try container.requireResolve(TodoUseCaseProtocol.self)
        let viewModel = TodoDetailViewModel(useCase: useCase, existingTodo: existingTodo)
        return TodoDetailView(viewModel: viewModel)
    }
}
