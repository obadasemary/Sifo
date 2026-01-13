import SwiftUI

/// Reusable error view with retry action
public struct ErrorView: View {
    public let message: String
    public let retryAction: () -> Void

    public init(message: String, retryAction: @escaping () -> Void) {
        self.message = message
        self.retryAction = retryAction
    }

    public var body: some View {
        ContentUnavailableView {
            Label("Error", systemImage: "exclamationmark.triangle.fill")
        } description: {
            Text(message)
        } actions: {
            Button("Retry", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Preview

#Preview("Error - Network Failure") {
    ErrorView(
        message: "Failed to load todos. Please check your internet connection.",
        retryAction: { print("Retry tapped") }
    )
}

#Preview("Error - Generic") {
    ErrorView(
        message: "Something went wrong. Please try again.",
        retryAction: { print("Retry tapped") }
    )
}

#Preview("Error - Long Message") {
    ErrorView(
        message: "An unexpected error occurred while processing your request. The server might be temporarily unavailable or you may have lost your internet connection. Please try again in a few moments.",
        retryAction: { print("Retry tapped") }
    )
}
