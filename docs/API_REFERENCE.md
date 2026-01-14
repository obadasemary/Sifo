# Sifo API Reference

Complete API documentation for all modules in the Sifo iOS application.

## Table of Contents

1. [DependencyContainer](#dependencycontainer)
2. [TodoUseCase](#todousecase)
3. [TodoRepository](#todorepository)
4. [TodoListView](#todolistview)
5. [TodoDetailView](#tododetailview)
6. [TodoUI](#todoui)
7. [TabBarView](#tabbarview)
8. [DevPreview](#devpreview)
9. [Models & DTOs](#models--dtos)
10. [Protocols](#protocols)

---

## DependencyContainer

**Package**: `DependencyContainer`
**Location**: `DependencyContainer/Sources/DependencyContainer/DIContainer.swift`

### DIContainer

A simple, type-safe dependency injection container with `@MainActor` and `@Observable` support.

```swift
@MainActor
@Observable
public final class DIContainer
```

#### Properties

None (internal services dictionary)

#### Methods

##### register

Registers a service instance for a given type.

```swift
public func register<T>(_ type: T.Type, _ instance: T)
```

**Parameters:**
- `type`: The type to register (e.g., `TodoRepositoryProtocol.self`)
- `instance`: The concrete instance to provide when resolving this type

**Example:**
```swift
let container = DIContainer()
let repository = TodoRepository(modelContext: context)
container.register(TodoRepositoryProtocol.self, repository)
```

##### requireResolve

Resolves a registered service, throwing an error if not found.

```swift
public func requireResolve<T>(_ type: T.Type) throws -> T
```

**Parameters:**
- `type`: The type to resolve

**Returns:** The registered instance of the requested type

**Throws:** `DIError.notFound` if the type hasn't been registered

**Example:**
```swift
let useCase = try container.requireResolve(TodoUseCaseProtocol.self)
```

#### Errors

```swift
public enum DIError: Error {
    case notFound(String)
}
```

---

## TodoUseCase

**Package**: `TodoUseCase`
**Location**: `TodoUseCase/Sources/TodoUseCase/TodoUseCase.swift`

### TodoUseCase

Business logic implementation for todo management with validation and error handling.

```swift
@MainActor
public final class TodoUseCase: TodoUseCaseProtocol
```

#### Initialization

```swift
public init(container: DIContainer) throws
```

**Parameters:**
- `container`: DIContainer with registered TodoRepositoryProtocol

**Throws:** DIError if TodoRepositoryProtocol not registered

#### Fetch Operations

##### fetchTodos

Fetches todos filtered by completion status.

```swift
public func fetchTodos(filter: FilterOption) async throws -> [TodoItemAdapter]
```

**Parameters:**
- `filter`: Filter option (.all, .active, .completed)

**Returns:** Array of TodoItemAdapter DTOs

**Throws:**
- `TodoError.unknown` for unexpected errors

**Example:**
```swift
let activeTodos = try await useCase.fetchTodos(filter: .active)
```

##### fetchTodo

Fetches a single todo by ID.

```swift
public func fetchTodo(byId id: PersistentIdentifier) async throws -> TodoItemAdapter?
```

**Parameters:**
- `id`: SwiftData PersistentIdentifier

**Returns:** TodoItemAdapter if found, nil otherwise

**Throws:** `TodoError.unknown` for unexpected errors

#### CRUD Operations

##### createTodo

Creates a new todo with validation.

```swift
public func createTodo(
    title: String,
    notes: String,
    dueDate: Date?,
    priority: TodoPriority,
    categoryIds: [PersistentIdentifier]
) async throws -> TodoItemAdapter
```

**Parameters:**
- `title`: Todo title (required, will be trimmed)
- `notes`: Optional notes/description
- `dueDate`: Optional due date
- `priority`: Priority level (.none, .low, .medium, .high)
- `categoryIds`: Array of category IDs to associate

**Returns:** Newly created TodoItemAdapter

**Throws:**
- `TodoError.validation` if title is empty after trimming
- `TodoError.unknown` for other errors

**Example:**
```swift
let todo = try await useCase.createTodo(
    title: "Buy groceries",
    notes: "Milk, eggs, bread",
    dueDate: Date().addingTimeInterval(86400),
    priority: .medium,
    categoryIds: []
)
```

##### updateTodo

Updates an existing todo.

```swift
public func updateTodo(
    id: PersistentIdentifier,
    title: String,
    notes: String,
    dueDate: Date?,
    priority: TodoPriority
) async throws
```

**Parameters:**
- `id`: Todo identifier
- `title`: Updated title (required, will be trimmed)
- `notes`: Updated notes
- `dueDate`: Updated due date
- `priority`: Updated priority

**Throws:**
- `TodoError.validation` if title is empty
- `TodoError.notFound` if todo doesn't exist
- `TodoError.unknown` for other errors

##### toggleTodoCompletion

Toggles the completion status of a todo.

```swift
public func toggleTodoCompletion(id: PersistentIdentifier) async throws
```

**Parameters:**
- `id`: Todo identifier

**Throws:**
- `TodoError.notFound` if todo doesn't exist
- `TodoError.unknown` for other errors

##### deleteTodo

Deletes a todo.

```swift
public func deleteTodo(id: PersistentIdentifier) async throws
```

**Parameters:**
- `id`: Todo identifier

**Throws:**
- `TodoError.notFound` if todo doesn't exist
- `TodoError.unknown` for other errors

##### reorderTodos

Reorders todos via drag and drop.

```swift
public func reorderTodos(
    from source: IndexSet,
    to destination: Int,
    in adapters: [TodoItemAdapter]
) async throws
```

**Parameters:**
- `source`: Source indices being moved
- `destination`: Destination index
- `adapters`: Current todo list

**Throws:** `TodoError.unknown` for errors

#### Category Operations

##### fetchCategories

Fetches all categories.

```swift
public func fetchCategories() async throws -> [CategoryAdapter]
```

**Returns:** Array of CategoryAdapter DTOs

**Throws:** `TodoError.unknown` for errors

##### createCategory

Creates a new category.

```swift
public func createCategory(name: String, colorHex: String) async throws -> CategoryAdapter
```

**Parameters:**
- `name`: Category name (required, will be trimmed)
- `colorHex`: Hex color code (e.g., "#007AFF")

**Returns:** Newly created CategoryAdapter

**Throws:**
- `TodoError.validation` if name is empty
- `TodoError.unknown` for other errors

---

## TodoRepository

**Package**: `TodoRepository`
**Location**: `TodoRepository/Sources/TodoRepository/TodoRepository.swift`

### TodoRepository

SwiftData persistence implementation.

```swift
@MainActor
public final class TodoRepository: TodoRepositoryProtocol
```

#### Initialization

```swift
public init(modelContext: ModelContext)
```

**Parameters:**
- `modelContext`: SwiftData ModelContext for persistence operations

#### Methods

##### fetchTodos

Fetches todos with optional completion filter.

```swift
public func fetchTodos(isCompleted: Bool?) async throws -> [Todo]
```

**Parameters:**
- `isCompleted`: Optional completion filter (nil = all, true = completed, false = active)

**Returns:** Array of Todo SwiftData models sorted by sortOrder

**Throws:** SwiftData errors

##### fetchTodo

Fetches a single todo by ID.

```swift
public func fetchTodo(byId id: PersistentIdentifier) async throws -> Todo?
```

**Parameters:**
- `id`: PersistentIdentifier

**Returns:** Todo model if found, nil otherwise

##### fetchAllTodos

Fetches all todos without filtering.

```swift
public func fetchAllTodos() async throws -> [Todo]
```

**Returns:** All todos sorted by sortOrder

##### createTodo

Creates a new todo.

```swift
public func createTodo(
    title: String,
    notes: String,
    dueDate: Date?,
    priority: TodoPriority
) async throws -> Todo
```

**Parameters:**
- `title`: Todo title
- `notes`: Notes/description
- `dueDate`: Optional due date
- `priority`: Priority level

**Returns:** Newly created Todo model

**Throws:** SwiftData errors

**Note:** Automatically assigns sortOrder based on existing todos

##### updateTodo

Updates an existing todo.

```swift
public func updateTodo(_ todo: Todo) async throws
```

**Parameters:**
- `todo`: Todo model to update (modifications already made)

**Throws:** SwiftData errors

##### deleteTodo

Deletes a todo.

```swift
public func deleteTodo(_ todo: Todo) async throws
```

**Parameters:**
- `todo`: Todo model to delete

**Throws:** SwiftData errors

##### reorderTodos

Reorders todos and updates sortOrder.

```swift
public func reorderTodos(
    from source: IndexSet,
    to destination: Int,
    in todos: [Todo]
) async throws
```

**Parameters:**
- `source`: Source indices
- `destination`: Destination index
- `todos`: Current ordered list

**Throws:** SwiftData errors

**Note:** Updates sortOrder property for all affected todos

##### fetchAllCategories

Fetches all categories.

```swift
public func fetchAllCategories() async throws -> [Category]
```

**Returns:** All categories sorted by name

##### createCategory

Creates a new category.

```swift
public func createCategory(name: String, colorHex: String) async throws -> Category
```

**Parameters:**
- `name`: Category name
- `colorHex`: Hex color code

**Returns:** Newly created Category model

##### addCategory

Associates a category with a todo.

```swift
public func addCategory(_ category: Category, to todo: Todo) async throws
```

**Parameters:**
- `category`: Category to add
- `todo`: Todo to associate with

**Throws:** SwiftData errors

---

## TodoListView

**Package**: `TodoListView`
**Location**: `TodoListView/Sources/TodoListView/`

### TodoListViewModel

State machine-based view model for todo list.

```swift
@MainActor
@Observable
public final class TodoListViewModel
```

#### State

```swift
public enum State: Equatable {
    case idle
    case loading
    case loaded([TodoItemAdapter])
    case error(String)
    case deleting(TodoItemAdapter)
}
```

#### Properties

```swift
public var state: State
public var currentFilter: FilterOption
public var isLoading: Bool { get }
public var todos: [TodoItemAdapter] { get }
public var errorMessage: String? { get }
```

#### Initialization

```swift
public init(useCase: TodoUseCaseProtocol, router: TodoListRouterProtocol)
```

**Parameters:**
- `useCase`: Business logic implementation
- `router`: Navigation handler

#### Actions

##### loadTodos

Loads todos based on current filter.

```swift
public func loadTodos()
```

**Side Effects:**
- Sets state to .loading
- Fetches todos asynchronously
- Updates state to .loaded or .error

##### filterChanged

Changes the active filter.

```swift
public func filterChanged(to filter: FilterOption)
```

**Parameters:**
- `filter`: New filter option

**Side Effects:** Reloads todos with new filter

##### toggleCompletion

Toggles todo completion status.

```swift
public func toggleCompletion(for todo: TodoItemAdapter)
```

**Parameters:**
- `todo`: Todo to toggle

**Side Effects:** Updates todo and reloads list

##### deleteTodoConfirmation

Shows delete confirmation.

```swift
public func deleteTodoConfirmation(for todo: TodoItemAdapter)
```

**Parameters:**
- `todo`: Todo to delete

**Side Effects:** Changes state to .deleting

##### confirmDelete

Confirms and executes deletion.

```swift
public func confirmDelete()
```

**Side Effects:** Deletes todo and reloads list

##### cancelDelete

Cancels deletion.

```swift
public func cancelDelete()
```

**Side Effects:** Returns to loaded state

##### reorderTodos

Reorders todos via drag and drop.

```swift
public func reorderTodos(from source: IndexSet, to destination: Int)
```

**Parameters:**
- `source`: Source indices
- `destination`: Destination index

**Side Effects:** Reorders and reloads list

##### addTodoTapped

Navigates to add todo.

```swift
public func addTodoTapped()
```

**Side Effects:** Calls router.navigateToAddTodo()

##### editTodoTapped

Navigates to edit todo.

```swift
public func editTodoTapped(_ todo: TodoItemAdapter)
```

**Parameters:**
- `todo`: Todo to edit

**Side Effects:** Calls router.navigateToEditTodo(todo)

### TodoListBuilder

Factory for creating TodoListView with dependencies.

```swift
@MainActor
@Observable
public final class TodoListBuilder
```

#### Methods

```swift
public func buildTodoListView(router: TodoListRouterProtocol) throws -> TodoListView
```

**Parameters:**
- `router`: Navigation router implementation

**Returns:** Configured TodoListView

**Throws:** DIError if dependencies not registered

---

## TodoDetailView

**Package**: `TodoDetailView`
**Location**: `TodoDetailView/Sources/TodoDetailView/`

### TodoDetailViewModel

State machine for todo add/edit form.

```swift
@MainActor
@Observable
public final class TodoDetailViewModel
```

#### State

```swift
public enum State: Equatable {
    case editing(FormData)
    case saving
    case saved
    case error(String)
}

public struct FormData: Equatable {
    public var title: String
    public var notes: String
    public var dueDate: Date?
    public var hasDueDate: Bool
    public var priority: TodoPriority
    public var selectedCategoryIds: Set<PersistentIdentifier>

    public var isValid: Bool { get }
}
```

#### Properties

```swift
public var state: State
public var formData: FormData
public var isValid: Bool { get }
public var isSaving: Bool { get }
```

#### Initialization

```swift
public init(
    useCase: TodoUseCaseProtocol,
    existingTodo: TodoItemAdapter?,
    availableCategories: [CategoryAdapter]
)
```

**Parameters:**
- `useCase`: Business logic implementation
- `existingTodo`: Optional todo to edit (nil for new todo)
- `availableCategories`: Available categories for selection

#### Actions

##### save

Saves the todo (create or update).

```swift
public func save()
```

**Side Effects:**
- Validates formData
- Creates or updates todo
- Changes state to .saved on success
- Changes state to .error on failure

##### cancel

Cancels the form.

```swift
public func cancel()
```

**Note:** Dismissal handled by view

### TodoDetailBuilder

Factory for creating TodoDetailView.

```swift
@MainActor
@Observable
public final class TodoDetailBuilder
```

#### Methods

```swift
public func buildTodoDetailView(existingTodo: TodoItemAdapter?) async throws -> TodoDetailView
```

**Parameters:**
- `existingTodo`: Optional todo to edit

**Returns:** Configured TodoDetailView

**Throws:** DIError if dependencies not registered

**Note:** Fetches categories asynchronously

---

## TodoUI

**Package**: `TodoUI`
**Location**: `TodoUI/Sources/TodoUI/`

### TodoRowView

Reusable todo list item component.

```swift
public struct TodoRowView: View
```

#### Initialization

```swift
public init(
    todo: TodoItemAdapter,
    onToggle: @escaping () -> Void
)
```

**Parameters:**
- `todo`: Todo to display
- `onToggle`: Callback when checkbox is toggled

**Features:**
- Checkbox for completion
- Title with strikethrough when completed
- Due date badge (color-coded)
- Priority badge
- Category tags

### EmptyStateView

Reusable empty state component.

```swift
public struct EmptyStateView: View
```

#### Initialization

```swift
public init(
    icon: String,
    message: String,
    actionTitle: String,
    action: @escaping () -> Void
)
```

**Parameters:**
- `icon`: SF Symbol name
- `message`: Empty state message
- `actionTitle`: Action button title
- `action`: Callback when button tapped

### ErrorView

Reusable error display component.

```swift
public struct ErrorView: View
```

#### Initialization

```swift
public init(
    message: String,
    retryAction: @escaping () -> Void
)
```

**Parameters:**
- `message`: Error message
- `retryAction`: Callback for retry button

### CategoryTagView

Category badge component.

```swift
public struct CategoryTagView: View
```

#### Initialization

```swift
public init(category: CategoryAdapter)
```

**Parameters:**
- `category`: Category to display

**Features:**
- Colored circle indicator
- Category name
- Colored background

### PriorityBadgeView

Priority indicator component.

```swift
public struct PriorityBadgeView: View
```

#### Initialization

```swift
public init(priority: TodoPriority)
```

**Parameters:**
- `priority`: Priority level

**Features:**
- Icon (arrow up/down/equal)
- Priority name
- Color-coded (red/orange/blue/gray)

---

## TabBarView

**Package**: `TabBarView`
**Location**: `TabBarView/Sources/TabBarView/`

### TabBarView

Main tab navigation container.

```swift
public struct TabBarView: View
```

Uses native SwiftUI `TabView` and `Tab` API (iOS 26.0+).

#### Initialization

```swift
public init(container: DIContainer)
```

**Parameters:**
- `container`: DIContainer for building child views

**Features:**
- Tab-based navigation
- Sheet coordination for add/edit
- Automatic list reload on sheet dismiss

### TabBarBuilder

Factory for creating TabBarView.

```swift
@MainActor
@Observable
public final class TabBarBuilder
```

#### Methods

```swift
public func buildTabBarView() -> TabBarView
```

**Returns:** Configured TabBarView

---

## DevPreview

**Package**: `DevPreview`
**Location**: `DevPreview/Sources/DevPreview/DevPreview.swift`

### DevPreview

Preview environment with in-memory SwiftData and seed data.

```swift
@MainActor
public final class DevPreview
```

#### Properties

```swift
public static let shared: DevPreview
public let container: DIContainer
```

#### Usage

```swift
#Preview("Todo List") {
    let container = DevPreview.shared.container
    let builder = TodoListBuilder(container: container)
    let router = PreviewTodoListRouter()
    return try! builder.buildTodoListView(router: router)
}
```

**Features:**
- Singleton instance
- In-memory ModelContainer (no persistence)
- Pre-seeded with sample todos and categories
- Mock router implementations

---

## Models & DTOs

### Todo (SwiftData Model)

**Location**: `TodoUseCase/Sources/TodoUseCase/Models/Todo.swift`

```swift
@Model
public final class Todo {
    public var title: String
    public var notes: String
    public var isCompleted: Bool
    public var createdAt: Date
    public var dueDate: Date?
    public var priorityRawValue: Int
    public var sortOrder: Int
    public var categories: [Category]?

    // Computed property
    public var priority: TodoPriority { get set }
}
```

**CloudKit Compatible:**
- All properties have defaults or are optional
- No `@Attribute(.unique)`
- Optional relationships

### Category (SwiftData Model)

**Location**: `TodoUseCase/Sources/TodoUseCase/Models/Category.swift`

```swift
@Model
public final class Category {
    public var name: String
    public var colorHex: String
    public var createdAt: Date
    public var todos: [Todo]?
}
```

### TodoItemAdapter (DTO)

**Location**: `TodoUseCase/Sources/TodoUseCase/Adapters/TodoItemAdapter.swift`

```swift
public struct TodoItemAdapter: Sendable, Identifiable, Hashable {
    public let id: PersistentIdentifier
    public let title: String
    public let notes: String
    public let isCompleted: Bool
    public let dueDate: Date?
    public let priority: TodoPriority
    public let categories: [CategoryAdapter]
    public let sortOrder: Int

    // Computed UI properties
    public var isDueToday: Bool { get }
    public var isOverdue: Bool { get }
    public var dueDateFormatted: String { get }

    // Factory method
    public static func from(_ todo: Todo) -> TodoItemAdapter
}
```

**Purpose:**
- Sendable for concurrency safety
- UI-friendly computed properties
- Decouples views from SwiftData models

### CategoryAdapter (DTO)

**Location**: `TodoUseCase/Sources/TodoUseCase/Adapters/CategoryAdapter.swift`

```swift
public struct CategoryAdapter: Sendable, Identifiable, Hashable {
    public let id: PersistentIdentifier
    public let name: String
    public let colorHex: String

    // Computed property
    public var color: Color { get }

    // Factory method
    public static func from(_ category: Category) -> CategoryAdapter
}
```

### TodoPriority

**Location**: `TodoUseCase/Sources/TodoUseCase/Models/TodoPriority.swift`

```swift
public enum TodoPriority: Int, Codable, CaseIterable, Sendable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3

    public var displayName: String { get }
    public var systemImageName: String { get }
    public var color: Color { get }
}
```

### FilterOption

**Location**: `TodoUseCase/Sources/TodoUseCase/Models/FilterOption.swift`

```swift
public enum FilterOption: String, CaseIterable, Identifiable, Sendable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"

    public var id: String { rawValue }
    public var completionFilter: Bool? { get }
}
```

### TodoError

**Location**: `TodoUseCase/Sources/TodoUseCase/Models/TodoError.swift`

```swift
public enum TodoError: Error, LocalizedError {
    case validation(String)
    case notFound
    case unknown(String)

    public var errorDescription: String? { get }
}
```

---

## Protocols

### TodoUseCaseProtocol

**Location**: `TodoUseCase/Sources/TodoUseCase/Protocols/TodoUseCaseProtocol.swift`

```swift
@MainActor
public protocol TodoUseCaseProtocol {
    func fetchTodos(filter: FilterOption) async throws -> [TodoItemAdapter]
    func fetchTodo(byId id: PersistentIdentifier) async throws -> TodoItemAdapter?
    func createTodo(title: String, notes: String, dueDate: Date?, priority: TodoPriority, categoryIds: [PersistentIdentifier]) async throws -> TodoItemAdapter
    func updateTodo(id: PersistentIdentifier, title: String, notes: String, dueDate: Date?, priority: TodoPriority) async throws
    func toggleTodoCompletion(id: PersistentIdentifier) async throws
    func deleteTodo(id: PersistentIdentifier) async throws
    func reorderTodos(from source: IndexSet, to destination: Int, in adapters: [TodoItemAdapter]) async throws
    func fetchCategories() async throws -> [CategoryAdapter]
    func createCategory(name: String, colorHex: String) async throws -> CategoryAdapter
}
```

### TodoRepositoryProtocol

**Location**: `TodoUseCase/Sources/TodoUseCase/Interfaces/TodoRepositoryProtocol.swift`

```swift
@MainActor
public protocol TodoRepositoryProtocol {
    func fetchTodos(isCompleted: Bool?) async throws -> [Todo]
    func fetchTodo(byId id: PersistentIdentifier) async throws -> Todo?
    func fetchAllTodos() async throws -> [Todo]
    func createTodo(title: String, notes: String, dueDate: Date?, priority: TodoPriority) async throws -> Todo
    func updateTodo(_ todo: Todo) async throws
    func deleteTodo(_ todo: Todo) async throws
    func reorderTodos(from source: IndexSet, to destination: Int, in todos: [Todo]) async throws
    func fetchAllCategories() async throws -> [Category]
    func createCategory(name: String, colorHex: String) async throws -> Category
    func addCategory(_ category: Category, to todo: Todo) async throws
}
```

### TodoListRouterProtocol

**Location**: `TodoListView/Sources/TodoListView/TodoListRouter.swift`

```swift
@MainActor
public protocol TodoListRouterProtocol {
    func navigateToAddTodo()
    func navigateToEditTodo(_ todo: TodoItemAdapter)
}
```

---

## Usage Examples

### Complete Feature Implementation

```swift
// 1. Setup Dependencies (SifoApp.swift)
let schema = Schema([Todo.self, Category.self])
let config = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false,
    cloudKitDatabase: .automatic
)
let modelContainer = try ModelContainer(for: schema, configurations: [config])
let diContainer = AppComposition.setupDependencies(modelContainer: modelContainer)

// 2. Build Views (TabBarView)
let builder = TabBarBuilder(container: diContainer)
let tabBarView = builder.buildTabBarView()

// 3. ViewModel Usage (TodoListViewModel)
let viewModel = TodoListViewModel(useCase: useCase, router: router)
viewModel.loadTodos() // Fetch initial data
viewModel.filterChanged(to: .active) // Filter active todos
viewModel.toggleCompletion(for: todo) // Toggle completion
viewModel.addTodoTapped() // Navigate to add

// 4. Create Todo (TodoDetailViewModel)
let detailVM = TodoDetailViewModel(
    useCase: useCase,
    existingTodo: nil,
    availableCategories: []
)
detailVM.formData.title = "Buy groceries"
detailVM.formData.priority = .medium
detailVM.save() // Creates todo

// 5. Testing (TodoListViewModelTests)
let fakeUseCase = FakeTodoUseCase()
let fakeRouter = FakeTodoListRouter()
let viewModel = TodoListViewModel(useCase: fakeUseCase, router: fakeRouter)
viewModel.loadTodos()
#expect(viewModel.state == .loaded(...))
```

---

## Error Handling

All async operations use Swift's structured concurrency and error handling:

```swift
Task {
    do {
        let todos = try await useCase.fetchTodos(filter: .all)
        state = .loaded(todos)
    } catch let error as TodoError {
        // Handle domain-specific errors
        state = .error(error.localizedDescription)
    } catch {
        // Handle unexpected errors
        state = .error("An unexpected error occurred")
    }
}
```

---

## Thread Safety

All public APIs are `@MainActor` isolated:

- ViewModels: `@MainActor @Observable`
- Use Cases: `@MainActor`
- Repositories: `@MainActor`
- Builders: `@MainActor @Observable`

SwiftData models (`@Model`) handle actor isolation automatically via the macro.

---

## Best Practices

1. **Always resolve dependencies via DIContainer**
   ```swift
   let useCase = try container.requireResolve(TodoUseCaseProtocol.self)
   ```

2. **Use builders to create views**
   ```swift
   let builder = TodoListBuilder(container: container)
   let view = try builder.buildTodoListView(router: router)
   ```

3. **Handle all error cases**
   ```swift
   catch let error as TodoError {
       // Domain errors
   } catch {
       // Unexpected errors
   }
   ```

4. **Use adapters for data transformation**
   ```swift
   let adapter = TodoItemAdapter.from(todo)
   ```

5. **Follow state machine patterns**
   ```swift
   state = .loading
   // ... perform operation
   state = .loaded(data)
   ```

---

## See Also

- [ARCHITECTURE.md](../ARCHITECTURE.md) - Architecture overview
- [ARCHITECTURE_DIAGRAMS.md](ARCHITECTURE_DIAGRAMS.md) - Visual diagrams
- [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) - Development setup
- [USER_GUIDE.md](USER_GUIDE.md) - User documentation
