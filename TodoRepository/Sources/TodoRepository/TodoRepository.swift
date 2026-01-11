import SwiftData
import Foundation
import TodoUseCase
import class TodoUseCase.Category
public typealias TodoCategory = Category

/// SwiftData implementation of TodoRepositoryProtocol
@MainActor
public final class TodoRepository {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
}

extension TodoRepository: TodoRepositoryProtocol {

    // MARK: - CRUD Operations

    public func createTodo(title: String, notes: String, dueDate: Date?, priority: TodoPriority) async throws -> Todo {
        let maxOrder = try await fetchMaxSortOrder()
        let todo = Todo(
            title: title,
            notes: notes,
            dueDate: dueDate,
            priorityRawValue: priority.rawValue,
            sortOrder: maxOrder + 1
        )
        modelContext.insert(todo)
        try modelContext.save()
        return todo
    }

    public func fetchAllTodos() async throws -> [Todo] {
        let descriptor = FetchDescriptor<Todo>(
            sortBy: [SortDescriptor(\Todo.sortOrder, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func fetchTodo(byId id: PersistentIdentifier) async throws -> Todo? {
        return modelContext.model(for: id) as? Todo
    }

    public func updateTodo(_ todo: Todo) async throws {
        try modelContext.save()
    }

    public func deleteTodo(_ todo: Todo) async throws {
        modelContext.delete(todo)
        try modelContext.save()
    }

    // MARK: - Filtering

    public func fetchTodos(isCompleted: Bool?) async throws -> [Todo] {
        var descriptor = FetchDescriptor<Todo>(
            sortBy: [SortDescriptor(\Todo.sortOrder, order: .forward)]
        )
        if let isCompleted = isCompleted {
            descriptor.predicate = #Predicate { $0.isCompleted == isCompleted }
        }
        return try modelContext.fetch(descriptor)
    }

    public func fetchTodos(priority: TodoPriority?) async throws -> [Todo] {
        var descriptor = FetchDescriptor<Todo>(
            sortBy: [SortDescriptor(\Todo.sortOrder, order: .forward)]
        )
        if let priority = priority {
            let rawValue = priority.rawValue
            descriptor.predicate = #Predicate { $0.priorityRawValue == rawValue }
        }
        return try modelContext.fetch(descriptor)
    }

    public func fetchTodos(category: TodoCategory) async throws -> [Todo] {
        let descriptor = FetchDescriptor<Todo>(
            sortBy: [SortDescriptor(\Todo.sortOrder, order: .forward)]
        )
        let allTodos = try modelContext.fetch(descriptor)
        // Filter todos that contain this category
        return allTodos.filter { todo in
            todo.categories?.contains(where: { $0.persistentModelID == category.persistentModelID }) ?? false
        }
    }

    // MARK: - Reordering

    public func reorderTodos(from source: IndexSet, to destination: Int, in todos: [Todo]) async throws {
        var mutableTodos = todos

        // Manually implement move logic without SwiftUI dependency
        let movedItems = source.sorted().reversed().map { mutableTodos.remove(at: $0) }
        mutableTodos.insert(contentsOf: movedItems.reversed(), at: destination)

        // Update sort order for all todos
        for (index, todo) in mutableTodos.enumerated() {
            todo.sortOrder = index
        }

        try modelContext.save()
    }

    // MARK: - Categories

    public func createCategory(name: String, colorHex: String) async throws -> TodoCategory {
        let category = TodoCategory(name: name, colorHex: colorHex)
        modelContext.insert(category)
        try modelContext.save()
        return category
    }

    public func fetchAllCategories() async throws -> [TodoCategory] {
        let descriptor = FetchDescriptor<TodoCategory>(
            sortBy: [SortDescriptor(\TodoCategory.name, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func deleteCategory(_ category: TodoCategory) async throws {
        modelContext.delete(category)
        try modelContext.save()
    }

    // MARK: - Relationships

    public func addCategory(_ category: TodoCategory, to todo: Todo) async throws {
        if todo.categories == nil {
            todo.categories = []
        }
        if !(todo.categories?.contains(where: { $0.persistentModelID == category.persistentModelID }) ?? false) {
            todo.categories?.append(category)
            try modelContext.save()
        }
    }

    public func removeCategory(_ category: TodoCategory, from todo: Todo) async throws {
        todo.categories?.removeAll(where: { $0.persistentModelID == category.persistentModelID })
        try modelContext.save()
    }

    // MARK: - Helpers

    private func fetchMaxSortOrder() async throws -> Int {
        let descriptor = FetchDescriptor<Todo>(
            sortBy: [SortDescriptor(\Todo.sortOrder, order: .reverse)]
        )
        let todos = try modelContext.fetch(descriptor)
        return todos.first?.sortOrder ?? 0
    }
}

