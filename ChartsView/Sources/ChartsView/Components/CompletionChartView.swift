import SwiftUI
import Charts
import TodoUseCase

/// Donut chart showing completed vs active todos
struct CompletionChartView: View {
    let statistics: TodoStatistics

    private struct ChartData: Identifiable {
        let id = UUID()
        let label: String
        let count: Int
        let color: Color
    }

    private var chartData: [ChartData] {
        [
            ChartData(label: "Completed", count: statistics.completedTodos, color: .green),
            ChartData(label: "Active", count: statistics.activeTodos, color: .orange)
        ]
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Completion Status")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Chart(chartData) { item in
                SectorMark(
                    angle: .value("Count", item.count),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(item.color)
                .annotation(position: .overlay) {
                    if item.count > 0 {
                        Text("\(item.count)")
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.white)
                    }
                }
            }
            .frame(height: 200)
            .chartBackground { _ in
                VStack {
                    Text("\(Int(statistics.completionRate * 100))%")
                        .font(.title)
                        .bold()
                    Text("Complete")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Legend
            HStack(spacing: 20) {
                ForEach(chartData) { item in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 8, height: 8)
                        Text(item.label)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }
}
