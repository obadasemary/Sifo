import Foundation
import SwiftData
import SwiftUI
//import TodoRepository

/// Adapter for Category model - decouples SwiftData from presentation layer
public struct CategoryAdapter: Identifiable, Hashable, Sendable {
    public let id: PersistentIdentifier
    public let name: String
    public let colorHex: String

    public init(id: PersistentIdentifier, name: String, colorHex: String) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }

    /// Create adapter from SwiftData Category model
    public static func from(_ category: Category) -> CategoryAdapter {
        CategoryAdapter(
            id: category.persistentModelID,
            name: category.name,
            colorHex: category.colorHex
        )
    }
}

/// Color extension for hex string parsing
extension Color {
    public init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

extension CategoryAdapter {
    /// Get SwiftUI Color from hex
    public var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}
