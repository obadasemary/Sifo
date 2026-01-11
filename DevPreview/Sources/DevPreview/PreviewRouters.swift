import Foundation
import TodoListView
import TodoUseCase

/// Preview router for TodoListView
@MainActor
public final class PreviewTodoListRouter: TodoListRouterProtocol {
    public init() {}

    public func navigateToAddTodo() {
        print("[Preview] Navigate to add todo")
    }

    public func navigateToEditTodo(_ todo: TodoItemAdapter) {
        print("[Preview] Navigate to edit todo: \(todo.title)")
    }
}
