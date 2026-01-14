# Sifo Documentation

Welcome to the comprehensive documentation for Sifo, a native iOS todo list application built with Swift 6.2, SwiftUI, and Clean Architecture principles.

## 📚 Documentation Index

### For Users

- **[User Guide](USER_GUIDE.md)** - Complete guide to using Sifo
  - Getting started
  - Managing todos
  - Categories and priorities
  - Filtering and organizing
  - CloudKit sync
  - Troubleshooting

### For Developers

- **[Developer Guide](DEVELOPER_GUIDE.md)** - Development setup and workflow
  - Project setup
  - Development workflow
  - Building new features
  - Testing strategies
  - Debugging techniques
  - Common tasks

- **[Architecture Documentation](../ARCHITECTURE.md)** - Detailed architectural design
  - Clean Architecture layers
  - Dependency management
  - Design patterns
  - State management
  - Common patterns

- **[Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md)** - Visual architecture diagrams
  - System overview
  - Layer dependencies
  - Data flow sequences
  - State machines
  - Navigation flows

- **[API Reference](API_REFERENCE.md)** - Complete API documentation
  - All modules and packages
  - Classes, protocols, and methods
  - Usage examples
  - Error handling
  - Best practices

- **[Package Guide](PACKAGE_GUIDE.md)** - SPM package documentation
  - Package overview
  - Individual package details
  - Creating new packages
  - Package best practices

### Project Information

- **[CLAUDE.md](../CLAUDE.md)** - Instructions for Claude Code
  - Project overview
  - Development environment
  - Architecture constraints
  - Swift and SwiftUI guidelines

---

## 🎯 Quick Start

### I want to...

**Use Sifo:**
→ Start with [User Guide](USER_GUIDE.md)

**Contribute to Sifo:**
→ Read [Developer Guide](DEVELOPER_GUIDE.md) → [Architecture Documentation](../ARCHITECTURE.md)

**Understand the architecture:**
→ Review [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md) → [Architecture Documentation](../ARCHITECTURE.md)

**Look up API details:**
→ Search [API Reference](API_REFERENCE.md)

**Create a new feature:**
→ Follow [Developer Guide § Building New Features](DEVELOPER_GUIDE.md#building-new-features)

**Understand packages:**
→ Read [Package Guide](PACKAGE_GUIDE.md)

---

## 🏗️ Architecture Overview

Sifo follows **Clean Architecture** with strict separation of concerns:

```
┌─────────────────────────────────────────────────┐
│   Presentation Layer (Views & ViewModels)       │
│   TodoListView, TodoDetailView, TabBarView      │
└──────────────────┬──────────────────────────────┘
                   │ depends on
                   ↓
┌─────────────────────────────────────────────────┐
│      Business Logic Layer (Use Cases)           │
│         TodoUseCase, Protocols                  │
└──────────────────┬──────────────────────────────┘
                   │ depends on
                   ↓
┌─────────────────────────────────────────────────┐
│          Data Layer (Repository)                │
│     TodoRepository, SwiftData Models            │
└─────────────────────────────────────────────────┘
```

**Key Principles:**
- Unidirectional dependencies (outer → inner)
- Protocol-oriented design
- Dependency injection via DIContainer
- State machine pattern for ViewModels
- SwiftData with CloudKit sync

---

## 📦 Package Structure

Sifo uses 8 local Swift Package Manager (SPM) packages:

### Infrastructure
- **DependencyContainer** - Dependency injection
- **DevPreview** - Preview support with in-memory data

### Data Layer
- **TodoRepository** - SwiftData persistence

### Business Logic
- **TodoUseCase** - Business logic, models, and adapters

### Presentation
- **TodoListView** - List feature
- **TodoDetailView** - Add/edit feature
- **TodoUI** - Shared UI components
- **TabBarView** - Main navigation

See [Package Guide](PACKAGE_GUIDE.md) for detailed information.

---

## 🔑 Key Concepts

### Clean Architecture

**What is it?**
A software design philosophy that separates concerns into layers with clear dependency rules.

**Why use it?**
- Testability (easy to test each layer)
- Maintainability (changes are localized)
- Flexibility (swap implementations)

**Learn more:**
- [Architecture Documentation](../ARCHITECTURE.md)
- [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md)

### State Machine Pattern

**What is it?**
ViewModels use enum-based states to represent UI state explicitly.

**Example:**
```swift
public enum State: Equatable {
    case idle
    case loading
    case loaded([TodoItemAdapter])
    case error(String)
}
```

**Why use it?**
- Impossible states become impossible
- Clear state transitions
- Easy to test and debug

**Learn more:**
- [Architecture Documentation § State Management](../ARCHITECTURE.md#state-management)
- [Architecture Diagrams § State Management](ARCHITECTURE_DIAGRAMS.md#state-management)

### Builder Pattern

**What is it?**
Factory classes that compose views with their dependencies.

**Example:**
```swift
let builder = TodoListBuilder(container: diContainer)
let view = try builder.buildTodoListView(router: router)
```

**Why use it?**
- Centralized dependency injection
- Testable view creation
- Decouples views from DI container

**Learn more:**
- [Architecture Documentation § Design Patterns](../ARCHITECTURE.md#design-patterns)
- [Developer Guide § Building New Features](DEVELOPER_GUIDE.md#building-new-features)

### Adapter Pattern

**What is it?**
DTOs that transform SwiftData models into view-friendly structures.

**Example:**
```swift
// SwiftData model
@Model class Todo { ... }

// Adapter (DTO)
struct TodoItemAdapter: Sendable {
    let id: PersistentIdentifier
    let title: String
    // ... UI-friendly computed properties
}
```

**Why use it?**
- Decouples views from SwiftData
- Sendable for concurrency safety
- UI-specific computed properties

**Learn more:**
- [Architecture Documentation § Adapter Pattern](../ARCHITECTURE.md#design-patterns)
- [API Reference § Models & DTOs](API_REFERENCE.md#models--dtos)

### Protocol-Oriented Design

**What is it?**
All inter-layer communication happens through protocols.

**Example:**
```swift
// Protocol definition
protocol TodoUseCaseProtocol {
    func fetchTodos(filter: FilterOption) async throws -> [TodoItemAdapter]
}

// Implementation
class TodoUseCase: TodoUseCaseProtocol { ... }

// Usage (depends on protocol, not concrete type)
let useCase: TodoUseCaseProtocol = try container.requireResolve(TodoUseCaseProtocol.self)
```

**Why use it?**
- Testability (easy mocking)
- Flexibility (swap implementations)
- Decoupling (layers don't know concrete types)

**Learn more:**
- [Architecture Documentation § Protocol-Oriented Design](../ARCHITECTURE.md#architectural-principles)
- [API Reference § Protocols](API_REFERENCE.md#protocols)

---

## 🛠️ Technology Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| **Swift** | 6.2 | Programming language with strict concurrency |
| **SwiftUI** | Latest | Modern declarative UI framework |
| **SwiftData** | Latest | Persistence framework with CloudKit sync |
| **Xcode** | 26.2+ | IDE and build tools |
| **iOS** | 26.0+ | Minimum deployment target |
| **Swift Testing** | Built-in | Modern testing framework |
| **SPM** | Built-in | Package management |

---

## 🧪 Testing

Sifo uses a comprehensive testing strategy:

### Unit Tests
- **ViewModels**: Test state transitions and business logic
- **Use Cases**: Test business rules and validation
- **Adapters**: Test data transformations

### Integration Tests
- **Repository**: Test SwiftData operations with in-memory container

### Test Doubles
- **Fake Use Cases**: Simulate business logic
- **Fake Repositories**: Simulate data access
- **Fake Routers**: Simulate navigation

**Run tests:**
```bash
# All tests
xcodebuild test -workspace Sifo.xcworkspace -scheme Sifo \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Package-specific tests
swift test --package-path TodoRepository
```

**Learn more:**
- [Developer Guide § Testing](DEVELOPER_GUIDE.md#testing)
- [Architecture Documentation § Testing Strategy](../ARCHITECTURE.md#testing-strategy)

---

## 📱 Features

### Current Features

✅ **Rich Todo Management**
- Title, notes, due date, priority, categories
- Mark complete/incomplete
- Edit and delete

✅ **Filtering**
- All todos
- Active (incomplete)
- Completed

✅ **Organization**
- Categories with colors
- Priority levels (None, Low, Medium, High)
- Drag-and-drop reordering

✅ **Persistence**
- SwiftData local storage
- CloudKit sync across devices

✅ **Modern iOS Features**
- SwiftUI with @Observable
- Native Tab API
- Pull-to-refresh
- Swipe actions
- Sheet navigation

### Planned Features

🔜 Future updates may include:
- Category management UI
- Search functionality
- Recurring todos
- Subtasks/checklists
- Widgets
- Apple Watch support

---

## 🎨 Design Principles

### Swift 6 Concurrency

- Strict concurrency mode enabled
- All UI operations on `@MainActor`
- SwiftData operations are `@MainActor` isolated
- No legacy GCD (`DispatchQueue`)

### Modern Swift Patterns

- `@Observable` instead of `ObservableObject`
- Native APIs over deprecated ones
- Static member lookup (`.circle` vs `Circle()`)
- Modern Foundation (`URL.documentsDirectory`)

### SwiftUI Best Practices

- Extract views into structs
- Use `@State` for view models
- Custom bindings for form fields
- Avoid force unwrapping
- No hard-coded values

**Learn more:**
- [CLAUDE.md § Swift & SwiftUI Guidelines](../CLAUDE.md#swift--swiftui-guidelines)

---

## 📖 Learning Path

### Beginner

1. **Understand the basics:**
   - Read [User Guide](USER_GUIDE.md)
   - Explore the app

2. **Learn the architecture:**
   - Review [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md)
   - Understand layer separation

3. **Set up development:**
   - Follow [Developer Guide § Project Setup](DEVELOPER_GUIDE.md#project-setup)

### Intermediate

1. **Understand packages:**
   - Read [Package Guide](PACKAGE_GUIDE.md)
   - Explore package dependencies

2. **Study design patterns:**
   - Review [Architecture Documentation § Design Patterns](../ARCHITECTURE.md#design-patterns)
   - Understand state machines, builders, adapters

3. **Write tests:**
   - Follow [Developer Guide § Testing](DEVELOPER_GUIDE.md#testing)
   - Create fake implementations

### Advanced

1. **Build new features:**
   - Follow [Developer Guide § Building New Features](DEVELOPER_GUIDE.md#building-new-features)
   - Add new packages

2. **Optimize performance:**
   - Study [Developer Guide § Performance Optimization](DEVELOPER_GUIDE.md#performance-optimization)
   - Profile with Instruments

3. **Contribute:**
   - Review [Developer Guide § Contributing](DEVELOPER_GUIDE.md#contributing)
   - Submit pull requests

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Read the documentation:**
   - [Developer Guide](DEVELOPER_GUIDE.md)
   - [Architecture Documentation](../ARCHITECTURE.md)
   - [CLAUDE.md](../CLAUDE.md)

2. **Set up your environment:**
   - Clone repository
   - Open `Sifo.xcworkspace`
   - Run tests

3. **Make changes:**
   - Follow coding conventions
   - Add tests for new features
   - Update documentation

4. **Submit pull request:**
   - Follow commit message conventions
   - Ensure all tests pass
   - Update CHANGELOG (if applicable)

**Learn more:**
- [Developer Guide § Contributing](DEVELOPER_GUIDE.md#contributing)

---

## 🐛 Troubleshooting

### Build Issues

**"No such module 'TodoUseCase'"**
→ See [Developer Guide § Troubleshooting](DEVELOPER_GUIDE.md#troubleshooting)

**Circular dependency errors**
→ See [Package Guide § Troubleshooting](PACKAGE_GUIDE.md#troubleshooting-packages)

### Runtime Issues

**State not updating UI**
→ Check `@Observable` and `@MainActor` annotations

**SwiftData crashes**
→ Ensure all operations on `@MainActor`

**Dependency not found**
→ Check `AppComposition.swift` registration

### User Issues

**Todo doesn't appear after saving**
→ See [User Guide § Troubleshooting](USER_GUIDE.md#troubleshooting)

**CloudKit not syncing**
→ Check iCloud settings and internet connection

---

## 📞 Support

### Documentation

All questions should be answerable by the documentation:
- [User Guide](USER_GUIDE.md) - For users
- [Developer Guide](DEVELOPER_GUIDE.md) - For developers
- [API Reference](API_REFERENCE.md) - For API details

### Issues

Report bugs or request features:
- Check existing issues on GitHub
- Create new issue with details
- Include steps to reproduce

### Community

- Discussions on GitHub
- Code reviews on pull requests

---

## 📄 License

See [LICENSE](../LICENSE) file for details.

---

## 🙏 Acknowledgments

Built with:
- Swift 6.2
- SwiftUI
- SwiftData
- CloudKit
- Modern iOS best practices

Inspired by Clean Architecture principles and protocol-oriented design.

---

## 📚 Additional Resources

### Apple Documentation

- [Swift Documentation](https://docs.swift.org/swift-book/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)

### Articles & Guides

- Clean Architecture by Robert C. Martin
- Protocol-Oriented Programming in Swift
- Swift Concurrency Manifesto

---

## 📋 Documentation Checklist

When updating documentation:

- [ ] User-facing changes → Update [User Guide](USER_GUIDE.md)
- [ ] Architecture changes → Update [Architecture Documentation](../ARCHITECTURE.md)
- [ ] New APIs → Update [API Reference](API_REFERENCE.md)
- [ ] New packages → Update [Package Guide](PACKAGE_GUIDE.md)
- [ ] Development workflow changes → Update [Developer Guide](DEVELOPER_GUIDE.md)
- [ ] Visual diagrams needed → Update [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md)
- [ ] Project guidelines → Update [CLAUDE.md](../CLAUDE.md)

---

**Last Updated:** January 2026
**Documentation Version:** 1.0
**Project:** Sifo iOS Application

---

## 🗺️ Documentation Map

```
docs/
├── README.md                      ← You are here
├── USER_GUIDE.md                  User documentation
├── DEVELOPER_GUIDE.md             Developer onboarding and workflow
├── API_REFERENCE.md               Complete API documentation
├── ARCHITECTURE_DIAGRAMS.md       Visual architecture diagrams
└── PACKAGE_GUIDE.md               SPM package documentation

../
├── ARCHITECTURE.md                Detailed architecture documentation
└── CLAUDE.md                      Claude Code instructions
```

Happy coding! 🚀
