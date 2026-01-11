import Foundation
import Observation
import DependencyContainer

/// Builder for composing TabBarView with dependencies
@MainActor
@Observable
public final class TabBarBuilder {
    private let container: DIContainer

    public init(container: DIContainer) {
        self.container = container
    }

    /// Build TabBarView with dependencies resolved
    /// - Returns: Configured TabBarView
    public func buildTabBarView() -> TabBarView {
        return TabBarView(container: container)
    }
}
