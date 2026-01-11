import Foundation
import SwiftData
//import TodoRepository

/// Protocol defining business logic operations for todos
@MainActor
public protocol TodoUseCaseProtocol {
    // Fetch operations
    func fetchTodos(filter: FilterOption) async throws -> [TodoItemAdapter]
    func fetchTodo(byId id: PersistentIdentifier) async throws -> TodoItemAdapter?

    // CRUD operations
    func createTodo(
        title: String,
        notes: String,
        dueDate: Date?,
        priority: TodoPriority,
        categoryIds: [PersistentIdentifier]
    ) async throws -> TodoItemAdapter

    func updateTodo(
        id: PersistentIdentifier,
        title: String,
        notes: String,
        dueDate: Date?,
        priority: TodoPriority
    ) async throws

    func toggleTodoCompletion(id: PersistentIdentifier) async throws
    func deleteTodo(id: PersistentIdentifier) async throws
    func reorderTodos(from source: IndexSet, to destination: Int, in adapters: [TodoItemAdapter]) async throws

    // Categories
    func fetchCategories() async throws -> [CategoryAdapter]
    func createCategory(name: String, colorHex: String) async throws -> CategoryAdapter
}
