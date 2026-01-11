import SwiftUI
import TodoRepository
import TodoUseCase

/// Reusable row view for displaying a todo item
public struct TodoRowView: View {
    public let todo: TodoItemAdapter
    public let toggleAction: () -> Void
    public let tapAction: () -> Void

    public init(
        todo: TodoItemAdapter,
        toggleAction: @escaping () -> Void,
        tapAction: @escaping () -> Void
    ) {
        self.todo = todo
        self.toggleAction = toggleAction
        self.tapAction = tapAction
    }

    public var body: some View {
        Button(action: tapAction) {
            HStack(alignment: .top, spacing: 12) {
                // Checkbox
                Button(action: toggleAction) {
                    Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(todo.isCompleted ? .green : .secondary)
                }
                .buttonStyle(.plain)

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    Text(todo.title)
                        .font(.body)
                        .foregroundStyle(todo.isCompleted ? .secondary : .primary)
                        .strikethrough(todo.isCompleted)

                    // Notes preview
                    if todo.hasNotes {
                        Text(todo.notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    // Metadata row
                    HStack(spacing: 8) {
                        // Due date
                        if let dueDateText = todo.dueDateFormatted {
                            Label(dueDateText, systemImage: "calendar")
                                .font(.caption)
                                .foregroundStyle(todo.isOverdue ? .red : .secondary)
                        }

                        // Priority
                        PriorityBadgeView(priority: todo.priority)

                        Spacer()
                    }

                    // Categories
                    if !todo.categories.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(todo.categories) { category in
                                    CategoryTagView(
                                        name: category.name,
                                        color: category.color
                                    )
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
