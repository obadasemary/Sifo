import Foundation
import Observation
import TodoUseCase

/// ViewModel for the todo list feature
/// Implements state machine pattern for clear state transitions
@MainActor
@Observable
public final class TodoListViewModel {

    // MARK: - State Machine
    public enum State: Equatable {
        case idle
        case loading
        case loaded([TodoItemAdapter])
        case error(String)
        case deleting(TodoItemAdapter) // Confirmation needed

        public static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle): return true
            case (.loading, .loading): return true
            case (.loaded(let l), .loaded(let r)): return l == r
            case (.error(let l), .error(let r)): return l == r
            case (.deleting(let l), .deleting(let r)): return l == r
            default: return false
            }
        }
    }

    // MARK: - Properties
    private let useCase: TodoUseCaseProtocol
    private let router: TodoListRouterProtocol

    public var state: State = .idle
    public var currentFilter: FilterOption = .all

    // Computed properties
    public var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    public var todos: [TodoItemAdapter] {
        if case .loaded(let items) = state { return items }
        return []
    }

    public var errorMessage: String? {
        if case .error(let message) = state { return message }
        return nil
    }

    // MARK: - Initialization
    public init(useCase: TodoUseCaseProtocol, router: TodoListRouterProtocol) {
        self.useCase = useCase
        self.router = router
    }

    // MARK: - Actions
    public func loadTodos() {
        state = .loading
        Task {
            do {
                let items = try await useCase.fetchTodos(filter: currentFilter)
                state = .loaded(items)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    public func filterChanged(to filter: FilterOption) {
        currentFilter = filter
        loadTodos()
    }

    public func toggleCompletion(for todo: TodoItemAdapter) {
        Task {
            do {
                try await useCase.toggleTodoCompletion(id: todo.id)
                loadTodos() // Refresh list
            } catch {
                state = .error("Failed to update todo: \(error.localizedDescription)")
            }
        }
    }

    public func deleteTodoConfirmation(for todo: TodoItemAdapter) {
        state = .deleting(todo)
    }

    public func confirmDelete() {
        guard case .deleting(let todo) = state else { return }
        Task {
            do {
                try await useCase.deleteTodo(id: todo.id)
                loadTodos()
            } catch {
                state = .error("Failed to delete: \(error.localizedDescription)")
            }
        }
    }

    public func cancelDelete() {
        loadTodos() // Return to loaded state
    }

    public func reorderTodos(from source: IndexSet, to destination: Int) {
        Task {
            do {
                try await useCase.reorderTodos(from: source, to: destination, in: todos)
                loadTodos()
            } catch {
                state = .error("Failed to reorder: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Navigation
    public func addTodoTapped() {
        router.navigateToAddTodo()
    }

    public func editTodoTapped(_ todo: TodoItemAdapter) {
        router.navigateToEditTodo(todo)
    }
}
