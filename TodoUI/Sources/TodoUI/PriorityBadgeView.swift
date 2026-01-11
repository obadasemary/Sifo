import SwiftUI
import TodoUseCase

/// View for displaying priority badge with icon
public struct PriorityBadgeView: View {
    public let priority: TodoPriority

    public init(priority: TodoPriority) {
        self.priority = priority
    }

    public var body: some View {
        if priority != .none {
            Label(priority.displayName, systemImage: priority.systemImageName)
                .font(.caption)
                .foregroundStyle(colorForPriority)
        }
    }

    private var colorForPriority: Color {
        switch priority {
        case .none:
            return .secondary
        case .low:
            return .blue
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
}
