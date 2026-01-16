import SwiftUI
import Charts
import TodoUseCase

/// Bar chart showing todo count by priority
struct PriorityChartView: View {
    let statistics: TodoStatistics

    private struct ChartData: Identifiable {
        let id = UUID()
        let priority: String
        let count: Int
        let color: Color
    }

    private var chartData: [ChartData] {
        [
            ChartData(priority: "None", count: statistics.noPriorityCount, color: .gray),
            ChartData(priority: "Low", count: statistics.lowPriorityCount, color: .blue),
            ChartData(priority: "Medium", count: statistics.mediumPriorityCount, color: .orange),
            ChartData(priority: "High", count: statistics.highPriorityCount, color: .red)
        ].filter { $0.count > 0 } // Only show priorities with todos
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Tasks by Priority")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if chartData.isEmpty {
                Text("No priority data available")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(height: 150)
            } else {
                Chart(chartData) { item in
                    BarMark(
                        x: .value("Priority", item.priority),
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
