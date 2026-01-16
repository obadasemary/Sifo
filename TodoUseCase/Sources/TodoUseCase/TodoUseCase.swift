import Foundation
import SwiftData
import DependencyContainer
//import TodoRepository

/// Use case implementation for todo business logic
@MainActor
public final class TodoUseCase: TodoUseCaseProtocol {
    private let repository: TodoRepositoryProtocol

    public init(container: DIContainer) throws {
        self.repository = try container.requireResolve(TodoRepositoryProtocol.self)
    }

    // MARK: - Fetch Operations

    public func fetchTodos(filter: FilterOption) async throws -> [TodoItemAdapter] {
        do {
            let todos = try await repository.fetchTodos(isCompleted: filter.completionFilter)
            return todos.map(TodoItemAdapter.from)
        } catch {
            throw TodoError.unknown(error.localizedDescription)
        }
    }

    public func fetchTodo(byId id: PersistentIdentifier) async throws -> TodoItemAdapter? {
        do {
            guard let todo = try await repository.fetchTodo(byId: id) else {
                return nil
            }
            return TodoItemAdapter.from(todo)
        } catch {
            throw TodoError.unknown(error.localizedDescription)
        }
    }

    // MARK: - Statistics

    public func fetchTodoStatistics() async throws -> TodoStatistics {
        do {
            // Fetch all todos (no filter)
            let todos = try await repository.fetchAllTodos()
            let adapters = todos.map(TodoItemAdapter.from)

            // Compute completion stats
            let total = adapters.count
            let completed = adapters.filter { $0.isCompleted }.count
            let active = total - completed
            let rate = total > 0 ? Double(completed) / Double(total) : 0.0

            // Compute priority breakdown
            let noPriority = adapters.filter { $0.priority == .none }.count
            let low = adapters.filter { $0.priority == .low }.count
            let medium = adapters.filter { $0.priority == .medium }.count
            let high = adapters.filter { $0.priority == .high }.count

            // Compute time-based stats
            let overdue = adapters.filter { $0.isOverdue }.count
            let dueToday = adapters.filter { $0.isDueToday }.count
            let upcoming = adapters.filter { todo in
                guard let dueDate = todo.dueDate, !todo.isCompleted else { return false }
                return dueDate > Date() && !todo.isDueToday
            }.count

            // Compute category statistics
            var categoryCount: [String: (name: String, colorHex: String, count: Int)] = [:]
            for adapter in adapters {
                for category in adapter.categories {
                    let key = category.name
                    if let existing = categoryCount[key] {
                        categoryCount[key] = (existing.name, existing.colorHex, existing.count + 1)
                    } else {
                        categoryCount[key] = (category.name, category.colorHex, 1)
                    }
                }
            }

            // Get top 5 categories by count
            let topCategories = categoryCount.values
                .sorted { $0.count > $1.count }
                .prefix(5)
                .map { CategoryStatistic(name: $0.name, colorHex: $0.colorHex, todoCount: $0.count) }

            return TodoStatistics(
                totalTodos: total,
                completedTodos: completed,
                activeTodos: active,
                completionRate: rate,
                noPriorityCount: noPriority,
                lowPriorityCount: low,
                mediumPriorityCount: medium,
                highPriorityCount: high,
                overdueTodos: overdue,
                dueTodayTodos: dueToday,
                upcomingTodos: upcoming,
                topCategories: Array(topCategories)
            )
        } catch {
            throw TodoError.unknown(error.localizedDescription)
        }
    }

    // MARK: - CRUD Operations

    public func createTodo(
        title: String,
        notes: String,
        dueDate: Date?,
        priority: TodoPriority,
        categoryIds: [PersistentIdentifier]
    ) async throws -> TodoItemAdapter {
        // Validation
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw TodoError.validation("Title cannot be empty")
        }

        do {
            // Create todo
            let todo = try await repository.createTodo(
                title: trimmedTitle,
                notes: notes,
                dueDate: dueDate,
                priority: priority
            )

            // Add categories if provided
            if !categoryIds.isEmpty {
                let categories = try await repository.fetchAllCategories()
                for categoryId in categoryIds {
                    if let category = categories.first(where: { $0.persistentModelID == categoryId }) {
                        try await repository.addCategory(category, to: todo)
                    }
                }
            }

            return TodoItemAdapter.from(todo)
        } catch let error as TodoError {
            throw error
        } catch {
            throw TodoError.unknown(error.localizedDescription)
        }
    }

    public func updateTodo(
        id: PersistentIdentifier,
        title: String,
        notes: String,
        dueDate: Date?,
        priority: TodoPriority
    ) async throws {
        // Validation
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw TodoError.validation("Title cannot be empty")
        }

        do {
            guard let todo = try await repository.fetchTodo(byId: id) else {
                throw TodoError.notFound
            }

            todo.title = trimmedTitle
            todo.notes = notes
            todo.dueDate = dueDate
            todo.priority = priority

            try await repository.updateTodo(todo)
        } catch let error as TodoError {
            throw error
        } catch {
            throw TodoError.unknown(error.localizedDescription)
        }
    }

    public func toggleTodoCompletion(id: PersistentIdentifier) async throws {
        do {
            guard let todo = try await repository.fetchTodo(byId: id) else {
                throw TodoError.notFound
            }

            todo.isCompleted.toggle()
            try await repository.updateTodo(todo)
        } catch let error as TodoError {
            throw error
        } catch {
            throw TodoError.unknown(error.localizedDescription)
        }
    }

    public func deleteTodo(id: PersistentIdentifier) async throws {
        do {
            guard let todo = try await repository.fetchTodo(byId: id) else {
                throw TodoError.notFound
            }

            try await repository.deleteTodo(todo)
        } catch let error as TodoError {
            throw error
        } catch {
            throw TodoError.unknown(error.localizedDescription)
        }
    }

    public func reorderTodos(from source: IndexSet, to destination: Int, in adapters: [TodoItemAdapter]) async throws {
        do {
            // Fetch actual Todo objects
            let allTodos = try await repository.fetchAllTodos()

            // Map adapters to todos preserving order
            let orderedTodos = adapters.compactMap { adapter in
                allTodos.first { $0.persistentModelID == adapter.id }
            }

            try await repository.reorderTodos(from: source, to: destination, in: orderedTodos)
        } catch {
            throw TodoError.unknown(error.localizedDescription)
        }
    }

    // MARK: - Categories

    public func fetchCategories() async throws -> [CategoryAdapter] {
        do {
            let categories = try await repository.fetchAllCategories()
            return categories.map(CategoryAdapter.from)
        } catch {
            throw TodoError.unknown(error.localizedDescription)
        }
    }

    public func createCategory(name: String, colorHex: String) async throws -> CategoryAdapter {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw TodoError.validation("Category name cannot be empty")
        }

        do {
            let category = try await repository.createCategory(name: trimmedName, colorHex: colorHex)
            return CategoryAdapter.from(category)
        } catch {
            throw TodoError.unknown(error.localizedDescription)
        }
    }
}
