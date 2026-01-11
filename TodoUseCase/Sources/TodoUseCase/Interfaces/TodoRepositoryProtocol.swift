import Foundation
import SwiftData

/// Protocol defining data access operations for todos
@MainActor
public protocol TodoRepositoryProtocol {
    // CRUD operations
    func createTodo(title: String, notes: String, dueDate: Date?, priority: TodoPriority) async throws -> Todo
    func fetchAllTodos() async throws -> [Todo]
    func fetchTodo(byId id: PersistentIdentifier) async throws -> Todo?
    func updateTodo(_ todo: Todo) async throws
    func deleteTodo(_ todo: Todo) async throws

    // Filtering
    func fetchTodos(isCompleted: Bool?) async throws -> [Todo]
    func fetchTodos(priority: TodoPriority?) async throws -> [Todo]
    func fetchTodos(category: Category) async throws -> [Todo]

    // Reordering
    func reorderTodos(from source: IndexSet, to destination: Int, in todos: [Todo]) async throws

    // Categories
    func createCategory(name: String, colorHex: String) async throws -> Category
    func fetchAllCategories() async throws -> [Category]
    func deleteCategory(_ category: Category) async throws

    // Relationships
    func addCategory(_ category: Category, to todo: Todo) async throws
    func removeCategory(_ category: Category, from todo: Todo) async throws
}
