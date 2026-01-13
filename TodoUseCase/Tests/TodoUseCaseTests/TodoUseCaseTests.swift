import Testing
import Foundation
import SwiftData
import DependencyContainer
@testable import TodoUseCase
@testable import TodoRepository
import class TodoUseCase.Category
public typealias TodoCategory = Category

@MainActor
struct TodoUseCaseTests {

    // Fake repository for testing
    final class FakeTodoRepository: TodoRepositoryProtocol {
        
        var todos: [Todo] = []
        var categories: [TodoCategory] = []

        func createTodo(title: String, notes: String, dueDate: Date?, priority: TodoPriority) async throws -> Todo {
            let todo = Todo(title: title, notes: notes, dueDate: dueDate, priorityRawValue: priority.rawValue)
            todos.append(todo)
            return todo
        }

        func fetchAllTodos() async throws -> [Todo] {
            return todos
        }

        func fetchTodo(byId id: PersistentIdentifier) async throws -> Todo? {
            return todos.first { $0.persistentModelID == id }
        }

        func updateTodo(_ todo: Todo) async throws {
            // Update is implicit in memory
        }

        func deleteTodo(_ todo: Todo) async throws {
            todos.removeAll { $0.persistentModelID == todo.persistentModelID }
        }

        func fetchTodos(isCompleted: Bool?) async throws -> [Todo] {
            if let completed = isCompleted {
                return todos.filter { $0.isCompleted == completed }
            }
            return todos
        }

        func fetchTodos(priority: TodoPriority?) async throws -> [Todo] {
            if let priority = priority {
                return todos.filter { $0.priority == priority }
            }
            return todos
        }

        func fetchTodos(category: Category) async throws -> [Todo] {
            return todos.filter { todo in
                todo.categories?.contains(where: { $0.persistentModelID == category.persistentModelID }) ?? false
            }
        }

        func reorderTodos(from source: IndexSet, to destination: Int, in todos: [Todo]) async throws {
            // No-op for tests
        }

        func createCategory(name: String, colorHex: String) async throws -> Category {
            let category = Category(name: name, colorHex: colorHex)
            categories.append(category)
            return category
        }

        func fetchAllCategories() async throws -> [Category] {
            return categories
        }

        func deleteCategory(_ category: Category) async throws {
            categories.removeAll { $0.persistentModelID == category.persistentModelID }
        }

        func addCategory(_ category: Category, to todo: Todo) async throws {
            if todo.categories == nil {
                todo.categories = []
            }
            todo.categories?.append(category)
        }

        func removeCategory(_ category: Category, from todo: Todo) async throws {
            todo.categories?.removeAll { $0.persistentModelID == category.persistentModelID }
        }
    }

    @Test("Create todo with valid title succeeds")
    func testCreateTodoSuccess() async throws {
        // Given
        let fakeRepo = FakeTodoRepository()
        let container = DIContainer()
        container.register(TodoRepositoryProtocol.self, fakeRepo)
        let useCase = try TodoUseCase(container: container)

        // When
        let adapter = try await useCase.createTodo(
            title: "Test Todo",
            notes: "Notes",
            dueDate: nil,
            priority: .medium,
            categoryIds: []
        )

        // Then
        #expect(adapter.title == "Test Todo")
        #expect(adapter.priority == .medium)
        #expect(fakeRepo.todos.count == 1)
    }

    @Test("Create todo with empty title throws validation error")
    func testCreateTodoEmptyTitleFails() async throws {
        // Given
        let fakeRepo = FakeTodoRepository()
        let container = DIContainer()
        container.register(TodoRepositoryProtocol.self, fakeRepo)
        let useCase = try TodoUseCase(container: container)

        // When/Then
        do {
            _ = try await useCase.createTodo(
                title: "   ",
                notes: "",
                dueDate: nil,
                priority: .none,
                categoryIds: []
            )
            Issue.record("Should have thrown validation error")
        } catch TodoError.validation {
            // Expected
        }
    }

    @Test("Filter active todos returns only incomplete")
    func testFilterActiveTodos() async throws {
        // Given
        let fakeRepo = FakeTodoRepository()
        let todo1 = Todo(title: "Active", isCompleted: false)
        let todo2 = Todo(title: "Done", isCompleted: true)
        fakeRepo.todos = [todo1, todo2]

        let container = DIContainer()
        container.register(TodoRepositoryProtocol.self, fakeRepo)
        let useCase = try TodoUseCase(container: container)

        // When
        let result = try await useCase.fetchTodos(filter: .active)

        // Then
        #expect(result.count == 1)
        #expect(result[0].title == "Active")
        #expect(!result[0].isCompleted)
    }

    @Test("Toggle todo completion changes state")
    func testToggleTodoCompletion() async throws {
        // Given
        let fakeRepo = FakeTodoRepository()
        let todo = Todo(title: "Test", isCompleted: false)
        fakeRepo.todos = [todo]

        let container = DIContainer()
        container.register(TodoRepositoryProtocol.self, fakeRepo)
        let useCase = try TodoUseCase(container: container)

        // When
        try await useCase.toggleTodoCompletion(id: todo.persistentModelID)

        // Then
        #expect(todo.isCompleted == true)
    }

    @Test("Delete todo removes from repository")
    func testDeleteTodo() async throws {
        // Given
        let fakeRepo = FakeTodoRepository()
        let todo = Todo(title: "To Delete")
        fakeRepo.todos = [todo]

        let container = DIContainer()
        container.register(TodoRepositoryProtocol.self, fakeRepo)
        let useCase = try TodoUseCase(container: container)

        // When
        try await useCase.deleteTodo(id: todo.persistentModelID)

        // Then
        #expect(fakeRepo.todos.isEmpty)
    }

    @Test("Create category with valid name succeeds")
    func testCreateCategory() async throws {
        // Given
        let fakeRepo = FakeTodoRepository()
        let container = DIContainer()
        container.register(TodoRepositoryProtocol.self, fakeRepo)
        let useCase = try TodoUseCase(container: container)

        // When
        let category = try await useCase.createCategory(name: "Work", colorHex: "#FF0000")

        // Then
        #expect(category.name == "Work")
        #expect(category.colorHex == "#FF0000")
        #expect(fakeRepo.categories.count == 1)
    }
}
