import Foundation

/// Filter options for displaying todos
public enum FilterOption: String, CaseIterable, Identifiable, Sendable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"

    public var id: String { rawValue }

    /// Maps filter option to completion status for repository queries
    public var completionFilter: Bool? {
        switch self {
        case .all: return nil
        case .active: return false
        case .completed: return true
        }
    }
}
