import SwiftUI

/// View for displaying a category tag with color
public struct CategoryTagView: View {
    public let name: String
    public let color: Color

    public init(name: String, color: Color) {
        self.name = name
        self.color = color
    }

    public var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(name)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .clipShape(.rect(cornerRadius: 4))
    }
}
