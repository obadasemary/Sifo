import Foundation
import Observation
import TodoUseCase

/// ViewModel for the charts feature
/// Implements state machine pattern for clear state transitions
@MainActor
@Observable
public final class ChartsViewModel {

    // MARK: - State Machine
    public enum State: Equatable {
        case idle
        case loading
        case loaded(TodoStatistics)
        case error(String)

        public static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle): return true
            case (.loading, .loading): return true
            case (.loaded(let l), .loaded(let r)): return l == r
            case (.error(let l), .error(let r)): return l == r
            default: return false
            }
        }
    }

    // MARK: - Properties
    private let useCase: TodoUseCaseProtocol
    private let router: ChartsRouterProtocol

    public var state: State = .idle

    // Computed properties
    public var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    public var statistics: TodoStatistics? {
        if case .loaded(let stats) = state { return stats }
        return nil
    }

    public var errorMessage: String? {
        if case .error(let message) = state { return message }
        return nil
    }

    // MARK: - Initialization
    public init(useCase: TodoUseCaseProtocol, router: ChartsRouterProtocol) {
        self.useCase = useCase
        self.router = router
    }

    // MARK: - Actions
    public func loadStatistics() {
        state = .loading
        Task {
            do {
                let stats = try await useCase.fetchTodoStatistics()
                state = .loaded(stats)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
}
