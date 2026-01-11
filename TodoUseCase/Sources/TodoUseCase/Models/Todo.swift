import SwiftData
import Foundation

/// SwiftData model for a todo item
/// CloudKit-compatible: all properties have defaults or are optional, no unique attributes
/// Note: @Model macro handles actor isolation in Swift 6 - no @MainActor needed
@Model
public final class Todo {
    // Primary fields
    public var title: String = ""
    public var notes: String = ""

    // Status
    public var isCompleted: Bool = false
    public var createdAt: Date = Date()
    public var dueDate: Date? = nil

    // Priority (stored as Int for SwiftData compatibility)
    public var priorityRawValue: Int = 0 // 0=none, 1=low, 2=medium, 3=high

    // Ordering support for drag & drop
    public var sortOrder: Int = 0

    // Relationships (optional for CloudKit compatibility)
    @Relationship(deleteRule: .nullify, inverse: \Category.todos)
    public var categories: [Category]? = []

    public init(
        title: String = "",
        notes: String = "",
        isCompleted: Bool = false,
        dueDate: Date? = nil,
        priorityRawValue: Int = 0,
        sortOrder: Int = 0
    ) {
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.priorityRawValue = priorityRawValue
        self.sortOrder = sortOrder
        self.createdAt = Date()
    }
}

// Computed property helper (extension)
extension Todo {
    /// Priority level as enum
    public var priority: TodoPriority {
        get { TodoPriority(rawValue: priorityRawValue) ?? .none }
        set { priorityRawValue = newValue.rawValue }
    }
}
