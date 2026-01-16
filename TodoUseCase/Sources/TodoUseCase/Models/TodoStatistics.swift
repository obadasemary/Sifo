import Foundation

/// Statistics computed from todo data for charts display
public struct TodoStatistics: Equatable, Sendable {
    // Completion stats
    public let totalTodos: Int
    public let completedTodos: Int
    public let activeTodos: Int
    public let completionRate: Double  // 0.0 to 1.0

    // Priority breakdown
    public let noPriorityCount: Int
    public let lowPriorityCount: Int
    public let mediumPriorityCount: Int
    public let highPriorityCount: Int

    // Time-based stats
    public let overdueTodos: Int
    public let dueTodayTodos: Int
    public let upcomingTodos: Int

    // Category stats (top 5 for display)
    public let topCategories: [CategoryStatistic]

    public init(
        totalTodos: Int,
        completedTodos: Int,
        activeTodos: Int,
        completionRate: Double,
        noPriorityCount: Int,
        lowPriorityCount: Int,
        mediumPriorityCount: Int,
        highPriorityCount: Int,
        overdueTodos: Int,
        dueTodayTodos: Int,
        upcomingTodos: Int,
        topCategories: [CategoryStatistic]
    ) {
        self.totalTodos = totalTodos
        self.completedTodos = completedTodos
        self.activeTodos = activeTodos
        self.completionRate = completionRate
        self.noPriorityCount = noPriorityCount
        self.lowPriorityCount = lowPriorityCount
        self.mediumPriorityCount = mediumPriorityCount
        self.highPriorityCount = highPriorityCount
        self.overdueTodos = overdueTodos
        self.dueTodayTodos = dueTodayTodos
        self.upcomingTodos = upcomingTodos
        self.topCategories = topCategories
    }

    /// Empty statistics for no todos case
    public static var empty: TodoStatistics {
        TodoStatistics(
            totalTodos: 0,
            completedTodos: 0,
            activeTodos: 0,
            completionRate: 0,
            noPriorityCount: 0,
            lowPriorityCount: 0,
            mediumPriorityCount: 0,
            highPriorityCount: 0,
            overdueTodos: 0,
            dueTodayTodos: 0,
            upcomingTodos: 0,
            topCategories: []
        )
    }
}

/// Category statistics for top categories display
public struct CategoryStatistic: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let colorHex: String
    public let todoCount: Int

    public init(name: String, colorHex: String, todoCount: Int) {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.todoCount = todoCount
    }
}
