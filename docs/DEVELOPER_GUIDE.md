# Sifo Developer Guide

A comprehensive guide for developers working on the Sifo iOS application.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Project Setup](#project-setup)
3. [Development Workflow](#development-workflow)
4. [Code Organization](#code-organization)
5. [Building New Features](#building-new-features)
6. [Testing](#testing)
7. [Debugging](#debugging)
8. [Performance Optimization](#performance-optimization)
9. [Common Tasks](#common-tasks)
10. [Troubleshooting](#troubleshooting)
11. [Contributing](#contributing)

---

## Getting Started

### Prerequisites

Before you begin, ensure you have:

- **macOS**: Sonoma (14.0) or later
- **Xcode**: 26.2 or later
- **Swift**: 6.2 (included with Xcode)
- **Git**: For version control
- **Apple Developer Account**: Optional (for device testing)

### System Requirements

- **Minimum iOS Target**: 26.0
- **Swift Concurrency**: Strict mode enabled
- **SwiftUI**: Modern patterns with `@Observable` macro
- **SwiftData**: For persistence with CloudKit sync

---

## Project Setup

### Cloning the Repository

```bash
# Clone the repository
git clone https://github.com/yourusername/Sifo.git
cd Sifo
```

### Opening the Project

**IMPORTANT:** Always open the **workspace**, not the project file.

```bash
# Open in Xcode
open Sifo.xcworkspace
```

**Why the workspace?**
- The project uses local Swift Package Manager (SPM) packages
- The `.xcworkspace` file includes both the main app and packages
- Opening `.xcodeproj` will cause build errors

### First Build

1. Select a simulator or device:
   - Recommended: iPhone 17 Pro Simulator
2. Press **Cmd+B** to build
3. Press **Cmd+R** to run

**Expected build time:** 10-30 seconds (first build may take longer)

### Verifying Setup

Run the test suite to verify everything is working:

```bash
# From terminal
xcodebuild test \
  -workspace Sifo.xcworkspace \
  -scheme Sifo \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# From Xcode
# Press Cmd+U to run all tests
```

---

## Development Workflow

### Branch Strategy

- **main**: Production-ready code
- **develop**: Integration branch for features
- **feature/***: Individual feature branches
- **bugfix/***: Bug fix branches

### Workflow Steps

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make changes**
   - Write code following project conventions
   - Add tests for new functionality
   - Update documentation as needed

3. **Test locally**
   ```bash
   # Run all tests
   xcodebuild test -workspace Sifo.xcworkspace -scheme Sifo \
     -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
   ```

4. **Commit changes**
   ```bash
   git add .
   git commit -m "feat(TodoList): add search functionality"
   ```

5. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   # Create pull request on GitHub
   ```

### Commit Message Convention

Follow conventional commits format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `test`: Adding/updating tests
- `docs`: Documentation changes
- `chore`: Maintenance tasks

**Examples:**
```
feat(TodoDetail): add category selection
fix(TodoList): resolve crash on empty state
refactor(UseCase): improve error handling
test(TodoRepository): add reorder tests
```

---

## Code Organization

### Project Structure

```
Sifo/
├── Sifo/                          # Main app target
│   ├── SifoApp.swift             # App entry point
│   ├── AppComposition.swift      # Dependency registration
│   └── ContentView.swift         # Placeholder view
├── DependencyContainer/           # DI framework
├── TodoRepository/                # Data layer
├── TodoUseCase/                   # Business logic
├── TodoListView/                  # List presentation
├── TodoDetailView/                # Detail presentation
├── TodoUI/                        # Shared UI components
├── TabBarView/                    # Navigation
├── DevPreview/                    # Preview support
└── docs/                          # Documentation
```

### Package Structure

Each SPM package follows this structure:

```
PackageName/
├── Package.swift                  # Package manifest
├── Sources/
│   └── PackageName/
│       ├── File1.swift
│       └── File2.swift
└── Tests/
    └── PackageNameTests/
        ├── File1Tests.swift
        └── File2Tests.swift
```

### File Organization Rules

1. **One type per file**: Each class, struct, or enum in its own file
2. **File naming**: Match the type name (e.g., `TodoListViewModel.swift`)
3. **Test file naming**: Append `Tests` (e.g., `TodoListViewModelTests.swift`)
4. **No nested types** in separate files (exceptions for small enums)

---

## Building New Features

### Step-by-Step Guide

#### 1. Plan the Feature

Before coding, determine:
- Which layer(s) does this feature touch?
- What new protocols are needed?
- What dependencies are required?

#### 2. Create Data Models (if needed)

**Location:** `TodoUseCase/Sources/TodoUseCase/Models/`

**Example: Adding a new Tag model**

```swift
// Tag.swift
import SwiftData
import Foundation

@Model
public final class Tag {
    public var name: String = ""
    public var colorHex: String = "#007AFF"
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

**CloudKit Checklist:**
- ✅ All properties have defaults or are optional
- ✅ No `@Attribute(.unique)`
- ✅ Relationships are optional
- ✅ No `@MainActor` on `@Model` classes

#### 3. Create Repository Methods

**Location:** `TodoRepository/Sources/TodoRepository/TodoRepository.swift`

**Example:**

```swift
public func fetchAllTags() async throws -> [Tag] {
    let descriptor = FetchDescriptor<Tag>(
        sortBy: [SortDescriptor(\Tag.name, order: .forward)]
    )
    return try modelContext.fetch(descriptor)
}

public func createTag(name: String, colorHex: String) async throws -> Tag {
    let tag = Tag(name: name, colorHex: colorHex)
    modelContext.insert(tag)
    try modelContext.save()
    return tag
}
```

**Update Protocol:**

```swift
// TodoUseCase/Sources/TodoUseCase/Interfaces/TodoRepositoryProtocol.swift
@MainActor
public protocol TodoRepositoryProtocol {
    // ... existing methods
    func fetchAllTags() async throws -> [Tag]
    func createTag(name: String, colorHex: String) async throws -> Tag
}
```

#### 4. Create Adapters (DTOs)

**Location:** `TodoUseCase/Sources/TodoUseCase/Adapters/`

**Example:**

```swift
// TagAdapter.swift
import Foundation
import SwiftData
import SwiftUI

public struct TagAdapter: Sendable, Identifiable, Hashable {
    public let id: PersistentIdentifier
    public let name: String
    public let colorHex: String

    public var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    public static func from(_ tag: Tag) -> TagAdapter {
        TagAdapter(
            id: tag.persistentModelID,
            name: tag.name,
            colorHex: tag.colorHex
        )
    }
}
```

#### 5. Add Use Case Methods

**Location:** `TodoUseCase/Sources/TodoUseCase/TodoUseCase.swift`

```swift
public func fetchTags() async throws -> [TagAdapter] {
    do {
        let tags = try await repository.fetchAllTags()
        return tags.map(TagAdapter.from)
    } catch {
        throw TodoError.unknown(error.localizedDescription)
    }
}

public func createTag(name: String, colorHex: String) async throws -> TagAdapter {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedName.isEmpty else {
        throw TodoError.validation("Tag name cannot be empty")
    }

    do {
        let tag = try await repository.createTag(name: trimmedName, colorHex: colorHex)
        return TagAdapter.from(tag)
    } catch {
        throw TodoError.unknown(error.localizedDescription)
    }
}
```

**Update Protocol:**

```swift
// TodoUseCase/Sources/TodoUseCase/Protocols/TodoUseCaseProtocol.swift
@MainActor
public protocol TodoUseCaseProtocol {
    // ... existing methods
    func fetchTags() async throws -> [TagAdapter]
    func createTag(name: String, colorHex: String) async throws -> TagAdapter
}
```

#### 6. Create ViewModel

**Location:** Create new package or add to existing

**Example: Tag Management ViewModel**

```swift
// TagManagementViewModel.swift
import Foundation
import Observation
import TodoUseCase

@MainActor
@Observable
public final class TagManagementViewModel {

    // State machine
    public enum State: Equatable {
        case idle
        case loading
        case loaded([TagAdapter])
        case error(String)
    }

    // Dependencies
    private let useCase: TodoUseCaseProtocol

    // State
    public var state: State = .idle

    // Computed properties
    public var tags: [TagAdapter] {
        if case .loaded(let items) = state { return items }
        return []
    }

    public init(useCase: TodoUseCaseProtocol) {
        self.useCase = useCase
    }

    // Actions
    public func loadTags() {
        state = .loading
        Task {
            do {
                let tags = try await useCase.fetchTags()
                state = .loaded(tags)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    public func createTag(name: String, colorHex: String) {
        Task {
            do {
                _ = try await useCase.createTag(name: name, colorHex: colorHex)
                loadTags()
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
}
```

#### 7. Create View

```swift
// TagManagementView.swift
import SwiftUI
import TodoUseCase

public struct TagManagementView: View {
    @State public var viewModel: TagManagementViewModel

    public init(viewModel: TagManagementViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    ProgressView()
                case .loaded(let tags):
                    tagList(tags)
                case .error(let message):
                    ErrorView(message: message) {
                        viewModel.loadTags()
                    }
                }
            }
            .navigationTitle("Tags")
            .toolbar {
                Button("Add", systemImage: "plus") {
                    // Show add sheet
                }
            }
            .onAppear {
                viewModel.loadTags()
            }
        }
    }

    @ViewBuilder
    private func tagList(_ tags: [TagAdapter]) -> some View {
        List(tags) { tag in
            HStack {
                Circle()
                    .fill(tag.color)
                    .frame(width: 12, height: 12)
                Text(tag.name)
            }
        }
    }
}
```

#### 8. Create Builder

```swift
// TagManagementBuilder.swift
import Foundation
import Observation
import DependencyContainer
import TodoUseCase

@MainActor
@Observable
public final class TagManagementBuilder {
    private let container: DIContainer

    public init(container: DIContainer) {
        self.container = container
    }

    public func buildTagManagementView() throws -> TagManagementView {
        let useCase = try container.requireResolve(TodoUseCaseProtocol.self)
        let viewModel = TagManagementViewModel(useCase: useCase)
        return TagManagementView(viewModel: viewModel)
    }
}
```

#### 9. Update AppComposition (if new dependencies)

```swift
// AppComposition.swift
@MainActor
final class AppComposition {
    static func setupDependencies(modelContainer: ModelContainer) -> DIContainer {
        let container = DIContainer()

        // Infrastructure
        let modelContext = ModelContext(modelContainer)

        // Data layer
        let todoRepository = TodoRepository(modelContext: modelContext)
        container.register(TodoRepositoryProtocol.self, todoRepository)

        // Business logic
        let todoUseCase = try! TodoUseCase(container: container)
        container.register(TodoUseCaseProtocol.self, todoUseCase)

        return container
    }
}
```

#### 10. Add to Navigation

Integrate into `TabBarView` or create new tab:

```swift
Tab("Tags", systemImage: "tag") {
    TagManagementCoordinator(container: container)
}
```

### Testing New Features

#### Unit Tests for ViewModel

```swift
// TagManagementViewModelTests.swift
import Testing
@testable import TagManagement

@MainActor
@Suite("TagManagementViewModel Tests")
struct TagManagementViewModelTests {

    @Test("Load tags updates state to loaded")
    func testLoadTagsSuccess() async throws {
        // Arrange
        let fakeUseCase = FakeTodoUseCase()
        fakeUseCase.tags = [
            TagAdapter(id: ..., name: "Work", colorHex: "#007AFF")
        ]
        let viewModel = TagManagementViewModel(useCase: fakeUseCase)

        // Act
        viewModel.loadTags()
        try await Task.sleep(for: .milliseconds(100))

        // Assert
        #expect(viewModel.state == .loaded(fakeUseCase.tags))
    }

    @Test("Create tag reloads tags")
    func testCreateTag() async throws {
        let fakeUseCase = FakeTodoUseCase()
        let viewModel = TagManagementViewModel(useCase: fakeUseCase)

        viewModel.createTag(name: "New Tag", colorHex: "#FF0000")
        try await Task.sleep(for: .milliseconds(100))

        #expect(fakeUseCase.createTagCalled == true)
    }
}
```

---

## Testing

### Testing Strategy

Sifo uses a layered testing approach:

1. **Unit Tests**: ViewModels and Use Cases
2. **Integration Tests**: Repository with in-memory SwiftData
3. **UI Tests**: Critical user flows (future)

### Running Tests

#### From Xcode

- **All tests**: `Cmd+U`
- **Single test**: Click diamond icon in gutter
- **Test navigator**: `Cmd+6` → select tests

#### From Command Line

```bash
# All tests
xcodebuild test \
  -workspace Sifo.xcworkspace \
  -scheme Sifo \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Specific package tests
swift test --package-path DependencyContainer
swift test --package-path TodoRepository
swift test --package-path TodoUseCase
```

### Writing Tests with Swift Testing

#### Basic Test Structure

```swift
import Testing
@testable import YourModule

@MainActor
@Suite("Feature Tests")
struct FeatureTests {

    @Test("Test description")
    func testSomething() async throws {
        // Arrange
        let sut = SystemUnderTest()

        // Act
        sut.performAction()

        // Assert
        #expect(sut.state == .expected)
    }
}
```

#### Async Testing

```swift
@Test("Async operation completes")
func testAsyncOperation() async throws {
    let viewModel = TodoListViewModel(useCase: fakeUseCase, router: fakeRouter)

    viewModel.loadTodos()

    // Wait for async operation
    try await Task.sleep(for: .milliseconds(100))

    #expect(viewModel.state == .loaded(...))
}
```

#### Testing Errors

```swift
@Test("Validation throws error for empty title")
func testValidationError() async throws {
    let useCase = TodoUseCase(container: container)

    await #expect(throws: TodoError.self) {
        try await useCase.createTodo(
            title: "   ",  // Empty after trimming
            notes: "",
            dueDate: nil,
            priority: .none,
            categoryIds: []
        )
    }
}
```

### Test Doubles

#### Fake Use Case

```swift
@MainActor
final class FakeTodoUseCase: TodoUseCaseProtocol {
    var todos: [TodoItemAdapter] = []
    var shouldThrowError = false
    var fetchTodosCalled = false

    func fetchTodos(filter: FilterOption) async throws -> [TodoItemAdapter] {
        fetchTodosCalled = true

        if shouldThrowError {
            throw TodoError.unknown("Test error")
        }

        switch filter {
        case .all:
            return todos
        case .active:
            return todos.filter { !$0.isCompleted }
        case .completed:
            return todos.filter { $0.isCompleted }
        }
    }

    // ... implement other protocol methods
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

### Coverage Goals

- **ViewModels**: 80%+ coverage
- **Use Cases**: 90%+ coverage
- **Repositories**: 70%+ coverage (integration tests)

---

## Debugging

### Common Debugging Techniques

#### 1. Breakpoints

```swift
// Set breakpoint and use LLDB commands
po viewModel.state         // Print object
p viewModel.todos.count    // Print value
expr state = .loading      // Modify value
```

#### 2. Print Debugging

```swift
public func loadTodos() {
    print("🔵 Loading todos with filter: \(currentFilter)")
    state = .loading

    Task {
        do {
            let items = try await useCase.fetchTodos(filter: currentFilter)
            print("✅ Loaded \(items.count) todos")
            state = .loaded(items)
        } catch {
            print("❌ Error loading todos: \(error)")
            state = .error(error.localizedDescription)
        }
    }
}
```

#### 3. View Debugging

Enable SwiftUI view debugging:

```swift
.onAppear {
    print("🟢 View appeared: \(Self.self)")
}
.onDisappear {
    print("🔴 View disappeared: \(Self.self)")
}
```

#### 4. State Machine Debugging

```swift
public var state: State = .idle {
    didSet {
        print("📱 State changed: \(oldValue) → \(state)")
    }
}
```

### Debugging SwiftData

#### View Model Context

```swift
// In repository
print("📦 ModelContext has changes: \(modelContext.hasChanges)")
print("📦 Inserted count: \(modelContext.insertedModelsArray.count)")
print("📦 Deleted count: \(modelContext.deletedModelsArray.count)")
```

#### Inspect Models

```swift
let todo = try await repository.fetchTodo(byId: id)
print("""
Todo details:
  ID: \(todo.persistentModelID)
  Title: \(todo.title)
  Completed: \(todo.isCompleted)
  Categories: \(todo.categories?.count ?? 0)
""")
```

### Debugging Concurrency

#### Thread Verification

```swift
@MainActor
public func loadTodos() {
    assert(Thread.isMainThread, "Must be on main thread")
    // ... rest of method
}
```

#### Task Debugging

```swift
Task {
    print("🔀 Task started on: \(Thread.current)")
    do {
        let items = try await useCase.fetchTodos(filter: currentFilter)
        print("🔀 Task completed on: \(Thread.current)")
        state = .loaded(items)
    } catch {
        print("🔀 Task failed on: \(Thread.current)")
        state = .error(error.localizedDescription)
    }
}
```

### Common Issues

#### Issue: State not updating UI

**Cause:** ViewModel not marked `@Observable` or view not using `@State`

**Fix:**
```swift
// ViewModel
@MainActor
@Observable  // ← Must have this
public final class TodoListViewModel {
    // ...
}

// View
@State public var viewModel: TodoListViewModel  // ← Must use @State
```

#### Issue: SwiftData crash

**Cause:** Accessing models off main thread

**Fix:**
```swift
@MainActor  // ← Ensure all repository methods are @MainActor
public final class TodoRepository: TodoRepositoryProtocol {
    // ...
}
```

#### Issue: Dependency not found

**Cause:** Not registered in `AppComposition`

**Fix:**
```swift
// AppComposition.swift
let useCase = try! TodoUseCase(container: container)
container.register(TodoUseCaseProtocol.self, useCase)  // ← Must register
```

---

## Performance Optimization

### SwiftData Best Practices

#### 1. Fetch Descriptors

Use predicates to filter at the database level:

```swift
// ✅ Good: Filter in database
var descriptor = FetchDescriptor<Todo>(
    sortBy: [SortDescriptor(\Todo.sortOrder)]
)
descriptor.predicate = #Predicate { !$0.isCompleted }
let todos = try modelContext.fetch(descriptor)

// ❌ Bad: Fetch all then filter in memory
let allTodos = try modelContext.fetch(FetchDescriptor<Todo>())
let activeTodos = allTodos.filter { !$0.isCompleted }
```

#### 2. Batch Operations

Group multiple saves:

```swift
// ✅ Good: Single save for multiple inserts
for todo in todosToCreate {
    modelContext.insert(todo)
}
try modelContext.save()  // Single save

// ❌ Bad: Save after each insert
for todo in todosToCreate {
    modelContext.insert(todo)
    try modelContext.save()  // Multiple saves
}
```

#### 3. Relationship Loading

Be mindful of relationship loading:

```swift
// Categories are loaded on access
let todo = try await repository.fetchTodo(byId: id)
let categoryCount = todo.categories?.count ?? 0  // Triggers load
```

### View Performance

#### 1. Avoid Expensive Computed Properties

```swift
// ✅ Good: Cache computed value
public struct TodoItemAdapter {
    public let dueDateFormatted: String  // Computed once in adapter

    public static func from(_ todo: Todo) -> TodoItemAdapter {
        let formatted = todo.dueDate.map { /* format */ } ?? ""
        return TodoItemAdapter(..., dueDateFormatted: formatted)
    }
}

// ❌ Bad: Compute on every render
extension Todo {
    var dueDateFormatted: String {
        dueDate.map { /* format */ } ?? ""  // Computed every time
    }
}
```

#### 2. Extract Subviews

```swift
// ✅ Good: Extract to separate view
struct TodoRow: View {
    let todo: TodoItemAdapter

    var body: some View {
        HStack {
            TodoCheckbox(isCompleted: todo.isCompleted)
            TodoTitle(todo: todo)
            TodoBadges(todo: todo)
        }
    }
}

// ❌ Bad: Everything inline
var body: some View {
    List {
        ForEach(todos) { todo in
            HStack {
                // ... lots of inline code
            }
        }
    }
}
```

### Profiling

Use Xcode Instruments:

1. **Time Profiler**: Find slow methods
2. **Allocations**: Track memory usage
3. **Leaks**: Detect memory leaks
4. **SwiftUI**: View update performance

---

## Common Tasks

### Adding a New Property to Todo

1. **Update SwiftData Model**
   ```swift
   // Todo.swift
   @Model
   public final class Todo {
       // ... existing properties
       public var newProperty: String = ""  // Add with default
   }
   ```

2. **Update Adapter**
   ```swift
   // TodoItemAdapter.swift
   public struct TodoItemAdapter {
       // ... existing properties
       public let newProperty: String

       public static func from(_ todo: Todo) -> TodoItemAdapter {
           TodoItemAdapter(
               // ... existing params
               newProperty: todo.newProperty
           )
       }
   }
   ```

3. **Update Create/Update Methods**
   ```swift
   // TodoRepository.swift
   public func createTodo(..., newProperty: String) async throws -> Todo {
       let todo = Todo(...)
       todo.newProperty = newProperty
       // ... rest of method
   }

   // TodoUseCase.swift
   public func createTodo(..., newProperty: String) async throws -> TodoItemAdapter {
       let todo = try await repository.createTodo(..., newProperty: newProperty)
       return TodoItemAdapter.from(todo)
   }
   ```

4. **Update UI**
   ```swift
   // TodoDetailView.swift - Add form field
   TextField("New Property", text: newPropertyBinding)
   ```

5. **Test**
   - Run tests to ensure no regressions
   - Add tests for new property

### Adding a New Filter Option

1. **Update FilterOption enum**
   ```swift
   public enum FilterOption: String, CaseIterable, Identifiable, Sendable {
       case all = "All"
       case active = "Active"
       case completed = "Completed"
       case highPriority = "High Priority"  // New

       public var completionFilter: Bool? {
           switch self {
           case .all: return nil
           case .active: return false
           case .completed: return true
           case .highPriority: return false  // Show uncompleted high priority
           }
       }

       public var priorityFilter: TodoPriority? {
           switch self {
           case .highPriority: return .high
           default: return nil
           }
       }
   }
   ```

2. **Update Repository**
   ```swift
   public func fetchTodos(
       isCompleted: Bool?,
       priority: TodoPriority?
   ) async throws -> [Todo] {
       var descriptor = FetchDescriptor<Todo>(
           sortBy: [SortDescriptor(\Todo.sortOrder)]
       )

       if let isCompleted {
           descriptor.predicate = #Predicate { $0.isCompleted == isCompleted }
       }

       if let priority {
           descriptor.predicate = #Predicate {
               $0.priorityRawValue == priority.rawValue
           }
       }

       return try modelContext.fetch(descriptor)
   }
   ```

3. **Update Use Case**
   ```swift
   public func fetchTodos(filter: FilterOption) async throws -> [TodoItemAdapter] {
       let todos = try await repository.fetchTodos(
           isCompleted: filter.completionFilter,
           priority: filter.priorityFilter
       )
       return todos.map(TodoItemAdapter.from)
   }
   ```

---

## Troubleshooting

### Build Errors

#### "No such module 'TodoUseCase'"

**Cause:** Package not properly linked

**Fix:**
1. Close Xcode
2. Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. Open `Sifo.xcworkspace`
4. Clean build folder: `Cmd+Shift+K`
5. Build: `Cmd+B`

#### "Cannot find 'DIContainer' in scope"

**Cause:** Missing import

**Fix:**
```swift
import DependencyContainer
```

### Runtime Errors

#### "Dependency not found: TodoUseCaseProtocol"

**Cause:** Not registered in `AppComposition`

**Fix:**
```swift
// AppComposition.swift
container.register(TodoUseCaseProtocol.self, todoUseCase)
```

#### SwiftData crash: "Context not on main actor"

**Cause:** Accessing SwiftData off main thread

**Fix:**
```swift
@MainActor
public final class TodoRepository {
    // All methods automatically on main actor
}
```

### Test Failures

#### "Test timed out"

**Cause:** Async operation never completes

**Fix:**
```swift
// Add timeout and proper async handling
try await Task.sleep(for: .milliseconds(100))
#expect(condition, "Expected state to update")
```

#### "Fake usecase not called"

**Cause:** Not properly configured

**Fix:**
```swift
let fake = FakeTodoUseCase()
fake.todos = [...]  // Configure test data
fake.shouldThrowError = false  // Set behavior
```

---

## Contributing

### Code Style Guidelines

1. **Use SwiftFormat** (if configured):
   ```bash
   swiftformat .
   ```

2. **Follow Swift API Design Guidelines**
   - Clear, concise names
   - Prefer protocols over concrete types
   - Use value types when possible

3. **Documentation**
   - Add doc comments for public APIs
   - Explain non-obvious logic
   - Update ARCHITECTURE.md for major changes

### Pull Request Checklist

Before submitting a PR:

- [ ] Code compiles without warnings
- [ ] All tests pass
- [ ] New features have tests
- [ ] Documentation updated
- [ ] Commit messages follow convention
- [ ] No force-unwrapping (`!`) added
- [ ] `@MainActor` annotations correct
- [ ] SwiftData models CloudKit-compatible

### Review Process

1. **Self-review**: Check your own code first
2. **Automated checks**: CI runs tests
3. **Code review**: Team member reviews
4. **Approval**: At least one approval required
5. **Merge**: Squash and merge to main

---

## Additional Resources

- [ARCHITECTURE.md](../ARCHITECTURE.md) - Detailed architecture
- [API_REFERENCE.md](API_REFERENCE.md) - API documentation
- [ARCHITECTURE_DIAGRAMS.md](ARCHITECTURE_DIAGRAMS.md) - Visual diagrams
- [Swift Documentation](https://docs.swift.org/swift-book/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)

---

**Last Updated:** January 2026
**Swift Version:** 6.2
**Xcode Version:** 26.2+
