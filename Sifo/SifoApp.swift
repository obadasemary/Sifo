//
//  SifoApp.swift
//  Sifo
//
//  Created by Abdelrahman Mohamed on 09.01.2026.
//

import SwiftUI
import SwiftData
import DependencyContainer
import TodoRepository
import TodoUseCase
import TabBarView

@main
struct SifoApp: App {
    let modelContainer: ModelContainer
    let diContainer: DIContainer

    init() {
        do {
            // Setup SwiftData schema
            let schema = Schema(
                [
                    Todo.self,
                    Category.self
                ]
            )

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic // Enable CloudKit sync
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            // Setup Dependency Injection container
            diContainer = AppComposition.setupDependencies(modelContainer: modelContainer)

        } catch {
            fatalError("Failed to initialize app: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            let builder = TabBarBuilder(container: diContainer)
            builder.buildTabBarView()
        }
        .modelContainer(modelContainer)
    }
}
