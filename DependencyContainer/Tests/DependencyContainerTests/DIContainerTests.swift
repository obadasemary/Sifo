import Testing
@testable import DependencyContainer

@MainActor
struct DIContainerTests {
    // Test protocol
    protocol TestService {
        func getValue() -> String
    }

    // Test implementation
    final class TestServiceImpl: TestService {
        func getValue() -> String {
            return "test"
        }
    }

    @Test("Register and resolve service succeeds")
    func testRegisterAndResolve() throws {
        let container = DIContainer()
        let service = TestServiceImpl()

        container.register(TestService.self, service)

        let resolved = try container.requireResolve(TestService.self)
        #expect(resolved.getValue() == "test")
    }

    @Test("Resolve unregistered service throws error")
    func testResolveUnregisteredThrows() throws {
        let container = DIContainer()

        do {
            _ = try container.requireResolve(TestService.self)
            Issue.record("Should have thrown DIError.notRegistered")
        } catch let error as DIError {
            if case .notRegistered = error {
                // Expected
            } else {
                Issue.record("Wrong error type")
            }
        }
    }

    @Test("Optional resolve returns nil for unregistered service")
    func testOptionalResolveReturnsNil() {
        let container = DIContainer()

        let resolved = container.resolve(TestService.self)
        #expect(resolved == nil)
    }

    @Test("Optional resolve returns service when registered")
    func testOptionalResolveReturnsService() {
        let container = DIContainer()
        let service = TestServiceImpl()

        container.register(TestService.self, service)

        let resolved = container.resolve(TestService.self)
        #expect(resolved != nil)
        #expect(resolved?.getValue() == "test")
    }
}
