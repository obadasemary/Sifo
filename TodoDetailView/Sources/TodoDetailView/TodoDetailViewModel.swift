import Foundation
import Observation
import SwiftData
import TodoUseCase

/// ViewModel for the todo detail/edit form
/// Implements form state machine pattern
@MainActor
@Observable
public final class TodoDetailViewModel {

    // MARK: - State Machine
    public enum State: Equatable {
        case editing(FormData)
        case saving
        case saved
        case error(String)

        public static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.editing(let l), .editing(let r)): return l == r
            case (.saving, .saving): return true
            case (.saved, .saved): return true
            case (.error(let l), .error(let r)): return l == r
            default: return false
            }
        }
    }

    public struct FormData: Equatable {
        public var title: String = ""
        public var notes: String = ""
        public var dueDate: Date? = nil
        public var hasDueDate: Bool = false
        public var priority: TodoPriority = .none
        public var selectedCategoryIds: Set<PersistentIdentifier> = []

        public var isValid: Bool {
            !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        public init(
            title: String = "",
            notes: String = "",
            dueDate: Date? = nil,
            hasDueDate: Bool = false,
            priority: TodoPriority = .none,
            selectedCategoryIds: Set<PersistentIdentifier> = []
        ) {
            self.title = title
            self.notes = notes
            self.dueDate = dueDate
            self.hasDueDate = hasDueDate
            self.priority = priority
            self.selectedCategoryIds = selectedCategoryIds
        }
    }

    // MARK: - Properties
    private let useCase: TodoUseCaseProtocol
    public let existingTodo: TodoItemAdapter?
    public var state: State
    public var availableCategories: [CategoryAdapter] = []

    // Direct property to fix binding issues with nested properties
    public var formData: FormData = FormData() {
        didSet {
            // Keep state in sync when formData changes
            if case .editing = state {
                state = .editing(formData)
            }
        }
    }

    public var isValid: Bool {
        formData.isValid
    }

    public var isSaving: Bool {
        if case .saving = state { return true }
        return false
    }

    // MARK: - Initialization
    public init(useCase: TodoUseCaseProtocol, existingTodo: TodoItemAdapter? = nil) {
        self.useCase = useCase
        self.existingTodo = existingTodo

        if let todo = existingTodo {
            // Edit mode - populate form with existing data
            let initialData = FormData(
                title: todo.title,
                notes: todo.notes,
                dueDate: todo.dueDate,
                hasDueDate: todo.dueDate != nil,
                priority: todo.priority,
                selectedCategoryIds: Set(todo.categories.map(\.id))
            )
            self.formData = initialData
            self.state = .editing(initialData)
        } else {
            // Add mode - start with empty form
            let initialData = FormData()
            self.formData = initialData
            self.state = .editing(initialData)
        }
    }

    // MARK: - Actions
    public func loadCategories() {
        Task {
            do {
                availableCategories = try await useCase.fetchCategories()
            } catch {
                // Handle silently or show inline error
                print("Failed to load categories: \(error)")
            }
        }
    }

    public func save() {
        guard formData.isValid else { return }

        state = .saving

        Task {
            do {
                if let existing = existingTodo {
                    // Update existing todo
                    try await useCase.updateTodo(
                        id: existing.id,
                        title: formData.title,
                        notes: formData.notes,
                        dueDate: formData.hasDueDate ? formData.dueDate : nil,
                        priority: formData.priority
                    )
                } else {
                    // Create new todo
                    _ = try await useCase.createTodo(
                        title: formData.title,
                        notes: formData.notes,
                        dueDate: formData.hasDueDate ? formData.dueDate : nil,
                        priority: formData.priority,
                        categoryIds: Array(formData.selectedCategoryIds)
                    )
                }
                state = .saved
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    public func toggleCategory(_ category: CategoryAdapter) {
        var data = formData
        if data.selectedCategoryIds.contains(category.id) {
            data.selectedCategoryIds.remove(category.id)
        } else {
            data.selectedCategoryIds.insert(category.id)
        }
        formData = data
    }
}
