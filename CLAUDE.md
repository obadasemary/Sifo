# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Sifo** is a native iOS application built with Swift 6.2 and SwiftUI, targeting iOS 26.0+. The project follows Clean Architecture principles with strict concurrency enforcement.

## Development Environment

- **Xcode**: 26.2 or later
- **Swift**: 6.2 with strict concurrency enabled
- **Minimum iOS**: 26.0
- **UI Framework**: SwiftUI with `@Observable` macro
- **Persistence**: SwiftData with CloudKit sync
- **Testing**: Swift Testing framework (not XCTest)
- **Project File**: `Sifo.xcworkspace` (uses SPM packages)

## Build Commands

```bash
# Build the app
xcodebuild -workspace Sifo.xcworkspace -scheme Sifo -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild test -workspace Sifo.xcworkspace -scheme Sifo -destination 'platform=iOS Simulator,name=iPhone 16'

# Run specific package tests
swift test --package-path DependencyContainer
swift test --package-path TodoRepository
swift test --package-path TodoUseCase

# Clean build folder
xcodebuild clean -workspace Sifo.xcworkspace -scheme Sifo
```

## Implemented Features

### Todo List (Full Clean Architecture)

A complete todo management application with:

- **Rich Todo Model**: Title, notes, due date, priority (none/low/medium/high), categories
- **Features**: Add, edit, delete, filter (all/active/completed), drag-and-drop reorder
- **Persistence**: SwiftData with CloudKit sync enabled
- **Clean Architecture**: 11 SPM packages organized by layer

#### Package Structure

```text
Sifo.xcworkspace
├── DependencyContainer (Infrastructure)
│   └── DIContainer with @MainActor + @Observable
├── TodoRepository (Data Layer)
│   ├── SwiftData models (Todo, Category, TodoPriority)
│   └── Repository with CRUD, filtering, reordering
├── TodoUseCase (Business Logic Layer)
│   ├── TodoUseCase with validation
│   ├── Adapters (TodoItemAdapter, CategoryAdapter)
│   └── Domain models (FilterOption, TodoError)
├── TodoListView (Presentation - List)
│   ├── TodoListViewModel (state machine)
│   ├── TodoListView with filter, swipe, reorder
│   └── TodoListBuilder + Router
├── TodoDetailView (Presentation - Add/Edit)
│   ├── TodoDetailViewModel (form state)
│   ├── TodoDetailView with validation
│   └── TodoDetailBuilder
├── TodoUI (Shared Components)
│   ├── TodoRowView, ErrorView, EmptyStateView
│   └── CategoryTagView, PriorityBadgeView
├── TabBarView (Navigation)
│   └── Main tab coordinator with sheet navigation
└── DevPreview (Preview Support)
    └── In-memory SwiftData with seed data
```

#### Key Files

- [SifoApp.swift](Sifo/SifoApp.swift): ModelContainer + DI setup
- [AppComposition.swift](Sifo/AppComposition.swift): Dependency registration
- [Todo.swift](TodoRepository/Sources/TodoRepository/Models/Todo.swift): CloudKit-compatible SwiftData model
- [TodoUseCase.swift](TodoUseCase/Sources/TodoUseCase/TodoUseCase.swift): Business logic with validation
- [TodoListViewModel.swift](TodoListView/Sources/TodoListView/TodoListViewModel.swift): State machine (idle/loading/loaded/error/deleting)
- [DevPreview.swift](DevPreview/Sources/DevPreview/DevPreview.swift): Preview environment with sample data

## Architecture

The codebase is designed to follow **Clean Architecture** principles. See [ARCHITECTURE.md](ARCHITECTURE.md) for the complete architectural vision, which includes:

- **Layer Structure**: Presentation → Business Logic → Data
- **Protocol-Oriented Design**: All inter-layer communication through protocols
- **Dependency Injection**: Via `DIContainer` registered in `AppComposition.swift`
- **Builder Pattern**: Features composed via builder classes (mandatory)
- **State Machine Pattern**: ViewModels use enum-based state machines
- **Modular Design**: Features as independent Swift Package Manager (SPM) packages

### Key Architectural Constraints

1. **Always use workspace when SPM packages are added**: Once local packages are integrated, open `*.xcworkspace`, never the `.xcodeproj`
2. **@MainActor is critical**: Most UI-related classes must be `@MainActor` for Swift 6 strict concurrency
3. **No force unwrapping**: Use safe unwrapping (`if let`, `guard let`) and `requireResolve()` for DI
4. **Protocol-first development**: Define protocols for cross-module dependencies
5. **Builder pattern is mandatory**: Never instantiate feature views directly

## Swift & SwiftUI Guidelines

### Swift Concurrency

- Always mark `@Observable` classes with `@MainActor`
- Strict concurrency rules are enforced (Swift 6.2)
- Never use old-style GCD (`DispatchQueue.main.async`); use modern Swift concurrency
- Use `Task.sleep(for:)` instead of `Task.sleep(nanoseconds:)`
- Avoid force `try` unless unrecoverable

### Modern Swift Patterns

- Prefer Swift-native APIs: `replacing(_:with:)` over `replacingOccurrences(of:with:)`
- Use modern Foundation: `URL.documentsDirectory`, `appending(path:)`
- Use `Text(value, format:)` for number formatting, never C-style `String(format:)`
- Prefer static member lookup: `.circle` over `Circle()`, `.borderedProminent` over `BorderedProminentButtonStyle()`
- Filter text with `localizedStandardContains()` not `contains()`

### SwiftUI Best Practices

- Use `foregroundStyle()` instead of `foregroundColor()`
- Use `clipShape(.rect(cornerRadius:))` instead of `cornerRadius()`
- Use `Tab` API instead of `tabItem()`
- Never use `ObservableObject`; always use `@Observable` classes
- Use `onChange()` with two parameters or none, never the 1-parameter variant
- Use `Button` instead of `onTapGesture()` unless tap location/count is needed
- Never use `UIScreen.main.bounds` for size
- Extract views into new `View` structs, not computed properties
- Use Dynamic Type instead of forcing font sizes
- Use `navigationDestination(for:)` with `NavigationStack` (not `NavigationView`)
- Always specify text for image buttons: `Button("Tap me", systemImage: "plus", action:)`
- Use `ImageRenderer` for SwiftUI view rendering (not `UIGraphicsImageRenderer`)
- Use `bold()` instead of `fontWeight(.bold)`
- Avoid `GeometryReader`; prefer `containerRelativeFrame()` or `visualEffect()`
- Don't convert to array for enumerated ForEach: `ForEach(x.enumerated(), id: \.element.id)`
- Use `.scrollIndicators(.hidden)` instead of `showsIndicators: false`
- Place view logic in view models for testability
- Avoid `AnyView` unless required
- Avoid hard-coded padding/spacing values

### Project Structure

- Folder layout determined by app features
- One type per Swift file (separate structs, classes, enums)
- Write unit tests for core logic (use Swift Testing framework)
- Add documentation comments as needed
- Never commit secrets (API keys) to repository

## Testing with Swift Testing

```swift
import Testing
@testable import Sifo

struct MyTests {
    @Test func exampleTest() async throws {
        #expect(value == expectedValue)
    }
}
```

## Skills

This project includes the `swift-concurrency` skill for expert guidance on async/await, actors, and concurrency patterns. The skill provides reference material on:
- Threading and actor isolation
- Core Data integration
- Async/await basics
- Migration strategies
- Performance optimization
- Memory management

## Important Notes

- Target **iOS 26.0 or later** (not 17.0)
- Avoid third-party frameworks without asking first
- Avoid UIKit unless requested
- If SwiftLint is installed, ensure it passes before committing
