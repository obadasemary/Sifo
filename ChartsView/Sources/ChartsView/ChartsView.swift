import SwiftUI
import Charts
import TodoUseCase
import TodoUI
import DevPreview

public struct ChartsView: View {
    @State public var viewModel: ChartsViewModel

    public init(viewModel: ChartsViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle:
                    Color.clear.onAppear { viewModel.loadStatistics() }

                case .loading:
                    ProgressView("Loading statistics...")

                case .loaded(let statistics):
                    statisticsContent(statistics)

                case .error(let message):
                    ErrorView(
                        message: message,
                        retryAction: { viewModel.loadStatistics() }
                    )
                }
            }
            .navigationTitle("Charts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Refresh", systemImage: "arrow.clockwise") {
                        viewModel.loadStatistics()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func statisticsContent(_ stats: TodoStatistics) -> some View {
        if stats.totalTodos == 0 {
            EmptyStateView(
                icon: "chart.bar",
                message: "No statistics yet",
                actionTitle: "Add Todos",
                action: { /* Navigate to todos tab */ }
            )
        } else {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary card
                    summaryCard(stats)

                    // Completion chart (donut chart)
                    CompletionChartView(statistics: stats)

                    // Priority breakdown (bar chart)
                    PriorityChartView(statistics: stats)

                    // Timeline chart (overdue, today, upcoming)
                    TimelineChartView(statistics: stats)

                    // Top categories (bar chart)
                    if !stats.topCategories.isEmpty {
                        CategoryChartView(statistics: stats)
                    }
                }
                .padding()
            }
        }
    }

    @ViewBuilder
    private func summaryCard(_ stats: TodoStatistics) -> some View {
        VStack(spacing: 12) {
            Text("Overview")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 20) {
                statItem(
                    title: "Total",
                    value: "\(stats.totalTodos)",
                    color: .blue
                )

                statItem(
                    title: "Completed",
                    value: "\(stats.completedTodos)",
                    color: .green
                )

                statItem(
                    title: "Active",
                    value: "\(stats.activeTodos)",
                    color: .orange
                )

                statItem(
                    title: "Rate",
                    value: "\(Int(stats.completionRate * 100))%",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    @ViewBuilder
    private func statItem(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .bold()
                .foregroundStyle(color)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview("Charts - Loaded") {
    let container = DevPreview.shared.container
    let useCase = try! container.requireResolve(TodoUseCaseProtocol.self)

    final class MockRouter: ChartsRouterProtocol {}

    let viewModel = ChartsViewModel(useCase: useCase, router: MockRouter())
    return ChartsView(viewModel: viewModel)
        .modelContainer(DevPreview.shared.modelContainer)
}

#Preview("Charts - Empty") {
    let container = DevPreview.shared.container
    let useCase = try! container.requireResolve(TodoUseCaseProtocol.self)

    final class MockRouter: ChartsRouterProtocol {}

    let viewModel = ChartsViewModel(useCase: useCase, router: MockRouter())
    viewModel.state = .loaded(.empty)

    return ChartsView(viewModel: viewModel)
        .modelContainer(DevPreview.shared.modelContainer)
}

#Preview("Charts - Error") {
    let container = DevPreview.shared.container
    let useCase = try! container.requireResolve(TodoUseCaseProtocol.self)

    final class MockRouter: ChartsRouterProtocol {}

    let viewModel = ChartsViewModel(useCase: useCase, router: MockRouter())
    viewModel.state = .error("Failed to load statistics. Please try again.")

    return ChartsView(viewModel: viewModel)
        .modelContainer(DevPreview.shared.modelContainer)
}
