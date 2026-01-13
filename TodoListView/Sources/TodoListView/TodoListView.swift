import SwiftUI
import TodoUseCase
import TodoUI
import DevPreview

public struct TodoListView: View {
    @State public var viewModel: TodoListViewModel

    public init(viewModel: TodoListViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle:
                    Color.clear.onAppear { viewModel.loadTodos() }

                case .loading:
                    ProgressView("Loading todos...")

                case .loaded(let todos):
                    todoListContent(todos)

                case .error(let message):
                    ErrorView(
                        message: message,
                        retryAction: { viewModel.loadTodos() }
                    )

                case .deleting:
                    todoListContent(viewModel.todos) // Show list with confirmation alert
                }
            }
            .navigationTitle("Todos")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add", systemImage: "plus") {
                        viewModel.addTodoTapped()
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
            .alert("Delete Todo?", isPresented: deleteConfirmationBinding) {
                Button("Cancel", role: .cancel) {
                    viewModel.cancelDelete()
                }
                Button("Delete", role: .destructive) {
                    viewModel.confirmDelete()
                }
            }
        }
    }

    @ViewBuilder
    private func todoListContent(_ todos: [TodoItemAdapter]) -> some View {
        VStack(spacing: 0) {
            // Always show filter picker
            filterPicker
                .padding(.horizontal)
                .padding(.top, 8)

            // Show list or empty state
            if todos.isEmpty {
                EmptyStateView(
                    icon: "checklist",
                    message: "No todos yet",
                    actionTitle: "Add Todo",
                    action: { viewModel.addTodoTapped() }
                )
            } else {
                List {
                    ForEach(todos) { todo in
                        TodoRowView(
                            todo: todo,
                            toggleAction: { viewModel.toggleCompletion(for: todo) },
                            tapAction: { viewModel.editTodoTapped(todo) }
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                viewModel.deleteTodoConfirmation(for: todo)
                            }
                        }
                    }
                    .onMove { source, destination in
                        viewModel.reorderTodos(from: source, to: destination)
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    private var filterPicker: some View {
        Picker("Filter", selection: currentFilterBinding) {
            ForEach(FilterOption.allCases) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(.segmented)
    }

    private var currentFilterBinding: Binding<FilterOption> {
        Binding(
            get: { viewModel.currentFilter },
            set: { newValue in
                viewModel.filterChanged(to: newValue)
            }
        )
    }

    private var deleteConfirmationBinding: Binding<Bool> {
        Binding(
            get: {
                if case .deleting = viewModel.state { return true }
                return false
            },
            set: { if !$0 { viewModel.cancelDelete() } }
        )
    }
}

// MARK: - Preview

#Preview("Todo List - Loaded") {
    let container = DevPreview.shared.container
    let useCase = try! container.requireResolve(TodoUseCaseProtocol.self)

    // Mock router for preview
    final class MockRouter: TodoListRouterProtocol {
        func navigateToAddTodo() {
            print("Navigate to add todo")
        }

        func navigateToEditTodo(_ todo: TodoItemAdapter) {
            print("Navigate to edit todo: \(todo.title)")
        }
    }

    let viewModel = TodoListViewModel(useCase: useCase, router: MockRouter())
    return TodoListView(viewModel: viewModel)
        .modelContainer(DevPreview.shared.modelContainer)
}

#Preview("Todo List - Empty") {
    let container = DevPreview.shared.container
    let useCase = try! container.requireResolve(TodoUseCaseProtocol.self)

    // Mock router for preview
    final class MockRouter: TodoListRouterProtocol {
        func navigateToAddTodo() {
            print("Navigate to add todo")
        }

        func navigateToEditTodo(_ todo: TodoItemAdapter) {
            print("Navigate to edit todo: \(todo.title)")
        }
    }

    let viewModel = TodoListViewModel(useCase: useCase, router: MockRouter())
    viewModel.currentFilter = .completed // Show completed filter (likely empty)

    return TodoListView(viewModel: viewModel)
        .modelContainer(DevPreview.shared.modelContainer)
}

#Preview("Todo List - Error") {
    let container = DevPreview.shared.container
    let useCase = try! container.requireResolve(TodoUseCaseProtocol.self)

    // Mock router for preview
    final class MockRouter: TodoListRouterProtocol {
        func navigateToAddTodo() {
            print("Navigate to add todo")
        }

        func navigateToEditTodo(_ todo: TodoItemAdapter) {
            print("Navigate to edit todo: \(todo.title)")
        }
    }

    let viewModel = TodoListViewModel(useCase: useCase, router: MockRouter())
    viewModel.state = .error("Failed to load todos. Please try again.")

    return TodoListView(viewModel: viewModel)
        .modelContainer(DevPreview.shared.modelContainer)
}
