import SwiftUI
import DependencyContainer
import TodoListView
import TodoDetailView
import ChartsView
import TodoUseCase
import DevPreview

/// Main tab bar view with navigation coordination
public struct TabBarView: View {
    private let container: DIContainer

    public init(container: DIContainer) {
        self.container = container
    }

    public var body: some View {
        TabView {
            Tab("Todos", systemImage: "checklist") {
                TodoListCoordinator(container: container)
            }

            Tab("Charts", systemImage: "chart.bar") {
                ChartsCoordinator(container: container)
            }
        }
    }
}

/// Coordinator for todo list with navigation
private struct TodoListCoordinator: View {
    private let container: DIContainer
    @State private var showingAddSheet = false
    @State private var editingTodo: TodoItemAdapter?
    @State private var listViewModel: TodoListViewModel?

    init(container: DIContainer) {
        self.container = container
    }

    var body: some View {
        // Build view model once on first render
        if listViewModel == nil {
            Color.clear.onAppear {
                buildViewModel()
            }
        } else if let viewModel = listViewModel {
            let router = TodoListRouterImpl(
                showAddSheet: { showingAddSheet = true },
                showEditSheet: { editingTodo = $0 }
            )

            TodoListView(viewModel: viewModel)
                .sheet(isPresented: $showingAddSheet) {
                    // Reload todos when sheet is dismissed
                    viewModel.loadTodos()
                } content: {
                    let detailBuilder = TodoDetailBuilder(container: container)
                    if let detailView = try? detailBuilder.buildTodoDetailView(existingTodo: nil) {
                        detailView
                    }
                }
                .sheet(item: $editingTodo, onDismiss: {
                    // Reload todos when edit sheet is dismissed
                    viewModel.loadTodos()
                }) { todo in
                    let detailBuilder = TodoDetailBuilder(container: container)
                    if let detailView = try? detailBuilder.buildTodoDetailView(existingTodo: todo) {
                        detailView
                    }
                }
        } else {
            Text("Failed to initialize")
                .foregroundStyle(.red)
        }
    }

    private func buildViewModel() {
        if let useCase = try? container.requireResolve(TodoUseCaseProtocol.self) {
            let router = TodoListRouterImpl(
                showAddSheet: { showingAddSheet = true },
                showEditSheet: { editingTodo = $0 }
            )
            listViewModel = TodoListViewModel(useCase: useCase, router: router)
        }
    }
}

/// Router implementation for todo list navigation
@MainActor
private final class TodoListRouterImpl: TodoListRouterProtocol {
    private let showAddSheet: () -> Void
    private let showEditSheet: (TodoItemAdapter) -> Void

    init(
        showAddSheet: @escaping () -> Void,
        showEditSheet: @escaping (TodoItemAdapter) -> Void
    ) {
        self.showAddSheet = showAddSheet
        self.showEditSheet = showEditSheet
    }

    func navigateToAddTodo() {
        showAddSheet()
    }

    func navigateToEditTodo(_ todo: TodoItemAdapter) {
        showEditSheet(todo)
    }
}

/// Coordinator for charts view (minimal since no navigation needed)
private struct ChartsCoordinator: View {
    private let container: DIContainer
    @State private var chartsViewModel: ChartsViewModel?

    init(container: DIContainer) {
        self.container = container
    }

    var body: some View {
        // Build view model once on first render
        if chartsViewModel == nil {
            Color.clear.onAppear {
                buildViewModel()
            }
        } else if let viewModel = chartsViewModel {
            ChartsView(viewModel: viewModel)
        } else {
            Text("Failed to initialize")
                .foregroundStyle(.red)
        }
    }

    private func buildViewModel() {
        if let useCase = try? container.requireResolve(TodoUseCaseProtocol.self) {
            let router = ChartsRouterImpl()
            chartsViewModel = ChartsViewModel(useCase: useCase, router: router)
        }
    }
}

/// Router implementation for charts (currently empty)
@MainActor
private final class ChartsRouterImpl: ChartsRouterProtocol {
    // No navigation methods needed yet
}

extension TodoItemAdapter: Identifiable {}

// MARK: - Preview

#Preview("Tab Bar with Todos") {
    TabBarView(container: DevPreview.shared.container)
        .modelContainer(DevPreview.shared.modelContainer)
}
