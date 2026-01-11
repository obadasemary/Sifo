//
//  AppComposition.swift
//  Sifo
//
//  Dependency injection composition root
//  Registers all dependencies in the correct order
//

import SwiftUI
import SwiftData
import DependencyContainer
import TodoRepository
import TodoUseCase

/// Composes and registers all app dependencies
@MainActor
final class AppComposition {

    /// Setup all dependencies for the application
    /// - Parameter modelContainer: The SwiftData model container
    /// - Returns: Configured DI container with all dependencies registered
    static func setupDependencies(modelContainer: ModelContainer) -> DIContainer {
        let container = DIContainer()

        // MARK: - Infrastructure Layer
        let modelContext = ModelContext(modelContainer)

        // MARK: - Data Layer
        // Register TodoRepository
        let todoRepository = TodoRepository(modelContext: modelContext)
        container.register(TodoRepositoryProtocol.self, todoRepository)

        // MARK: - Business Logic Layer
        // Register TodoUseCase
        do {
            let todoUseCase = try TodoUseCase(container: container)
            container.register(TodoUseCaseProtocol.self, todoUseCase)
        } catch {
            fatalError("Failed to register TodoUseCase: \(error)")
        }

        // MARK: - Presentation Layer
        // Builders are instantiated directly with the container when needed
        // No registration required

        return container
    }
}
