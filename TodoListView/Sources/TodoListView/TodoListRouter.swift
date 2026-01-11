import Foundation
import TodoUseCase

/// Protocol for navigation from the todo list
@MainActor
public protocol TodoListRouterProtocol {
    func navigateToAddTodo()
    func navigateToEditTodo(_ todo: TodoItemAdapter)
}
