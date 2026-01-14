# Sifo Package Guide

Detailed documentation for each Swift Package Manager (SPM) package in the Sifo project.

## Table of Contents

1. [Overview](#overview)
2. [DependencyContainer](#dependencycontainer)
3. [TodoUseCase](#todousecase)
4. [TodoRepository](#todorepository)
5. [TodoListView](#todolistview)
6. [TodoDetailView](#tododetailview)
7. [TodoUI](#todoui)
8. [TabBarView](#tabbarview)
9. [DevPreview](#devpreview)
10. [Creating New Packages](#creating-new-packages)

---

## Overview

Sifo uses a modular architecture with 8 local SPM packages organized by Clean Architecture layers:

```
Infrastructure Layer:
  - DependencyContainer
  - DevPreview

Data Layer:
  - TodoRepository

Business Logic Layer:
  - TodoUseCase

Presentation Layer:
  - TodoListView
  - TodoDetailView
  - TodoUI
  - TabBarView
```

### Why Packages?

**Benefits:**
- **Modularity**: Clear separation of concerns
- **Reusability**: Packages can be reused across projects
- **Build Performance**: Incremental compilation
- **Testing**: Isolated unit tests per package
- **Dependency Management**: Explicit dependency graphs

---

## DependencyContainer

### Purpose

Simple, type-safe dependency injection container for managing app dependencies.

### Location

```
DependencyContainer/
├── Package.swift
├── Sources/
│   └── DependencyContainer/
│       └── DIContainer.swift
└── Tests/
    └── DependencyContainerTests/
        └── DIContainerTests.swift
```

### Dependencies

None (foundation package)

### Key Types

#### DIContainer

```swift
@MainActor
@Observable
public final class DIContainer {
    public init()
    public func register<T>(_ type: T.Type, _ instance: T)
    public func requireResolve<T>(_ type: T.Type) throws -> T
}
```

### Package.swift

```swift
let package = Package(
    name: "DependencyContainer",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "DependencyContainer",
            targets: ["DependencyContainer"]
        )
    ],
    targets: [
        .target(name: "DependencyContainer"),
        .testTarget(
            name: "DependencyContainerTests",
            dependencies: ["DependencyContainer"]
        )
    ]
)
```

### Usage Example

```swift
import DependencyContainer

let container = DIContainer()

// Register
container.register(TodoRepositoryProtocol.self, repository)

// Resolve
let repo = try container.requireResolve(TodoRepositoryProtocol.self)
```

### Testing

```swift
@Test("Resolve registered dependency")
func testResolve() throws {
    let container = DIContainer()
    let service = MockService()
    container.register(ServiceProtocol.self, service)

    let resolved = try container.requireResolve(ServiceProtocol.self)
    #expect(resolved === service)
}
```

---

## TodoUseCase

### Purpose

Business logic layer containing use cases, domain models, adapters, and SwiftData models.

### Location

```
TodoUseCase/
├── Package.swift
├── Sources/
│   └── TodoUseCase/
│       ├── TodoUseCase.swift
│       ├── Models/
│       │   ├── Todo.swift
│       │   ├── Category.swift
│       │   ├── TodoPriority.swift
│       │   ├── FilterOption.swift
│       │   └── TodoError.swift
│       ├── Adapters/
│       │   ├── TodoItemAdapter.swift
│       │   └── CategoryAdapter.swift
│       ├── Protocols/
│       │   └── TodoUseCaseProtocol.swift
│       └── Interfaces/
│           └── TodoRepositoryProtocol.swift
└── Tests/
    └── TodoUseCaseTests/
        └── TodoUseCaseTests.swift
```

### Dependencies

- `DependencyContainer`

### Key Types

#### SwiftData Models

**Todo.swift:**
- CloudKit-compatible SwiftData model
- All properties have defaults or are optional
- Relationships are optional
- No `@MainActor` (handled by `@Model` macro)

**Category.swift:**
- Many-to-many relationship with Todo
- Color-coded organization

#### Adapters (DTOs)

**TodoItemAdapter:**
- Sendable, thread-safe DTO
- UI-friendly computed properties
- Transforms SwiftData models for presentation layer

**CategoryAdapter:**
- Category DTO with color support

#### Domain Models

**TodoPriority:**
- Enum with display properties (name, icon, color)

**FilterOption:**
- Filter options for todo list

**TodoError:**
- Domain-specific errors with localized descriptions

### Package.swift

```swift
let package = Package(
    name: "TodoUseCase",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "TodoUseCase", targets: ["TodoUseCase"])
    ],
    dependencies: [
        .package(path: "../DependencyContainer")
    ],
    targets: [
        .target(
            name: "TodoUseCase",
            dependencies: ["DependencyContainer"]
        ),
        .testTarget(
            name: "TodoUseCaseTests",
            dependencies: ["TodoUseCase"]
        )
    ]
)
```

### Design Decisions

#### Why Models Live Here?

Models are in `TodoUseCase` (not `TodoRepository`) to avoid circular dependencies:

```
TodoRepository → TodoUseCase (imports models)
TodoListView → TodoUseCase (uses adapters)
```

This ensures one-way dependencies.

#### Why Adapters?

Adapters decouple SwiftData models from views:
- Models are tied to ModelContext lifecycle
- Adapters are Sendable for concurrency safety
- Adapters add UI-specific computed properties
- Views don't need SwiftData imports

### Testing

```swift
@Test("Create todo validates title")
func testValidation() async throws {
    let container = DIContainer()
    container.register(TodoRepositoryProtocol.self, FakeRepository())
    let useCase = try TodoUseCase(container: container)

    await #expect(throws: TodoError.self) {
        try await useCase.createTodo(
            title: "   ",
            notes: "",
            dueDate: nil,
            priority: .none,
            categoryIds: []
        )
    }
}
```

---

## TodoRepository

### Purpose

Data access layer implementing SwiftData persistence.

### Location

```
TodoRepository/
├── Package.swift
├── Sources/
│   └── TodoRepository/
│       └── TodoRepository.swift
└── Tests/
    └── TodoRepositoryTests/
        └── TodoRepositoryTests.swift
```

### Dependencies

- `DependencyContainer`
- `TodoUseCase` (for model types)

### Key Types

#### TodoRepository

```swift
@MainActor
public final class TodoRepository: TodoRepositoryProtocol {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext)

    // CRUD operations
    public func createTodo(...) async throws -> Todo
    public func fetchTodos(isCompleted: Bool?) async throws -> [Todo]
    public func updateTodo(_ todo: Todo) async throws
    public func deleteTodo(_ todo: Todo) async throws
    public func reorderTodos(...) async throws
}
```

### Package.swift

```swift
let package = Package(
    name: "TodoRepository",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "TodoRepository", targets: ["TodoRepository"])
    ],
    dependencies: [
        .package(path: "../DependencyContainer"),
        .package(path: "../TodoUseCase")
    ],
    targets: [
        .target(
            name: "TodoRepository",
            dependencies: [
                "DependencyContainer",
                "TodoUseCase"
            ]
        ),
        .testTarget(
            name: "TodoRepositoryTests",
            dependencies: ["TodoRepository"]
        )
    ]
)
```

### Design Patterns

#### FetchDescriptor Usage

```swift
public func fetchTodos(isCompleted: Bool?) async throws -> [Todo] {
    var descriptor = FetchDescriptor<Todo>(
        sortBy: [SortDescriptor(\Todo.sortOrder, order: .forward)]
    )

    if let isCompleted {
        descriptor.predicate = #Predicate { $0.isCompleted == isCompleted }
    }

    return try modelContext.fetch(descriptor)
}
```

#### Manual Reordering

Repository can't use SwiftUI's `.move()`, so implements manual array manipulation:

```swift
public func reorderTodos(from source: IndexSet, to destination: Int, in todos: [Todo]) async throws {
    var mutableTodos = todos

    // Manual reordering
    let movedItems = source.sorted().reversed().map { mutableTodos.remove(at: $0) }
    mutableTodos.insert(contentsOf: movedItems.reversed(), at: destination)

    // Update sortOrder for persistence
    for (index, todo) in mutableTodos.enumerated() {
        todo.sortOrder = index
    }

    try modelContext.save()
}
```

### Testing

```swift
@Test("Create todo persists")
func testCreate() async throws {
    // In-memory container
    let schema = Schema([Todo.self, Category.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [config])
    let context = ModelContext(container)
    let repository = TodoRepository(modelContext: context)

    // Create
    let todo = try await repository.createTodo(
        title: "Test",
        notes: "",
        dueDate: nil,
        priority: .none
    )

    // Verify
    let fetched = try await repository.fetchTodos(isCompleted: nil)
    #expect(fetched.count == 1)
    #expect(fetched.first?.title == "Test")
}
```

---

## TodoListView

### Purpose

Presentation layer for todo list feature with filtering, reordering, and deletion.

### Location

```
TodoListView/
├── Package.swift
├── Sources/
│   └── TodoListView/
│       ├── TodoListView.swift
│       ├── TodoListViewModel.swift
│       ├── TodoListBuilder.swift
│       └── TodoListRouter.swift
└── Tests/
    └── TodoListViewTests/
        └── TodoListViewTests.swift
```

### Dependencies

- `DependencyContainer`
- `TodoUseCase`
- `TodoUI`

### Key Types

#### TodoListViewModel

State machine-based view model:

```swift
@MainActor
@Observable
public final class TodoListViewModel {
    public enum State: Equatable {
        case idle
        case loading
        case loaded([TodoItemAdapter])
        case error(String)
        case deleting(TodoItemAdapter)
    }

    public var state: State = .idle
    public var currentFilter: FilterOption = .all

    public func loadTodos()
    public func filterChanged(to: FilterOption)
    public func toggleCompletion(for: TodoItemAdapter)
    public func deleteTodoConfirmation(for: TodoItemAdapter)
    public func confirmDelete()
    public func reorderTodos(from: IndexSet, to: Int)
}
```

#### TodoListBuilder

Factory for dependency injection:

```swift
@MainActor
@Observable
public final class TodoListBuilder {
    public func buildTodoListView(router: TodoListRouterProtocol) throws -> TodoListView
}
```

#### TodoListRouterProtocol

Navigation abstraction:

```swift
@MainActor
public protocol TodoListRouterProtocol {
    func navigateToAddTodo()
    func navigateToEditTodo(_ todo: TodoItemAdapter)
}
```

### Package.swift

```swift
let package = Package(
    name: "TodoListView",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "TodoListView", targets: ["TodoListView"])
    ],
    dependencies: [
        .package(path: "../DependencyContainer"),
        .package(path: "../TodoUseCase"),
        .package(path: "../TodoUI")
    ],
    targets: [
        .target(
            name: "TodoListView",
            dependencies: [
                "DependencyContainer",
                "TodoUseCase",
                "TodoUI"
            ]
        ),
        .testTarget(
            name: "TodoListViewTests",
            dependencies: ["TodoListView"]
        )
    ]
)
```

### Design Patterns

#### State Machine

Clear state transitions prevent impossible states:

```swift
// Load todos
state = .loading
// ... fetch
state = .loaded(todos)

// Delete confirmation
state = .deleting(todo)
// ... confirm
state = .loading  // Then reload
```

#### Custom Bindings

```swift
private var currentFilterBinding: Binding<FilterOption> {
    Binding(
        get: { viewModel.currentFilter },
        set: { viewModel.filterChanged(to: $0) }
    )
}
```

### Testing

```swift
@Test("Load todos success")
func testLoad() async throws {
    let fake = FakeTodoUseCase()
    fake.todos = [TodoItemAdapter(...)]
    let vm = TodoListViewModel(useCase: fake, router: FakeRouter())

    vm.loadTodos()
    try await Task.sleep(for: .milliseconds(100))

    #expect(vm.state == .loaded(fake.todos))
}
```

---

## TodoDetailView

### Purpose

Presentation layer for adding/editing todos with form validation.

### Location

```
TodoDetailView/
├── Package.swift
├── Sources/
│   └── TodoDetailView/
│       ├── TodoDetailView.swift
│       ├── TodoDetailViewModel.swift
│       └── TodoDetailBuilder.swift
└── Tests/
    └── TodoDetailViewTests/
        └── TodoDetailViewTests.swift
```

### Dependencies

- `DependencyContainer`
- `TodoUseCase`
- `TodoUI`

### Key Types

#### TodoDetailViewModel

Form state machine:

```swift
@MainActor
@Observable
public final class TodoDetailViewModel {
    public enum State: Equatable {
        case editing(FormData)
        case saving
        case saved
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

    public var state: State
    public var formData: FormData

    public func save()
}
```

### Package.swift

```swift
let package = Package(
    name: "TodoDetailView",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "TodoDetailView", targets: ["TodoDetailView"])
    ],
    dependencies: [
        .package(path: "../DependencyContainer"),
        .package(path: "../TodoUseCase"),
        .package(path: "../TodoUI")
    ],
    targets: [
        .target(
            name: "TodoDetailView",
            dependencies: [
                "DependencyContainer",
                "TodoUseCase",
                "TodoUI"
            ]
        ),
        .testTarget(
            name: "TodoDetailViewTests",
            dependencies: ["TodoDetailView"]
        )
    ]
)
```

### Design Patterns

#### FormData with didSet

```swift
public var formData: FormData = FormData() {
    didSet {
        if case .editing = state {
            state = .editing(formData)
        }
    }
}
```

**Why not computed?** Computed properties don't work well with nested bindings.

#### @State for ViewModel

```swift
// In view
@State public var viewModel: TodoDetailViewModel

// Custom bindings
private var titleBinding: Binding<String> {
    Binding(
        get: { viewModel.formData.title },
        set: { viewModel.formData.title = $0 }
    )
}
```

### Testing

```swift
@Test("Save creates todo")
func testSave() async throws {
    let fake = FakeTodoUseCase()
    let vm = TodoDetailViewModel(
        useCase: fake,
        existingTodo: nil,
        availableCategories: []
    )

    vm.formData.title = "New Todo"
    vm.save()
    try await Task.sleep(for: .milliseconds(100))

    #expect(fake.createTodoCalled == true)
    #expect(vm.state == .saved)
}
```

---

## TodoUI

### Purpose

Shared UI components used across multiple features.

### Location

```
TodoUI/
├── Package.swift
├── Sources/
│   └── TodoUI/
│       ├── TodoRowView.swift
│       ├── EmptyStateView.swift
│       ├── ErrorView.swift
│       ├── CategoryTagView.swift
│       └── PriorityBadgeView.swift
└── Tests/
    └── TodoUITests/
        └── TodoUITests.swift
```

### Dependencies

- `TodoUseCase` (for adapter types)

### Key Components

#### TodoRowView

Complete todo list item with checkbox, badges, and categories.

```swift
public struct TodoRowView: View {
    let todo: TodoItemAdapter
    let onToggle: () -> Void

    public init(todo: TodoItemAdapter, onToggle: @escaping () -> Void)
}
```

**Features:**
- Checkbox for completion
- Strikethrough when completed
- Due date badge (color-coded)
- Priority badge
- Category tags (horizontal scroll)

#### EmptyStateView

Reusable empty state with action button.

```swift
public struct EmptyStateView: View {
    let icon: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    public init(icon: String, message: String, actionTitle: String, action: @escaping () -> Void)
}
```

Uses `ContentUnavailableView` for native iOS feel.

#### ErrorView

Error display with retry button.

```swift
public struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    public init(message: String, retryAction: @escaping () -> Void)
}
```

#### CategoryTagView

Colored category badge.

```swift
public struct CategoryTagView: View {
    let category: CategoryAdapter

    public init(category: CategoryAdapter)
}
```

#### PriorityBadgeView

Priority indicator with icon and color.

```swift
public struct PriorityBadgeView: View {
    let priority: TodoPriority

    public init(priority: TodoPriority)
}
```

### Package.swift

```swift
let package = Package(
    name: "TodoUI",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "TodoUI", targets: ["TodoUI"])
    ],
    dependencies: [
        .package(path: "../TodoUseCase")
    ],
    targets: [
        .target(
            name: "TodoUI",
            dependencies: ["TodoUseCase"]
        ),
        .testTarget(
            name: "TodoUITests",
            dependencies: ["TodoUI"]
        )
    ]
)
```

### Design Philosophy

- **Reusable**: Used across multiple features
- **Self-contained**: No external state dependencies
- **Callback-based**: Actions via closures
- **Preview-friendly**: Easy to preview in Xcode

---

## TabBarView

### Purpose

Main navigation container using native SwiftUI Tab API.

### Location

```
TabBarView/
├── Package.swift
├── Sources/
│   └── TabBarView/
│       ├── TabBarView.swift
│       └── TabBarBuilder.swift
└── Tests/
    └── TabBarViewTests/
        └── TabBarViewTests.swift
```

### Dependencies

- `DependencyContainer`
- `TodoListView`
- `TodoDetailView`
- `TodoUseCase`

### Key Types

#### TabBarView

Main tab container with coordinator pattern for sheet management.

```swift
public struct TabBarView: View {
    private let container: DIContainer

    public init(container: DIContainer)

    public var body: some View {
        TabView {
            Tab("Todos", systemImage: "checklist") {
                TodoListCoordinator(container: container)
            }
        }
    }
}
```

#### TodoListCoordinator

Manages list view and sheet presentation.

```swift
private struct TodoListCoordinator: View {
    @State private var showingAddSheet = false
    @State private var editingTodo: TodoItemAdapter?
    @State private var listViewModel: TodoListViewModel?

    var body: some View {
        // List view
        // Sheet for add
        // Sheet for edit
        // onDismiss: reload list
    }
}
```

### Package.swift

```swift
let package = Package(
    name: "TabBarView",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "TabBarView", targets: ["TabBarView"])
    ],
    dependencies: [
        .package(path: "../DependencyContainer"),
        .package(path: "../TodoListView"),
        .package(path: "../TodoDetailView"),
        .package(path: "../TodoUseCase")
    ],
    targets: [
        .target(
            name: "TabBarView",
            dependencies: [
                "DependencyContainer",
                "TodoListView",
                "TodoDetailView",
                "TodoUseCase"
            ]
        ),
        .testTarget(
            name: "TabBarViewTests",
            dependencies: ["TabBarView"]
        )
    ]
)
```

### Design Patterns

#### Router Implementation

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

#### Sheet Reload Pattern

```swift
.sheet(isPresented: $showingAddSheet) {
    // onDismiss: Reload list
    viewModel.loadTodos()
} content: {
    // Present TodoDetailView
}
```

**Critical:** Store `listViewModel` reference to call `loadTodos()` on dismiss.

---

## DevPreview

### Purpose

Preview environment with in-memory SwiftData and mock dependencies.

### Location

```
DevPreview/
├── Package.swift
├── Sources/
│   └── DevPreview/
│       └── DevPreview.swift
└── Tests/
    └── DevPreviewTests/
        └── DevPreviewTests.swift
```

### Dependencies

- `DependencyContainer`
- `TodoRepository`
- `TodoUseCase`

### Key Types

#### DevPreview

Singleton providing preview environment.

```swift
@MainActor
public final class DevPreview {
    public static let shared: DevPreview

    public let container: DIContainer

    private init() {
        // Create in-memory ModelContainer
        // Setup dependencies
        // Seed sample data
    }
}
```

### Package.swift

```swift
let package = Package(
    name: "DevPreview",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "DevPreview", targets: ["DevPreview"])
    ],
    dependencies: [
        .package(path: "../DependencyContainer"),
        .package(path: "../TodoRepository"),
        .package(path: "../TodoUseCase")
    ],
    targets: [
        .target(
            name: "DevPreview",
            dependencies: [
                "DependencyContainer",
                "TodoRepository",
                "TodoUseCase"
            ]
        ),
        .testTarget(
            name: "DevPreviewTests",
            dependencies: ["DevPreview"]
        )
    ]
)
```

### Usage

```swift
#Preview("Todo List") {
    let container = DevPreview.shared.container
    let builder = TodoListBuilder(container: container)
    let router = PreviewTodoListRouter()
    return try! builder.buildTodoListView(router: router)
}

#Preview("Todo Detail - New") {
    let container = DevPreview.shared.container
    let builder = TodoDetailBuilder(container: container)
    return try! await builder.buildTodoDetailView(existingTodo: nil)
}
```

### Design Decisions

#### Why Singleton?

- Shared state across previews
- Performance (single in-memory container)
- Consistent seed data

#### Mock Routers

```swift
final class PreviewTodoListRouter: TodoListRouterProtocol {
    func navigateToAddTodo() {
        print("Preview: Navigate to add")
    }

    func navigateToEditTodo(_ todo: TodoItemAdapter) {
        print("Preview: Navigate to edit \(todo.title)")
    }
}
```

---

## Creating New Packages

### Step-by-Step Guide

#### 1. Create Package Directory

```bash
mkdir -p NewPackage/Sources/NewPackage
mkdir -p NewPackage/Tests/NewPackageTests
cd NewPackage
```

#### 2. Create Package.swift

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NewPackage",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "NewPackage",
            targets: ["NewPackage"]
        )
    ],
    dependencies: [
        .package(path: "../DependencyContainer"),
        .package(path: "../TodoUseCase")
        // Add other dependencies as needed
    ],
    targets: [
        .target(
            name: "NewPackage",
            dependencies: [
                "DependencyContainer",
                "TodoUseCase"
            ]
        ),
        .testTarget(
            name: "NewPackageTests",
            dependencies: ["NewPackage"]
        )
    ]
)
```

#### 3. Add to Workspace

1. Close Xcode
2. Open `Sifo.xcworkspace` in text editor or Finder
3. The workspace automatically detects local packages in subdirectories

#### 4. Create Initial Files

**Sources/NewPackage/NewPackage.swift:**

```swift
import Foundation

public struct NewPackage {
    public init() {}

    public func exampleMethod() {
        print("Hello from NewPackage")
    }
}
```

**Tests/NewPackageTests/NewPackageTests.swift:**

```swift
import Testing
@testable import NewPackage

@Suite("NewPackage Tests")
struct NewPackageTests {
    @Test("Example test")
    func testExample() {
        let package = NewPackage()
        package.exampleMethod()
        // Assertions
    }
}
```

#### 5. Add to Main App

Update main app's dependencies:

**Sifo/Sifo.xcodeproj → General → Frameworks:**
- Add `NewPackage`

Or in code:

```swift
import NewPackage

let instance = NewPackage()
```

#### 6. Build and Test

```bash
# Build package
swift build --package-path NewPackage

# Test package
swift test --package-path NewPackage

# Build entire workspace
xcodebuild build -workspace Sifo.xcworkspace -scheme Sifo
```

### Package Checklist

Before finalizing a new package:

- [ ] Package.swift specifies iOS 26.0 platform
- [ ] All dependencies explicitly listed
- [ ] Test target created
- [ ] At least one test written
- [ ] Public API properly exported
- [ ] `@MainActor` annotations where needed
- [ ] Documentation comments added
- [ ] README.md in package root (optional but recommended)

---

## Package Best Practices

### Dependency Rules

1. **One-way dependencies**: No circular dependencies
2. **Minimal dependencies**: Only depend on what you need
3. **Protocol abstractions**: Depend on protocols, not concrete types

### Naming Conventions

- **Packages**: PascalCase (e.g., `TodoListView`)
- **Targets**: Match package name
- **Files**: Match type name
- **Tests**: Append `Tests` to target name

### Public API Guidelines

```swift
// ✅ Good: Clear, documented public API
/// Creates a new todo item
public func createTodo(title: String, notes: String) async throws -> TodoItemAdapter

// ❌ Bad: Internal details exposed
public var internalCache: [String: Any]
```

### Testing Practices

- Each package has its own test target
- Tests are isolated from other packages
- Use in-memory SwiftData for repository tests
- Use fake implementations for protocol testing

### Performance

- Keep packages focused (single responsibility)
- Minimize cross-package dependencies
- Use protocols for testability
- Consider build times when organizing

---

## Troubleshooting Packages

### "No such module 'PackageName'"

**Fixes:**
1. Clean build folder: `Cmd+Shift+K`
2. Delete derived data
3. Rebuild: `Cmd+B`
4. Verify Package.swift dependencies

### Package not showing in Xcode

**Fixes:**
1. Close Xcode
2. Delete `*.xcworkspace/xcshareddata`
3. Reopen workspace
4. File → Packages → Reset Package Cache

### Circular dependency error

**Analysis:**
```
A → B → C → A  (circular!)
```

**Fix:** Introduce protocol abstraction in shared package

---

## Summary

Sifo's package architecture provides:

- **Clear boundaries**: Each package has a single responsibility
- **Testability**: Isolated testing per package
- **Reusability**: Packages can be reused or extracted
- **Maintainability**: Changes are localized
- **Build performance**: Incremental compilation

Follow these patterns when extending the codebase.

---

**Last Updated:** January 2026
**Package Count:** 8
**Target iOS:** 26.0+
