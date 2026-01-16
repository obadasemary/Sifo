import SwiftUI
import Charts
import TodoUseCase

/// Bar chart showing overdue, due today, and upcoming todos
struct TimelineChartView: View {
    let statistics: TodoStatistics

    private struct ChartData: Identifiable {
        let id = UUID()
        let status: String
        let count: Int
        let color: Color
    }

    private var chartData: [ChartData] {
        [
            ChartData(status: "Overdue", count: statistics.overdueTodos, color: .red),
            ChartData(status: "Today", count: statistics.dueTodayTodos, color: .orange),
            ChartData(status: "Upcoming", count: statistics.upcomingTodos, color: .blue)
        ].filter { $0.count > 0 } // Only show statuses with todos
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Timeline")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if chartData.isEmpty {
                Text("No due date data available")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(height: 150)
            } else {
                Chart(chartData) { item in
                    BarMark(
                        x: .value("Status", item.status),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(item.color)
                    .annotation(position: .top) {
                        Text("\(item.count)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }
}
