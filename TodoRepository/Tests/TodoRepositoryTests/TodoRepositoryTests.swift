import Testing
import Foundation
import SwiftData
import TodoUseCase
@testable import TodoRepository

@MainActor
struct TodoRepositoryTests {

    // Helper to create in-memory container
    func createInMemoryContainer() throws -> ModelContainer {
        let schema = Schema([Todo.self, Category.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }

    @Test("Create todo persists to database")
    func testCreateTodo() async throws {
        // Given
        let container = try createInMemoryContainer()
        let context = ModelContext(container)
        let repository = TodoRepository(modelContext: context)

        // When
        let todo = try await repository.createTodo(
            title: "Test Todo",
            notes: "Test Notes",
            dueDate: nil,
            priority: .medium
        )

        // Then
        #expect(todo.title == "Test Todo")
        #expect(todo.notes == "Test Notes")
        #expect(todo.priority == .medium)

        let fetchedTodos = try await repository.fetchAllTodos()
        #expect(fetchedTodos.count == 1)
        #expect(fetchedTodos[0].title == "Test Todo")
    }

    @Test("Filter by completion status works correctly")
    func testFilterByCompletionStatus() async throws {
        // Given
        let container = try createInMemoryContainer()
        let context = ModelContext(container)
        let repository = TodoRepository(modelContext: context)

        _ = try await repository.createTodo(title: "Active", notes: "", dueDate: nil, priority: .none)
        let completedTodo = try await repository.createTodo(title: "Done", notes: "", dueDate: nil, priority: .none)
        completedTodo.isCompleted = true
        try await repository.updateTodo(completedTodo)

        // When
        let activeTodos = try await repository.fetchTodos(isCompleted: false)
        let completedTodos = try await repository.fetchTodos(isCompleted: true)

        // Then
        #expect(activeTodos.count == 1)
        #expect(completedTodos.count == 1)
        #expect(activeTodos[0].title == "Active")
        #expect(completedTodos[0].title == "Done")
    }

    @Test("Reorder todos updates sort order")
    func testReorderTodos() async throws {
        // Given
        let container = try createInMemoryContainer()
        let context = ModelContext(container)
        let repository = TodoRepository(modelContext: context)

        let todo1 = try await repository.createTodo(title: "First", notes: "", dueDate: nil, priority: .none)
        let todo2 = try await repository.createTodo(title: "Second", notes: "", dueDate: nil, priority: .none)
        let todo3 = try await repository.createTodo(title: "Third", notes: "", dueDate: nil, priority: .none)

        let todos = [todo1, todo2, todo3]

        // When - Move index 0 to position 2
        try await repository.reorderTodos(from: IndexSet(integer: 0), to: 2, in: todos)

        // Then
        let reordered = try await repository.fetchAllTodos()
        #expect(reordered[0].title == "Second")
        #expect(reordered[1].title == "First")
        #expect(reordered[2].title == "Third")
    }

    @Test("Delete todo removes from database")
    func testDeleteTodo() async throws {
        // Given
        let container = try createInMemoryContainer()
        let context = ModelContext(container)
        let repository = TodoRepository(modelContext: context)

        let todo = try await repository.createTodo(title: "To Delete", notes: "", dueDate: nil, priority: .none)

        // When
        try await repository.deleteTodo(todo)

        // Then
        let todos = try await repository.fetchAllTodos()
        #expect(todos.isEmpty)
    }

    @Test("Create category persists to database")
    func testCreateCategory() async throws {
        // Given
        let container = try createInMemoryContainer()
        let context = ModelContext(container)
        let repository = TodoRepository(modelContext: context)

        // When
        let category = try await repository.createCategory(name: "Work", colorHex: "#FF0000")

        // Then
        #expect(category.name == "Work")
        #expect(category.colorHex == "#FF0000")

        let categories = try await repository.fetchAllCategories()
        #expect(categories.count == 1)
    }

    @Test("Add category to todo creates relationship")
    func testAddCategoryToTodo() async throws {
        // Given
        let container = try createInMemoryContainer()
        let context = ModelContext(container)
        let repository = TodoRepository(modelContext: context)

        let todo = try await repository.createTodo(title: "Test", notes: "", dueDate: nil, priority: .none)
        let category = try await repository.createCategory(name: "Work", colorHex: "#FF0000")

        // When
        try await repository.addCategory(category, to: todo)

        // Then
        #expect(todo.categories?.count == 1)
        #expect(todo.categories?.first?.name == "Work")
    }

    @Test("Remove category from todo removes relationship")
    func testRemoveCategoryFromTodo() async throws {
        // Given
        let container = try createInMemoryContainer()
        let context = ModelContext(container)
        let repository = TodoRepository(modelContext: context)

        let todo = try await repository.createTodo(title: "Test", notes: "", dueDate: nil, priority: .none)
        let category = try await repository.createCategory(name: "Work", colorHex: "#FF0000")
        try await repository.addCategory(category, to: todo)

        // When
        try await repository.removeCategory(category, from: todo)

        // Then
        #expect(todo.categories?.isEmpty ?? true)
    }

    @Test("Filter by priority works correctly")
    func testFilterByPriority() async throws {
        // Given
        let container = try createInMemoryContainer()
        let context = ModelContext(container)
        let repository = TodoRepository(modelContext: context)

        _ = try await repository.createTodo(title: "Low Priority", notes: "", dueDate: nil, priority: .low)
        _ = try await repository.createTodo(title: "High Priority", notes: "", dueDate: nil, priority: .high)

        // When
        let highPriorityTodos = try await repository.fetchTodos(priority: .high)

        // Then
        #expect(highPriorityTodos.count == 1)
        #expect(highPriorityTodos[0].title == "High Priority")
    }
}
