import SwiftUI

/// Reusable empty state view
public struct EmptyStateView: View {
    public let icon: String
    public let message: String
    public let actionTitle: String
    public let action: () -> Void

    public init(
        icon: String,
        message: String,
        actionTitle: String,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        ContentUnavailableView {
            Label(message, systemImage: icon)
        } description: {
            Text("Get started by adding your first todo")
        } actions: {
            Button(actionTitle, systemImage: "plus", action: action)
                .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Preview

#Preview("Empty State - No Todos") {
    EmptyStateView(
        icon: "checklist",
        message: "No todos yet",
        actionTitle: "Add Todo",
        action: { print("Add todo tapped") }
    )
}

#Preview("Empty State - No Results") {
    EmptyStateView(
        icon: "magnifyingglass",
        message: "No results found",
        actionTitle: "Clear Filter",
        action: { print("Clear filter tapped") }
    )
}
