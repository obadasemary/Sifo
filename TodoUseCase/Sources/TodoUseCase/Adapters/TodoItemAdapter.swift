import Foundation
import SwiftData
//import TodoRepository

/// Adapter for Todo model - decouples SwiftData from presentation layer
/// Provides computed properties optimized for UI display
public struct TodoItemAdapter: Identifiable, Hashable, Sendable {
    public let id: PersistentIdentifier
    public let title: String
    public let notes: String
    public let isCompleted: Bool
    public let dueDate: Date?
    public let priority: TodoPriority
    public let categories: [CategoryAdapter]
    public let createdAt: Date

    public init(
        id: PersistentIdentifier,
        title: String,
        notes: String,
        isCompleted: Bool,
        dueDate: Date?,
        priority: TodoPriority,
        categories: [CategoryAdapter],
        createdAt: Date
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.priority = priority
        self.categories = categories
        self.createdAt = createdAt
    }

    // MARK: - Computed Properties for UI

    /// Check if due date is today
    public var isDueToday: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }

    /// Check if todo is overdue
    public var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return dueDate < Date() && !isCompleted
    }

    /// Formatted due date string
    public var dueDateFormatted: String? {
        guard let dueDate = dueDate else { return nil }
        return dueDate.formatted(date: .abbreviated, time: .omitted)
    }

    /// Has notes content
    public var hasNotes: Bool {
        !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Factory Method

    /// Create adapter from SwiftData Todo model
    public static func from(_ todo: Todo) -> TodoItemAdapter {
        TodoItemAdapter(
            id: todo.persistentModelID,
            title: todo.title,
            notes: todo.notes,
            isCompleted: todo.isCompleted,
            dueDate: todo.dueDate,
            priority: todo.priority,
            categories: todo.categories?.map(CategoryAdapter.from) ?? [],
            createdAt: todo.createdAt
        )
    }
}
