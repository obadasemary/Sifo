import SwiftUI
import SwiftData
import DependencyContainer
import TodoRepository
import TodoUseCase

/// Shared preview environment with in-memory data and dependencies
@MainActor
public final class DevPreview {
    public static let shared = DevPreview()

    public let container: DIContainer
    public let modelContainer: ModelContainer

    private init() {
        do {
            // Create in-memory SwiftData container for previews
            let schema = Schema([Todo.self, Category.self])
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            modelContainer = try ModelContainer(for: schema, configurations: [config])

            // Setup DI container
            container = DIContainer()
            let modelContext = ModelContext(modelContainer)

            // Register repository
            let repository: TodoRepositoryProtocol = TodoRepository(modelContext: modelContext)
            container.register(TodoRepositoryProtocol.self, repository)

            // Register use case
            let useCase = try TodoUseCase(container: container)
            container.register(TodoUseCaseProtocol.self, useCase)

            // Seed preview data
            Task {
                await seedPreviewData(repository: repository)
            }
        } catch {
            fatalError("Failed to create DevPreview: \(error)")
        }
    }

    private func seedPreviewData(repository: TodoRepositoryProtocol) async {
        do {
            // Create some categories
            let workCategory = try await repository.createCategory(name: "Work", colorHex: "#FF0000")
            let personalCategory = try await repository.createCategory(name: "Personal", colorHex: "#00FF00")

            // Create sample todos
            let todo1 = try await repository.createTodo(
                title: "Buy groceries",
                notes: "Milk, eggs, bread, and coffee",
                dueDate: Date().addingTimeInterval(86400), // Tomorrow
                priority: .high
            )
            try await repository.addCategory(personalCategory, to: todo1)

            let todo2 = try await repository.createTodo(
                title: "Finish project report",
                notes: "Need to complete Q4 analysis",
                dueDate: Date().addingTimeInterval(-86400), // Yesterday (overdue)
                priority: .medium
            )
            try await repository.addCategory(workCategory, to: todo2)

            let todo3 = try await repository.createTodo(
                title: "Call dentist",
                notes: "",
                dueDate: nil,
                priority: .low
            )

            let completedTodo = try await repository.createTodo(
                title: "Read Swift documentation",
                notes: "Completed yesterday",
                dueDate: nil,
                priority: .none
            )
            completedTodo.isCompleted = true
            try await repository.updateTodo(completedTodo)
            try await repository.addCategory(workCategory, to: completedTodo)

            _ = try await repository.createTodo(
                title: "Plan vacation",
                notes: "Research destinations and book flights",
                dueDate: Date().addingTimeInterval(604800), // Next week
                priority: .medium
            )

        } catch {
            print("Failed to seed preview data: \(error)")
        }
    }
}

