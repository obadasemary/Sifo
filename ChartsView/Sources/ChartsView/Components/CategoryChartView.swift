import SwiftUI
import Charts
import TodoUseCase

/// Horizontal bar chart showing top 5 categories by todo count
struct CategoryChartView: View {
    let statistics: TodoStatistics

    var body: some View {
        VStack(spacing: 12) {
            Text("Top Categories")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Chart(statistics.topCategories) { category in
                BarMark(
                    x: .value("Count", category.todoCount),
                    y: .value("Category", category.name)
                )
                .foregroundStyle(Color(hex: category.colorHex) ?? .blue)
                .annotation(position: .trailing) {
                    Text("\(category.todoCount)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: CGFloat(statistics.topCategories.count * 40 + 20))
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
