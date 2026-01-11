# Architecture Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architectural Principles](#architectural-principles)
3. [Layer Structure](#layer-structure)
4. [Module Breakdown](#module-breakdown)
5. [Dependency Management](#dependency-management)
6. [Data Flow](#data-flow)
7. [Design Patterns](#design-patterns)
8. [Navigation](#navigation)
9. [State Management](#state-management)
10. [Testing Strategy](#testing-strategy)
11. [Common Patterns](#common-patterns)

---

## Overview

**Sifo** is a native iOS todo list application built with **Swift 6.2** and **SwiftUI**, following **Clean Architecture** principles. The app provides comprehensive task management features including creating, editing, deleting, filtering, and reordering todos with SwiftData persistence and CloudKit synchronization.

### Technology Stack
- **Language**: Swift 6.2 (strict concurrency enabled)
- **UI Framework**: SwiftUI with `@Observable` macro
- **Persistence**: SwiftData with CloudKit sync
- **Minimum Deployment**: iOS 26.0+
- **Build System**: Xcode 26.2+
- **Dependency Management**: Swift Package Manager (SPM)
- **Architecture**: Clean Architecture with modular design
- **Navigation**: Native SwiftUI Tab API
- **Testing**: Swift Testing Framework

### Key Features
- ✅ Create and edit todos with rich metadata (title, notes, due date, priority, categories)
- ✅ Mark todos as complete/incomplete
- ✅ Filter by status (All, Active, Completed)
- ✅ Drag-and-drop reordering
- ✅ Swipe-to-delete with confirmation
- ✅ Category tagging with color coding
- ✅ Priority levels (None, Low, Medium, High)
- ✅ CloudKit sync for cross-device persistence
- ✅ Empty state handling
- ✅ Error handling with retry

---

## Architectural Principles

### 1. Clean Architecture
The application strictly follows Clean Architecture, separating concerns into distinct layers with clear dependency directions.

**Dependency Rule**: Dependencies point inward. Outer layers depend on inner layers, never the reverse.

```
┌─────────────────────────────────────────────────┐
│   Presentation Layer (Views & ViewModels)       │
│   (TodoListView, TodoDetailView, TabBarView)    │
└──────────────────┬──────────────────────────────┘
                   │ depends on
                   ↓
┌─────────────────────────────────────────────────┐
│      Business Logic Layer (Use Cases)           │
│         (TodoUseCase, protocols)                │
└──────────────────┬──────────────────────────────┘
                   │ depends on
                   ↓
┌─────────────────────────────────────────────────┐
│          Data Layer (Repository)                │
│     (TodoRepository, SwiftData models)          │
└─────────────────────────────────────────────────┘
```

### 2. Protocol-Oriented Design
All inter-layer communication happens through protocols, enabling:
- Testability (easy mocking)
- Flexibility (swap implementations)
- Decoupling (layers don't know concrete types)

**Key Protocols**:
- `TodoRepositoryProtocol` - Data access abstraction
- `TodoUseCaseProtocol` - Business logic abstraction
- `TodoListRouterProtocol` - Navigation abstraction for list
- `TodoDetailRouterProtocol` - Navigation abstraction for detail

### 3. Dependency Injection
All dependencies are:
- Registered in `AppComposition.swift`
- Resolved through `DIContainer`
- Injected via constructors (never accessed globally)

### 4. Unidirectional Data Flow
Data flows in one direction:
```
User Action → ViewModel → UseCase → Repository → SwiftData
                ↓             ↓          ↓            ↓
             Update       Business    Data        Model
              State        Logic     Access      Context
```

### 5. Actor Isolation
- SwiftData models use `@Model` macro (handles actor isolation automatically)
- ViewModels are `@MainActor` for UI thread safety
- Repository is `@MainActor` (uses ModelContext which requires main actor)
- DIContainer is `@MainActor` with `@Observable` for SwiftUI integration

---

## Layer Structure

### Presentation Layer
**Responsibility**: UI rendering, user interaction, view state management

**Components**:
- SwiftUI Views (`TodoListView`, `TodoDetailView`, `TabBarView`)
- ViewModels (manage view state, coordinate with use cases)
- Builders (compose views with dependencies)
- Routers (handle navigation)
- UI Components (`TodoUI` package)

**Rules**:
- Views are stateless and declarative
- ViewModels hold state and handle business logic coordination
- No direct SwiftData or repository access
- Communicate only with use cases
- Use `@State` for view model references (not `@Bindable`)
- Custom bindings for form fields

### Business Logic Layer
**Responsibility**: Application-specific business rules, data transformation

**Components**:
- Use Cases (`TodoUseCase`)
- Domain Models (`Todo`, `Category`, `TodoPriority`)
- Adapters (map SwiftData models to DTOs: `TodoItemAdapter`, `CategoryAdapter`)
- Business Logic Protocols
- Domain errors (`TodoError`)

**Rules**:
- No UI dependencies (no SwiftUI imports except for colors)
- No knowledge of SwiftData implementation details
- Pure business logic only
- Framework-independent where possible

### Data Layer
**Responsibility**: Data access, persistence, SwiftData operations

**Components**:
- Repositories (`TodoRepository`)
- SwiftData Models (`Todo`, `Category`)
- Repository Protocols (`TodoRepositoryProtocol`)
- Model enums (`TodoPriority`)

**Rules**:
- Implements repository protocols defined in use cases
- Handles SwiftData operations (fetch, insert, update, delete)
- Maps SwiftData models to domain models (via use case)
- No business logic
- All operations on `@MainActor`

---

## Module Breakdown

### Core Infrastructure Modules

#### 1. **DependencyContainer**
Simple dependency injection container.

**Location**: Separate SPM package
**Key Types**:
- `DIContainer` (class with registration and resolution methods)

**Responsibilities**:
- Service registration
- Service resolution with type safety
- `@MainActor` and `@Observable` support for SwiftUI

**Attributes**:
```swift
@MainActor
@Observable
public final class DIContainer {
    private var services: [String: Any] = [:]

    public func register<T>(_ type: T.Type, _ instance: T)
    public func requireResolve<T>(_ type: T.Type) throws -> T
}
```

### Data Layer Modules

#### 2. **TodoRepository**
Data access implementation using SwiftData.

**Location**: Separate SPM package
**Key Types**:
- `TodoRepository` (implements `TodoRepositoryProtocol`)
- `TodoRepositoryProtocol` (defines CRUD operations)

**Responsibilities**:
- SwiftData CRUD operations
- Filtering (by completion status)
- Reordering todos (drag-and-drop)
- Category management
- Relationship handling

**Key Methods**:
```swift
func createTodo(title: String, notes: String, dueDate: Date?, priority: TodoPriority) async throws -> Todo
func fetchTodos(isCompleted: Bool?) async throws -> [Todo]
func updateTodo(_ todo: Todo) async throws
func deleteTodo(_ todo: Todo) async throws
func reorderTodos(from: IndexSet, to: Int, in: [Todo]) async throws
```

**Important Notes**:
- Models (`Todo`, `Category`) moved to `TodoUseCase` package to avoid circular dependencies
- Uses `import TodoUseCase` and typealias for accessing models
- All operations use `ModelContext` on `@MainActor`

#### 3. **TodoUseCase**
Business logic and domain models.

**Location**: Separate SPM package
**Key Types**:
- `TodoUseCase` (implements `TodoUseCaseProtocol`)
- `TodoUseCaseProtocol` (defines business operations)
- SwiftData Models: `Todo`, `Category`
- Adapters: `TodoItemAdapter`, `CategoryAdapter`
- Domain Models: `FilterOption`, `TodoPriority`, `TodoError`

**SwiftData Models**:
```swift
@Model
public final class Todo {
    public var title: String = ""
    public var notes: String = ""
    public var isCompleted: Bool = false
    public var createdAt: Date = Date()
    public var dueDate: Date? = nil
    public var priorityRawValue: Int = 0
    public var sortOrder: Int = 0

    @Relationship(deleteRule: .nullify, inverse: \Category.todos)
    public var categories: [Category]? = []
}

@Model
public final class Category {
    public var name: String = ""
    public var colorHex: String = "#007AFF"
    public var createdAt: Date = Date()

    @Relationship(deleteRule: .nullify)
    public var todos: [Todo]? = []
}
```

**CloudKit Compatibility**:
- All properties have default values OR are optional
- No `@Attribute(.unique)` (not supported by CloudKit)
- All relationships are optional
- `@Model` macro handles actor isolation (no `@MainActor` needed)

**Adapters (DTOs)**:
```swift
public struct TodoItemAdapter: Sendable, Identifiable, Hashable {
    public let id: PersistentIdentifier
    public let title: String
    public let notes: String
    public let isCompleted: Bool
    public let dueDate: Date?
    public let priority: TodoPriority
    public let categories: [CategoryAdapter]

    // Computed properties for UI
    public var isDueToday: Bool { /* ... */ }
    public var isOverdue: Bool { /* ... */ }
    public var dueDateFormatted: String { /* ... */ }
}
```

**Responsibilities**:
- Transform SwiftData models to DTOs
- Business validation (e.g., title not empty)
- Filter logic (All, Active, Completed)
- Category relationship management
- Error mapping

### Presentation Layer Modules

#### 4. **TodoListView**
Todo list feature with filtering and reordering.

**Location**: Separate SPM package
**Key Types**:
- `TodoListView` (SwiftUI view)
- `TodoListViewModel` (state machine pattern)
- `TodoListBuilder` (dependency composition)
- `TodoListRouterProtocol` (navigation abstraction)

**State Machine**:
```swift
public enum State: Equatable {
    case idle
    case loading
    case loaded([TodoItemAdapter])
    case error(String)
    case deleting(TodoItemAdapter)
}
```

**Features**:
- Segmented filter picker (All, Active, Completed)
- Pull-to-refresh
- Swipe-to-delete with confirmation alert
- Tap to edit
- Checkbox toggle for completion
- Drag-and-drop reordering (via `.onMove`)
- Empty state with "Add Todo" button
- EditButton in toolbar for reorder mode

**ViewModel Actions**:
```swift
func loadTodos()
func filterChanged(to: FilterOption)
func toggleCompletion(for: TodoItemAdapter)
func reorderTodos(from: IndexSet, to: Int)
func deleteTodoConfirmation(for: TodoItemAdapter)
func confirmDelete()
func cancelDelete()
func addTodoTapped()
func editTodoTapped(_ todo: TodoItemAdapter)
```

#### 5. **TodoDetailView**
Todo add/edit form with validation.

**Location**: Separate SPM package
**Key Types**:
- `TodoDetailView` (SwiftUI form view)
- `TodoDetailViewModel` (form state machine)
- `TodoDetailBuilder` (dependency composition)

**State Machine**:
```swift
public enum State: Equatable {
    case editing(FormData)
    case saving
    case saved  // Triggers dismiss
    case error(String)
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
}
```

**Form Sections**:
1. **Details**: Title (required), Notes (multi-line)
2. **Due Date**: Toggle + DatePicker (conditional)
3. **Priority**: Menu picker (None, Low, Medium, High)
4. **Categories**: Multi-select list with checkmarks

**Key Pattern - Custom Bindings**:
```swift
// Use @State instead of @Bindable for view model
@State public var viewModel: TodoDetailViewModel

// Create custom bindings for form fields
private var titleBinding: Binding<String> {
    Binding(
        get: { viewModel.formData.title },
        set: { newValue in
            viewModel.formData.title = newValue
        }
    )
}
```

**Important Implementation Details**:
- `formData` is a stored property with `didSet` observer (not computed)
- Always use `@State` for view model, never `@Bindable`
- Custom bindings for all form fields to work with `@State`
- Save validation prevents empty titles
- Navigation title changes based on mode ("New Todo" vs "Edit Todo")

#### 6. **TodoUI**
Shared UI components.

**Location**: Separate SPM package
**Components**:
- `TodoRowView` - Todo list item with checkbox, title, badges
- `CategoryTagView` - Colored category tag
- `PriorityBadgeView` - Priority icon + text
- `EmptyStateView` - Reusable empty state with action button
- `ErrorView` - Error display with retry button

**TodoRowView Features**:
- Checkbox for completion toggle
- Title with strikethrough when completed
- Due date badge (color-coded: overdue=red, today=orange, future=gray)
- Priority badge
- Category tags (horizontal scroll)

**EmptyStateView**:
```swift
ContentUnavailableView {
    Label(message, systemImage: icon)
} description: {
    Text("Get started by adding your first todo")
} actions: {
    Button(actionTitle, systemImage: "plus", action: action)
        .buttonStyle(.borderedProminent)
}
```

#### 7. **TabBarView**
Main tab navigation with sheet coordination.

**Location**: Separate SPM package
**Uses**: Native SwiftUI `TabView` and `Tab` API (iOS 26.0+)

**Key Components**:
- `TabBarView` - Main tab container
- `TodoListCoordinator` - Handles list view + sheet navigation

**Coordinator Pattern**:
```swift
private struct TodoListCoordinator: View {
    @State private var showingAddSheet = false
    @State private var editingTodo: TodoItemAdapter?
    @State private var listViewModel: TodoListViewModel?

    // Sheet modifiers with onDismiss reload
    .sheet(isPresented: $showingAddSheet) {
        viewModel.loadTodos()  // Reload on dismiss
    } content: {
        // TodoDetailView for adding
    }
}
```

**Important Pattern**:
- Store `listViewModel` reference in coordinator
- Call `viewModel.loadTodos()` in sheet `onDismiss` to refresh list
- Build router with closure captures for sheet state

**Router Implementation**:
```swift
@MainActor
private final class TodoListRouterImpl: TodoListRouterProtocol {
    private let showAddSheet: () -> Void
    private let showEditSheet: (TodoItemAdapter) -> Void

    func navigateToAddTodo() { showAddSheet() }
    func navigateToEditTodo(_ todo: TodoItemAdapter) { showEditSheet(todo) }
}
```

### Utility Modules

#### 8. **DevPreview**
SwiftUI preview support with real dependencies.

**Location**: Separate SPM package
**Purpose**: Provide in-memory SwiftData container and fake dependencies for previews

**Usage**:
```swift
#Preview {
    let container = DevPreview.shared.container
    let builder = TodoListBuilder(container: container)
    let router = PreviewTodoListRouter()
    return builder.buildTodoListView(router: router)
}
```

**Features**:
- In-memory ModelContainer with seed data
- Preview-only router implementations
- Shared singleton for consistent preview state

---

## Dependency Management

### Registration Flow
Dependencies are registered in `AppComposition.swift` in a specific order:

```swift
@MainActor
final class AppComposition {
    static func setupDependencies(modelContainer: ModelContainer) -> DIContainer {
        let container = DIContainer()

        // 1. Infrastructure - SwiftData context
        let modelContext = ModelContext(modelContainer)

        // 2. Data layer - Repository
        let todoRepository = TodoRepository(modelContext: modelContext)
        container.register(TodoRepositoryProtocol.self, todoRepository)

        // 3. Business logic - Use case
        let todoUseCase = try! TodoUseCase(container: container)
        container.register(TodoUseCaseProtocol.self, todoUseCase)

        return container
    }
}
```

### App Initialization
`SifoApp.swift` sets up SwiftData and DI:

```swift
@main
struct SifoApp: App {
    let modelContainer: ModelContainer
    let diContainer: DIContainer

    init() {
        // Setup SwiftData with CloudKit
        let schema = Schema([Todo.self, Category.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic  // Enable CloudKit sync
        )
        modelContainer = try! ModelContainer(for: schema, configurations: [config])

        // Setup DI
        diContainer = AppComposition.setupDependencies(modelContainer: modelContainer)
    }

    var body: some Scene {
        WindowGroup {
            let builder = TabBarBuilder(container: diContainer)
            builder.buildTabBarView()
        }
        .modelContainer(modelContainer)
    }
}
```

### Resolution Rules
1. **Registration order matters** - Register dependencies before dependents
2. **Use `requireResolve()`** - Throws error if dependency missing
3. **No force unwrapping** - Always handle resolution errors (except in init where failure is fatal)
4. **Constructor injection only** - No property injection
5. **MainActor isolation** - All DI operations on main actor

---

## Data Flow

### Example: Creating a New Todo

```
1. User Action
   ↓
   TodoDetailView (tap Save button)

2. View → ViewModel
   ↓
   TodoDetailViewModel.save()

3. ViewModel Validation
   ↓
   Validate formData.isValid (title not empty)

4. ViewModel → UseCase
   ↓
   TodoUseCase.createTodo(title:notes:dueDate:priority:)

5. UseCase Validation
   ↓
   Trim title, check not empty, throw TodoError.validation if invalid

6. UseCase → Repository
   ↓
   TodoRepository.createTodo(title:notes:dueDate:priority:)

7. Repository → SwiftData
   ↓
   Create Todo model, set sortOrder, insert to ModelContext, save

8. Repository → UseCase
   ↓
   Return Todo model

9. UseCase Transformation
   ↓
   TodoItemAdapter.from(todo) - convert to DTO

10. UseCase → ViewModel
    ↓
    Return TodoItemAdapter

11. ViewModel State Update
    ↓
    state = .saved

12. View Dismisses
    ↓
    onChange(of: viewModel.state) triggers dismiss()

13. Sheet onDismiss
    ↓
    TodoListViewModel.loadTodos() - refresh list

14. List View Re-renders
    ↓
    TodoListView displays updated list
```

### Example: Filtering Todos

```
1. User Action
   ↓
   TodoListView (tap "Active" in segmented picker)

2. View Binding
   ↓
   currentFilterBinding.set(.active)

3. ViewModel Action
   ↓
   TodoListViewModel.filterChanged(to: .active)

4. ViewModel State
   ↓
   currentFilter = .active
   state = .loading

5. ViewModel → UseCase
   ↓
   TodoUseCase.fetchTodos(filter: .active)

6. UseCase → Repository
   ↓
   TodoRepository.fetchTodos(isCompleted: false)

7. Repository → SwiftData
   ↓
   FetchDescriptor<Todo>(predicate: #Predicate { !$0.isCompleted })

8. SwiftData → Repository
   ↓
   Return [Todo] filtered by completion status

9. Repository → UseCase
   ↓
   Return [Todo]

10. UseCase Transformation
    ↓
    [TodoItemAdapter].from(todos) - batch conversion

11. UseCase → ViewModel
    ↓
    Return [TodoItemAdapter]

12. ViewModel State Update
    ↓
    state = .loaded(adapters)

13. View Re-renders
    ↓
    TodoListView displays filtered todos
```

---

## Design Patterns

### 1. Builder Pattern
Every feature has a Builder class that composes views with dependencies.

**Purpose**:
- Centralize dependency injection
- Keep views testable
- Decouple view creation from DI container

**Example**:
```swift
@MainActor
@Observable
public final class TodoListBuilder {
    private let container: DIContainer

    public init(container: DIContainer) {
        self.container = container
    }

    public func buildTodoListView(router: TodoListRouterProtocol) throws -> TodoListView {
        let useCase = try container.requireResolve(TodoUseCaseProtocol.self)
        let viewModel = TodoListViewModel(useCase: useCase, router: router)
        return TodoListView(viewModel: viewModel)
    }
}
```

### 2. State Machine Pattern
ViewModels use enum-based state machines for clarity.

**Benefits**:
- Impossible states become impossible
- Clear state transitions
- Easy to test
- Explicit loading/error states

**TodoListViewModel Example**:
```swift
public enum State: Equatable {
    case idle
    case loading
    case loaded([TodoItemAdapter])
    case error(String)
    case deleting(TodoItemAdapter)
}

public func loadTodos() {
    state = .loading
    Task {
        do {
            let todos = try await useCase.fetchTodos(filter: currentFilter)
            state = .loaded(todos)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
```

**TodoDetailViewModel Example**:
```swift
public enum State: Equatable {
    case editing(FormData)
    case saving
    case saved
    case error(String)
}

public func save() {
    guard formData.isValid else { return }

    state = .saving
    Task {
        do {
            if let existing = existingTodo {
                _ = try await useCase.updateTodo(id: existing.id, formData: formData)
            } else {
                _ = try await useCase.createTodo(
                    title: formData.title,
                    notes: formData.notes,
                    dueDate: formData.hasDueDate ? formData.dueDate : nil,
                    priority: formData.priority
                )
            }
            state = .saved
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
```

### 3. Repository Pattern
Abstracts data sources behind protocols.

**Benefits**:
- Swap implementations (SwiftData, Core Data, mock)
- Testability with fake repositories
- Single source of truth for data access

**Protocol Definition**:
```swift
public protocol TodoRepositoryProtocol {
    func createTodo(title: String, notes: String, dueDate: Date?, priority: TodoPriority) async throws -> Todo
    func fetchTodos(isCompleted: Bool?) async throws -> [Todo]
    func updateTodo(_ todo: Todo) async throws
    func deleteTodo(_ todo: Todo) async throws
    func reorderTodos(from source: IndexSet, to destination: Int, in todos: [Todo]) async throws
}
```

**SwiftData Implementation**:
```swift
@MainActor
public final class TodoRepository: TodoRepositoryProtocol {
    private let modelContext: ModelContext

    public func fetchTodos(isCompleted: Bool?) async throws -> [Todo] {
        var descriptor = FetchDescriptor<Todo>(
            sortBy: [SortDescriptor(\Todo.sortOrder, order: .forward)]
        )

        if let isCompleted {
            descriptor.predicate = #Predicate { $0.isCompleted == isCompleted }
        }

        return try modelContext.fetch(descriptor)
    }
}
```

### 4. Adapter Pattern
Transforms data between layers using DTOs.

**Purpose**:
- Keep layers independent
- Map SwiftData models to view-friendly structures
- Add computed properties for UI (isDueToday, isOverdue)
- Ensure Sendable conformance for concurrency safety

**Example**:
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
    public var isDueToday: Bool {
        guard let dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }

    public var isOverdue: Bool {
        guard let dueDate, !isCompleted else { return false }
        return dueDate < Date()
    }

    public static func from(_ todo: Todo) -> TodoItemAdapter {
        TodoItemAdapter(
            id: todo.persistentModelID,
            title: todo.title,
            notes: todo.notes,
            isCompleted: todo.isCompleted,
            dueDate: todo.dueDate,
            priority: TodoPriority(rawValue: todo.priorityRawValue) ?? .none,
            categories: (todo.categories ?? []).map { CategoryAdapter.from($0) },
            sortOrder: todo.sortOrder
        )
    }
}
```

**Why Not Use SwiftData Models Directly in Views?**
- Models are tied to ModelContext lifecycle
- Can't easily add computed properties to `@Model` classes
- Adapters are Sendable for safe async/concurrent access
- Views don't need SwiftData dependencies

### 5. Protocol-Oriented Programming
All abstractions are protocols, not base classes.

**Benefits**:
- Better testability (easy to create fakes)
- Composition over inheritance
- Value semantics when possible
- Clear contracts between layers

**Example - Router Protocol**:
```swift
@MainActor
public protocol TodoListRouterProtocol {
    func navigateToAddTodo()
    func navigateToEditTodo(_ todo: TodoItemAdapter)
}

// Implementation in TabBarView
private final class TodoListRouterImpl: TodoListRouterProtocol {
    private let showAddSheet: () -> Void
    private let showEditSheet: (TodoItemAdapter) -> Void

    func navigateToAddTodo() { showAddSheet() }
    func navigateToEditTodo(_ todo: TodoItemAdapter) { showEditSheet(todo) }
}

// Preview implementation in DevPreview
final class PreviewTodoListRouter: TodoListRouterProtocol {
    func navigateToAddTodo() { print("Navigate to add") }
    func navigateToEditTodo(_ todo: TodoItemAdapter) { print("Navigate to edit \(todo.title)") }
}
```

### 6. Custom Bindings for @State ViewModels
When using `@State` for view models (instead of `@Bindable`), create custom bindings.

**Pattern**:
```swift
// In view
@State public var viewModel: TodoDetailViewModel

private var titleBinding: Binding<String> {
    Binding(
        get: { viewModel.formData.title },
        set: { newValue in
            viewModel.formData.title = newValue
        }
    )
}

// In body
TextField("Title", text: titleBinding)
```

**Why This Pattern?**
- `@State` holds a reference to the view model
- SwiftUI tracks changes to the view model's `@Observable` properties
- Custom bindings provide two-way data flow for form controls
- More explicit than `@Bindable`, better for debugging

### 7. FormData with didSet Observer
For form state management, use a stored property with `didSet`.

**Pattern**:
```swift
public var formData: FormData = FormData() {
    didSet {
        // Keep state in sync when formData changes
        if case .editing = state {
            state = .editing(formData)
        }
    }
}
```

**Why Not Computed Property?**
- Computed properties don't work well with SwiftUI bindings for nested properties
- `didSet` ensures state machine stays in sync with form changes
- Allows direct mutation of `formData` fields

---

## Navigation

### Native SwiftUI Tab API
The app uses the native SwiftUI `Tab` API (iOS 18.0+) for tab navigation.

**TabBarView Structure**:
```swift
public struct TabBarView: View {
    private let container: DIContainer

    public var body: some View {
        TabView {
            Tab("Todos", systemImage: "checklist") {
                TodoListCoordinator(container: container)
            }
            // Add more tabs as needed
        }
    }
}
```

### Sheet-Based Navigation
Detail views are presented as sheets with sheet state managed by coordinator.

**Pattern**:
```swift
@State private var showingAddSheet = false
@State private var editingTodo: TodoItemAdapter?

TodoListView(viewModel: viewModel)
    .sheet(isPresented: $showingAddSheet) {
        // onDismiss - reload list
        viewModel.loadTodos()
    } content: {
        // Present add sheet
        TodoDetailView(...)
    }
    .sheet(item: $editingTodo, onDismiss: {
        viewModel.loadTodos()
    }) { todo in
        // Present edit sheet
        TodoDetailView(...)
    }
```

**Key Points**:
- Use `onDismiss` callback to reload list after add/edit
- Store view model reference in coordinator to call `loadTodos()`
- Router protocol triggers sheet presentation via closure captures

### Router Protocol Pattern
Routers are protocol-based and injected into ViewModels.

**Protocol**:
```swift
@MainActor
public protocol TodoListRouterProtocol {
    func navigateToAddTodo()
    func navigateToEditTodo(_ todo: TodoItemAdapter)
}
```

**Implementation**:
```swift
private final class TodoListRouterImpl: TodoListRouterProtocol {
    private let showAddSheet: () -> Void
    private let showEditSheet: (TodoItemAdapter) -> Void

    init(showAddSheet: @escaping () -> Void, showEditSheet: @escaping (TodoItemAdapter) -> Void) {
        self.showAddSheet = showAddSheet
        self.showEditSheet = showEditSheet
    }

    func navigateToAddTodo() { showAddSheet() }
    func navigateToEditTodo(_ todo: TodoItemAdapter) { showEditSheet(todo) }
}
```

**Usage in ViewModel**:
```swift
public func addTodoTapped() {
    router.navigateToAddTodo()
}

public func editTodoTapped(_ todo: TodoItemAdapter) {
    router.navigateToEditTodo(todo)
}
```

---

## State Management

### SwiftUI @Observable
The app uses Swift 5.9+ `@Observable` macro instead of `ObservableObject`.

**Usage**:
```swift
@MainActor
@Observable
public final class TodoListViewModel {
    public var state: State = .idle
    public var currentFilter: FilterOption = .all
    public var todos: [TodoItemAdapter] = []

    // Computed properties tracked automatically
    public var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }
}
```

**Benefits**:
- Less boilerplate (no `@Published` wrappers)
- Automatic change tracking for used properties
- Better performance (fine-grained observation)
- Works seamlessly with `@State` in views

### @State vs @Bindable
**Use @State** for view model references:
```swift
@State public var viewModel: TodoListViewModel

public init(viewModel: TodoListViewModel) {
    self._viewModel = State(initialValue: viewModel)
}
```

**Why @State Instead of @Bindable?**
- `@State` holds a reference and tracks changes
- `@Bindable` is for creating bindings to observable properties
- For our pattern, we create custom bindings explicitly
- `@State` is more explicit and easier to debug

### State Machine Transitions
ViewModels manage state transitions explicitly:

**TodoListViewModel**:
```swift
// Initial state
state = .idle

// Loading todos
state = .loading

// Loaded successfully
state = .loaded(todos)

// Showing delete confirmation
state = .deleting(todo)

// Error occurred
state = .error(message)
```

**TodoDetailViewModel**:
```swift
// Editing form
state = .editing(formData)

// Saving changes
state = .saving

// Save succeeded (triggers dismiss)
state = .saved

// Save failed
state = .error(message)
```

---

## Testing Strategy

### Unit Tests
Each SPM package has its own `Tests/` directory.

**Framework**: Swift Testing (modern, built-in)

**Test Structure**:
```
TodoListView/
├── Sources/
│   └── TodoListView/
│       ├── TodoListView.swift
│       └── TodoListViewModel.swift
└── Tests/
    └── TodoListViewTests/
        └── TodoListViewModelTests.swift
```

### Test Doubles

#### Fake Repository
```swift
@MainActor
final class FakeTodoRepository: TodoRepositoryProtocol {
    var todos: [Todo] = []
    var shouldThrowError = false

    func fetchTodos(isCompleted: Bool?) async throws -> [Todo] {
        if shouldThrowError {
            throw TodoError.unknown("Test error")
        }

        if let isCompleted {
            return todos.filter { $0.isCompleted == isCompleted }
        }
        return todos
    }

    func createTodo(title: String, notes: String, dueDate: Date?, priority: TodoPriority) async throws -> Todo {
        let todo = Todo(title: title, notes: notes, dueDate: dueDate, priority: priority)
        todos.append(todo)
        return todo
    }

    // ... other methods
}
```

#### Fake Use Case
```swift
@MainActor
final class FakeTodoUseCase: TodoUseCaseProtocol {
    var todos: [TodoItemAdapter] = []
    var shouldThrowError = false

    func fetchTodos(filter: FilterOption) async throws -> [TodoItemAdapter] {
        if shouldThrowError {
            throw TodoError.unknown("Test error")
        }

        switch filter {
        case .all: return todos
        case .active: return todos.filter { !$0.isCompleted }
        case .completed: return todos.filter { $0.isCompleted }
        }
    }

    // ... other methods
}
```

#### Fake Router
```swift
@MainActor
final class FakeTodoListRouter: TodoListRouterProtocol {
    var addTodoCalled = false
    var editTodoCalled = false
    var lastEditedTodo: TodoItemAdapter?

    func navigateToAddTodo() {
        addTodoCalled = true
    }

    func navigateToEditTodo(_ todo: TodoItemAdapter) {
        editTodoCalled = true
        lastEditedTodo = todo
    }
}
```

### Testing ViewModels
Test state transitions and business logic:

```swift
import Testing
@testable import TodoListView

@MainActor
@Suite("TodoListViewModel Tests")
struct TodoListViewModelTests {

    @Test("Load todos updates state to loaded")
    func testLoadTodosSuccess() async throws {
        // Arrange
        let fakeUseCase = FakeTodoUseCase()
        fakeUseCase.todos = [
            TodoItemAdapter(id: ..., title: "Test Todo", ...)
        ]
        let fakeRouter = FakeTodoListRouter()
        let viewModel = TodoListViewModel(useCase: fakeUseCase, router: fakeRouter)

        // Act
        viewModel.loadTodos()
        try await Task.sleep(for: .milliseconds(100))

        // Assert
        #expect(viewModel.state == .loaded(fakeUseCase.todos))
    }

    @Test("Load todos failure updates state to error")
    func testLoadTodosError() async throws {
        // Arrange
        let fakeUseCase = FakeTodoUseCase()
        fakeUseCase.shouldThrowError = true
        let fakeRouter = FakeTodoListRouter()
        let viewModel = TodoListViewModel(useCase: fakeUseCase, router: fakeRouter)

        // Act
        viewModel.loadTodos()
        try await Task.sleep(for: .milliseconds(100))

        // Assert
        if case .error = viewModel.state {
            // Success - state is error
        } else {
            Issue.record("Expected error state")
        }
    }

    @Test("Filter changed reloads todos")
    func testFilterChanged() async throws {
        let fakeUseCase = FakeTodoUseCase()
        let viewModel = TodoListViewModel(useCase: fakeUseCase, router: FakeTodoListRouter())

        viewModel.filterChanged(to: .active)
        #expect(viewModel.currentFilter == .active)
    }

    @Test("Add todo tapped calls router")
    func testAddTodoTapped() {
        let fakeRouter = FakeTodoListRouter()
        let viewModel = TodoListViewModel(useCase: FakeTodoUseCase(), router: fakeRouter)

        viewModel.addTodoTapped()

        #expect(fakeRouter.addTodoCalled == true)
    }
}
```

### Testing Repositories (In-Memory SwiftData)
Use in-memory ModelContainer for repository tests:

```swift
import Testing
import SwiftData
@testable import TodoRepository

@MainActor
@Suite("TodoRepository Tests")
struct TodoRepositoryTests {

    func createInMemoryContainer() throws -> ModelContainer {
        let schema = Schema([Todo.self, Category.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }

    @Test("Create todo persists correctly")
    func testCreateTodo() async throws {
        // Arrange
        let container = try createInMemoryContainer()
        let context = ModelContext(container)
        let repository = TodoRepository(modelContext: context)

        // Act
        let todo = try await repository.createTodo(
            title: "Test Todo",
            notes: "Test notes",
            dueDate: nil,
            priority: .medium
        )

        // Assert
        #expect(todo.title == "Test Todo")
        #expect(todo.notes == "Test notes")
        #expect(todo.priority == .medium)

        // Verify persistence
        let fetched = try await repository.fetchTodos(isCompleted: nil)
        #expect(fetched.count == 1)
        #expect(fetched.first?.title == "Test Todo")
    }

    @Test("Fetch todos with filter")
    func testFetchTodosFiltered() async throws {
        let container = try createInMemoryContainer()
        let context = ModelContext(container)
        let repository = TodoRepository(modelContext: context)

        // Create completed and active todos
        let completed = try await repository.createTodo(title: "Completed", ...)
        completed.isCompleted = true
        try await repository.updateTodo(completed)

        _ = try await repository.createTodo(title: "Active", ...)

        // Fetch only active
        let active = try await repository.fetchTodos(isCompleted: false)
        #expect(active.count == 1)
        #expect(active.first?.title == "Active")
    }
}
```

### Testing Use Cases
Test business logic with fake repositories:

```swift
import Testing
@testable import TodoUseCase

@MainActor
@Suite("TodoUseCase Tests")
struct TodoUseCaseTests {

    @Test("Create todo validates title")
    func testCreateTodoValidation() async throws {
        let fakeRepo = FakeTodoRepository()
        let container = DIContainer()
        container.register(TodoRepositoryProtocol.self, fakeRepo)
        let useCase = try TodoUseCase(container: container)

        // Empty title should throw
        await #expect(throws: TodoError.self) {
            try await useCase.createTodo(title: "   ", notes: "", dueDate: nil, priority: .none)
        }
    }

    @Test("Fetch todos filters correctly")
    func testFetchTodosFilter() async throws {
        let fakeRepo = FakeTodoRepository()
        fakeRepo.todos = [
            Todo(title: "Active 1", isCompleted: false),
            Todo(title: "Completed 1", isCompleted: true),
            Todo(title: "Active 2", isCompleted: false)
        ]

        let container = DIContainer()
        container.register(TodoRepositoryProtocol.self, fakeRepo)
        let useCase = try TodoUseCase(container: container)

        let active = try await useCase.fetchTodos(filter: .active)
        #expect(active.count == 2)
        #expect(active.allSatisfy { !$0.isCompleted })
    }
}
```

---

## Common Patterns

### 1. Drag-and-Drop Reordering

**View Implementation**:
```swift
List {
    ForEach(todos) { todo in
        TodoRowView(todo: todo, ...)
    }
    .onMove { source, destination in
        viewModel.reorderTodos(from: source, to: destination)
    }
}
```

**ViewModel**:
```swift
public func reorderTodos(from source: IndexSet, to destination: Int) {
    guard case .loaded(let todos) = state else { return }

    Task {
        do {
            // Get SwiftData models from use case
            let models = try await useCase.getTodoModels(for: todos)
            try await useCase.reorderTodos(from: source, to: destination, in: models)

            // Reload to get updated sort order
            loadTodos()
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
```

**Repository (Manual Reordering)**:
```swift
public func reorderTodos(from source: IndexSet, to destination: Int, in todos: [Todo]) async throws {
    var mutableTodos = todos

    // Manual array reordering (without SwiftUI dependency)
    let movedItems = source.sorted().reversed().map { mutableTodos.remove(at: $0) }
    mutableTodos.insert(contentsOf: movedItems.reversed(), at: destination)

    // Update sortOrder for all todos
    for (index, todo) in mutableTodos.enumerated() {
        todo.sortOrder = index
    }

    try modelContext.save()
}
```

**Key Points**:
- Repository can't use SwiftUI's `.move()` method
- Implement manual array reordering logic
- Update `sortOrder` property for persistence
- Reload list after reorder to show updated state

### 2. Delete with Confirmation

**View**:
```swift
.swipeActions(edge: .trailing, allowsFullSwipe: false) {
    Button("Delete", systemImage: "trash", role: .destructive) {
        viewModel.deleteTodoConfirmation(for: todo)
    }
}
.alert("Delete Todo?", isPresented: deleteConfirmationBinding) {
    Button("Cancel", role: .cancel) {
        viewModel.cancelDelete()
    }
    Button("Delete", role: .destructive) {
        viewModel.confirmDelete()
    }
}
```

**ViewModel State Machine**:
```swift
public enum State: Equatable {
    case loaded([TodoItemAdapter])
    case deleting(TodoItemAdapter)
    // ... other states
}

public func deleteTodoConfirmation(for todo: TodoItemAdapter) {
    state = .deleting(todo)
}

public func confirmDelete() {
    guard case .deleting(let todo) = state else { return }

    Task {
        do {
            try await useCase.deleteTodo(id: todo.id)
            loadTodos()
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

public func cancelDelete() {
    guard case .deleting = state, !todos.isEmpty else { return }
    state = .loaded(todos)
}
```

**Binding**:
```swift
private var deleteConfirmationBinding: Binding<Bool> {
    Binding(
        get: {
            if case .deleting = viewModel.state { return true }
            return false
        },
        set: { if !$0 { viewModel.cancelDelete() } }
    )
}
```

### 3. Form Validation

**FormData**:
```swift
public struct FormData: Equatable {
    public var title: String = ""
    public var notes: String = ""
    // ... other fields

    public var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
```

**ViewModel**:
```swift
public var isValid: Bool {
    formData.isValid
}

public func save() {
    guard formData.isValid else { return }

    state = .saving
    Task {
        // Save logic
    }
}
```

**View**:
```swift
Button("Save") {
    viewModel.save()
}
.disabled(!viewModel.isValid)
```

### 4. Filter with Segmented Picker

**FilterOption**:
```swift
public enum FilterOption: String, CaseIterable, Identifiable, Sendable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"

    public var id: String { rawValue }
}
```

**View**:
```swift
Picker("Filter", selection: currentFilterBinding) {
    ForEach(FilterOption.allCases) { option in
        Text(option.rawValue).tag(option)
    }
}
.pickerStyle(.segmented)
```

**Binding**:
```swift
private var currentFilterBinding: Binding<FilterOption> {
    Binding(
        get: { viewModel.currentFilter },
        set: { newValue in
            viewModel.filterChanged(to: newValue)
        }
    )
}
```

**ViewModel**:
```swift
public var currentFilter: FilterOption = .all

public func filterChanged(to filter: FilterOption) {
    currentFilter = filter
    loadTodos()
}

public func loadTodos() {
    state = .loading
    Task {
        do {
            let todos = try await useCase.fetchTodos(filter: currentFilter)
            state = .loaded(todos)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
```

### 5. Empty State Handling

**Always Show Filter Picker Pattern**:
```swift
@ViewBuilder
private func todoListContent(_ todos: [TodoItemAdapter]) -> some View {
    VStack(spacing: 0) {
        // Always show filter picker (prevents tab bar disappearing)
        filterPicker
            .padding(.horizontal)
            .padding(.top, 8)

        // Show list or empty state
        if todos.isEmpty {
            EmptyStateView(
                icon: "checklist",
                message: "No todos yet",
                actionTitle: "Add Todo",
                action: { viewModel.addTodoTapped() }
            )
        } else {
            List {
                // Todo items
            }
        }
    }
}
```

**Key Point**: Wrap in VStack to always show filter picker, preventing tab bar from disappearing when list is empty.

### 6. Sheet Reload Pattern

**Problem**: New/edited todos don't appear until app restart.

**Solution**: Reload list in sheet `onDismiss`:

```swift
TodoListView(viewModel: viewModel)
    .sheet(isPresented: $showingAddSheet) {
        // Reload todos when sheet is dismissed
        viewModel.loadTodos()
    } content: {
        TodoDetailView(...)
    }
```

**Why This Works**:
- SwiftData changes are persisted when save() completes
- Sheet dismisses when save state is .saved
- onDismiss callback triggers list reload
- Reload fetches updated data from SwiftData

### 7. Priority and Category Display

**Priority Badge**:
```swift
struct PriorityBadgeView: View {
    let priority: TodoPriority

    var body: some View {
        if priority != .none {
            Label {
                Text(priority.displayName)
            } icon: {
                Image(systemName: priority.systemImageName)
            }
            .font(.caption)
            .foregroundStyle(priority.color)
        }
    }
}
```

**Category Tags**:
```swift
ScrollView(.horizontal, showsIndicators: false) {
    HStack(spacing: 4) {
        ForEach(todo.categories) { category in
            CategoryTagView(category: category)
        }
    }
}

struct CategoryTagView: View {
    let category: CategoryAdapter

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(category.color)
                .frame(width: 8, height: 8)

            Text(category.name)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(category.color.opacity(0.2))
        .clipShape(Capsule())
    }
}
```

### 8. SwiftUI Previews with DevPreview

**DevPreview Package**:
```swift
@MainActor
public final class DevPreview {
    public static let shared = DevPreview()

    public let container: DIContainer

    private init() {
        // Create in-memory ModelContainer
        let schema = Schema([Todo.self, Category.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let modelContainer = try! ModelContainer(for: schema, configurations: [config])

        // Setup DI with in-memory data
        container = AppComposition.setupDependencies(modelContainer: modelContainer)

        // Seed data
        seedData(modelContainer: modelContainer)
    }

    private func seedData(modelContainer: ModelContainer) {
        let context = ModelContext(modelContainer)
        // Create sample todos
    }
}
```

**Usage in Previews**:
```swift
#Preview("Todo List - Loaded") {
    let container = DevPreview.shared.container
    let builder = TodoListBuilder(container: container)
    let router = PreviewTodoListRouter()
    return try! builder.buildTodoListView(router: router)
}

#Preview("Todo Detail - New") {
    let container = DevPreview.shared.container
    let builder = TodoDetailBuilder(container: container)
    return try! builder.buildTodoDetailView(existingTodo: nil)
}
```

### 9. Adding New Features

**Step 1**: Create SPM package:
```bash
# In workspace root
mkdir -p NewFeature/Sources/NewFeature
mkdir -p NewFeature/Tests/NewFeatureTests
# Create Package.swift
```

**Step 2**: Define dependencies in Package.swift:
```swift
let package = Package(
    name: "NewFeature",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "NewFeature", targets: ["NewFeature"])
    ],
    dependencies: [
        .package(path: "../DependencyContainer"),
        .package(path: "../TodoUseCase"),
        // ... other dependencies
    ],
    targets: [
        .target(
            name: "NewFeature",
            dependencies: [
                "DependencyContainer",
                "TodoUseCase"
            ]
        )
    ]
)
```

**Step 3**: Create Builder:
```swift
@MainActor
@Observable
public final class NewFeatureBuilder {
    private let container: DIContainer

    public init(container: DIContainer) {
        self.container = container
    }

    public func buildView(router: NewFeatureRouterProtocol) throws -> NewFeatureView {
        let useCase = try container.requireResolve(TodoUseCaseProtocol.self)
        let viewModel = NewFeatureViewModel(useCase: useCase, router: router)
        return NewFeatureView(viewModel: viewModel)
    }
}
```

**Step 4**: Register in AppComposition (if new use case needed):
```swift
// In AppComposition.setupDependencies
let newUseCase = try! NewFeatureUseCase(container: container)
container.register(NewFeatureUseCaseProtocol.self, newUseCase)
```

---

## Important Constraints

### 1. SwiftData Models Location
- **Models are in TodoUseCase**, not TodoRepository
- Reason: Avoid circular dependencies
- TodoRepository imports TodoUseCase to access models
- Use `import class TodoUseCase.Todo` for specific imports

### 2. @Model and @MainActor
- **Never add @MainActor to @Model classes**
- `@Model` macro handles actor isolation in Swift 6
- Adding both causes compiler errors
- SwiftData operations must be on @MainActor

### 3. @State for ViewModels
- **Use @State, not @Bindable**
- Create custom bindings for form fields
- More explicit and easier to debug
- `@Bindable` is for different use cases

### 4. FormData Pattern
- **Stored property with didSet, not computed**
- Computed properties don't work with nested bindings
- `didSet` keeps state machine in sync

### 5. Sheet Reload
- **Always reload in onDismiss**
- Required for new/edited todos to appear
- Store view model reference in coordinator
- Call `viewModel.loadTodos()` in sheet callbacks

### 6. Filter Picker Visibility
- **Always show filter picker in VStack**
- Prevents tab bar from disappearing
- Even when list is empty
- Wrap list/empty state in VStack

### 7. CloudKit Compatibility
- All SwiftData properties have defaults or are optional
- No `@Attribute(.unique)` (CloudKit doesn't support)
- All relationships optional
- Use `cloudKitDatabase: .automatic` in ModelConfiguration

### 8. No Force Unwrapping
- Use safe unwrapping: `if let`, `guard let`
- Use `requireResolve()` for DI (throws on failure)
- Only `try!` in app init where failure is fatal

### 9. Protocol-First Development
- Define protocols for cross-module dependencies
- Concrete types are implementation details
- Enables testing and flexibility

### 10. Builder Pattern is Mandatory
- Features composed via builder classes
- Never instantiate feature views directly
- Builders encapsulate dependency injection

---

## SwiftData Schema

### Todo Model
```swift
@Model
public final class Todo {
    public var title: String = ""
    public var notes: String = ""
    public var isCompleted: Bool = false
    public var createdAt: Date = Date()
    public var dueDate: Date? = nil
    public var priorityRawValue: Int = 0  // 0=none, 1=low, 2=medium, 3=high
    public var sortOrder: Int = 0  // For drag-and-drop reordering

    @Relationship(deleteRule: .nullify, inverse: \Category.todos)
    public var categories: [Category]? = []

    public init(title: String = "", notes: String = "", dueDate: Date? = nil, priority: TodoPriority = .none) {
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.priorityRawValue = priority.rawValue
        self.createdAt = Date()
        self.sortOrder = 0
    }
}
```

### Category Model
```swift
@Model
public final class Category {
    public var name: String = ""
    public var colorHex: String = "#007AFF"  // Default blue
    public var createdAt: Date = Date()

    @Relationship(deleteRule: .nullify)
    public var todos: [Todo]? = []

    public init(name: String = "", colorHex: String = "#007AFF") {
        self.name = name
        self.colorHex = colorHex
        self.createdAt = Date()
    }
}
```

### TodoPriority Enum
```swift
public enum TodoPriority: Int, Codable, CaseIterable, Sendable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3

    public var displayName: String {
        switch self {
        case .none: return "None"
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }

    public var systemImageName: String {
        switch self {
        case .none: return ""
        case .low: return "arrow.down"
        case .medium: return "equal"
        case .high: return "arrow.up"
        }
    }

    public var color: Color {
        switch self {
        case .none: return .gray
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}
```

---

## Best Practices Summary

1. **Separation of Concerns**: Each layer has a single responsibility
2. **Dependency Injection**: All dependencies injected via constructors
3. **Protocol Abstraction**: Communicate through interfaces, not concrete types
4. **Unidirectional Flow**: Data flows outer → inner layers only
5. **State Machines**: Use enums for view state management
6. **Thread Safety**: Use `@MainActor` for SwiftData and UI code
7. **Error Handling**: Map errors at each layer boundary
8. **Testing**: Write unit tests with protocol-based mocks and fakes
9. **Modular Design**: Each feature is an independent SPM package
10. **Builder Pattern**: Compose features via builder classes
11. **Custom Bindings**: Create explicit bindings when using @State
12. **SwiftData Best Practices**: Models in shared package, CloudKit-compatible schema

---

## Conclusion

This architecture ensures:
- **Scalability**: Easy to add new features without affecting existing code
- **Testability**: Protocol-oriented design enables easy mocking
- **Maintainability**: Clear separation of concerns and consistent patterns
- **Type Safety**: Leverages Swift's type system and strict concurrency
- **Readability**: Predictable structure and naming conventions
- **Persistence**: SwiftData with CloudKit sync for cross-device data
- **Modularity**: 11 SPM packages with clear boundaries

By following these principles and patterns, the codebase remains clean, testable, and production-ready.
