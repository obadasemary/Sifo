import Testing
import SwiftData
@testable import ChartsView
import TodoUseCase

@MainActor
@Suite("ChartsViewModel Tests")
struct ChartsViewModelTests {

    @Test("Load statistics updates state to loaded")
    func testLoadStatisticsSuccess() async throws {
        // Arrange
        let fakeUseCase = FakeTodoUseCase()
        fakeUseCase.statistics = TodoStatistics(
            totalTodos: 10,
            completedTodos: 6,
            activeTodos: 4,
            completionRate: 0.6,
            noPriorityCount: 2,
            lowPriorityCount: 3,
            mediumPriorityCount: 3,
            highPriorityCount: 2,
            overdueTodos: 1,
            dueTodayTodos: 2,
            upcomingTodos: 1,
            topCategories: []
        )
        let fakeRouter = FakeChartsRouter()
        let viewModel = ChartsViewModel(useCase: fakeUseCase, router: fakeRouter)

        // Act
        viewModel.loadStatistics()
        try await Task.sleep(for: .milliseconds(100))

        // Assert
        #expect(viewModel.state == .loaded(fakeUseCase.statistics!))
        #expect(viewModel.statistics?.totalTodos == 10)
        #expect(viewModel.statistics?.completionRate == 0.6)
    }

    @Test("Load statistics failure updates state to error")
    func testLoadStatisticsError() async throws {
        // Arrange
        let fakeUseCase = FakeTodoUseCase()
        fakeUseCase.shouldThrowError = true
        let fakeRouter = FakeChartsRouter()
        let viewModel = ChartsViewModel(useCase: fakeUseCase, router: fakeRouter)

        // Act
        viewModel.loadStatistics()
        try await Task.sleep(for: .milliseconds(100))

        // Assert
        if case .error = viewModel.state {
            // Success - state is error
        } else {
            Issue.record("Expected error state")
        }
    }

    @Test("Empty statistics handled correctly")
    func testEmptyStatistics() async throws {
        let fakeUseCase = FakeTodoUseCase()
        fakeUseCase.statistics = .empty
        let viewModel = ChartsViewModel(useCase: fakeUseCase, router: FakeChartsRouter())

        viewModel.loadStatistics()
        try await Task.sleep(for: .milliseconds(100))

        #expect(viewModel.statistics?.totalTodos == 0)
        #expect(viewModel.statistics?.completionRate == 0)
    }

    @Test("Computed property isLoading returns correct value")
    func testIsLoadingProperty() {
        let fakeUseCase = FakeTodoUseCase()
        let viewModel = ChartsViewModel(useCase: fakeUseCase, router: FakeChartsRouter())

        // Idle state
        #expect(viewModel.isLoading == false)

        // Loading state
        viewModel.state = .loading
        #expect(viewModel.isLoading == true)

        // Loaded state
        viewModel.state = .loaded(.empty)
        #expect(viewModel.isLoading == false)

        // Error state
        viewModel.state = .error("Test error")
        #expect(viewModel.isLoading == false)
    }

    @Test("Computed property statistics returns correct value")
    func testStatisticsProperty() {
        let fakeUseCase = FakeTodoUseCase()
        let viewModel = ChartsViewModel(useCase: fakeUseCase, router: FakeChartsRouter())

        // Idle state
        #expect(viewModel.statistics == nil)

        // Loading state
        viewModel.state = .loading
        #expect(viewModel.statistics == nil)

        // Loaded state
        let stats = TodoStatistics.empty
        viewModel.state = .loaded(stats)
        #expect(viewModel.statistics == stats)

        // Error state
        viewModel.state = .error("Test error")
        #expect(viewModel.statistics == nil)
    }

    @Test("Computed property errorMessage returns correct value")
    func testErrorMessageProperty() {
        let fakeUseCase = FakeTodoUseCase()
        let viewModel = ChartsViewModel(useCase: fakeUseCase, router: FakeChartsRouter())

        // Idle state
        #expect(viewModel.errorMessage == nil)

        // Loading state
        viewModel.state = .loading
        #expect(viewModel.errorMessage == nil)

        // Loaded state
        viewModel.state = .loaded(.empty)
        #expect(viewModel.errorMessage == nil)

        // Error state
        viewModel.state = .error("Test error message")
        #expect(viewModel.errorMessage == "Test error message")
    }
}

// MARK: - Test Doubles

@MainActor
final class FakeTodoUseCase: TodoUseCaseProtocol {
    var todos: [TodoItemAdapter] = []
    var statistics: TodoStatistics?
    var shouldThrowError = false

    func fetchTodoStatistics() async throws -> TodoStatistics {
        if shouldThrowError {
            throw TodoError.unknown("Test error")
        }
        return statistics ?? .empty
    }

    // Implement other protocol methods as needed for compilation
    func fetchTodos(filter: FilterOption) async throws -> [TodoItemAdapter] { todos }
    func fetchTodo(byId id: PersistentIdentifier) async throws -> TodoItemAdapter? { nil }
    func createTodo(title: String, notes: String, dueDate: Date?, priority: TodoPriority, categoryIds: [PersistentIdentifier]) async throws -> TodoItemAdapter {
        fatalError("Not implemented in test double")
    }
    func updateTodo(id: PersistentIdentifier, title: String, notes: String, dueDate: Date?, priority: TodoPriority) async throws {}
    func toggleTodoCompletion(id: PersistentIdentifier) async throws {}
    func deleteTodo(id: PersistentIdentifier) async throws {}
    func reorderTodos(from source: IndexSet, to destination: Int, in adapters: [TodoItemAdapter]) async throws {}
    func fetchCategories() async throws -> [CategoryAdapter] { [] }
    func createCategory(name: String, colorHex: String) async throws -> CategoryAdapter {
        fatalError("Not implemented in test double")
    }
}

@MainActor
final class FakeChartsRouter: ChartsRouterProtocol {
    // No methods yet
}
