import SwiftData
import Foundation

/// SwiftData model for a category
/// CloudKit-compatible: all properties have defaults or are optional
/// Note: @Model macro handles actor isolation in Swift 6 - no @MainActor needed
@Model
public final class Category {
    public var name: String = ""
    public var colorHex: String = "#007AFF" // Default blue
    public var createdAt: Date = Date()

    // Relationships (optional for CloudKit compatibility)
    @Relationship(deleteRule: .nullify)
    public var todos: [Todo]? = []

    public init(
        name: String = "",
        colorHex: String = "#007AFF"
    ) {
        self.name = name
        self.colorHex = colorHex
        self.createdAt = Date()
    }
}
