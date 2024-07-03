import XCTest
import Additions
@testable import AdditionsTestHelpers

final class AppPluginsTest: XCTestCase {

    let plugins = AppPlugins.shared

    @Inject private var foo: Foo
    @Inject private var bar: Bar

    @MainActor
    func testStartupFinishedAfterServiceFinishesOperations() throws {
        let exp = expectation(description: #function)
        plugins.build(serviceProviders: [TestServiceProvider()]) {
            exp.fulfill()
        }

        wait(for: [exp])
    }

    @MainActor
    func testDependencyInjection1() throws {
        let exp = expectation(description: #function)
        plugins.build(serviceProviders: [TestServiceProvider()]) {
            exp.fulfill()
        }

        wait(for: [exp])

        let bar = BarClass()
        CoreServiceLocator.shared.add {
            Register(Bar.self) { bar }
            Register(BarClass.self) { bar }
        }

        bar.stubReturn = true

        XCTAssertTrue(foo.someFoo())
    }

    func testDependencyInjection2() throws {
        let bar = BarClass()
        CoreServiceLocator.shared.add {
            Register(Bar.self) { bar }
            Register(BarClass.self) { bar }
        }
        bar.stubReturn = true
        bar.stubError = CancellationError()

        XCTAssertFalse(foo.someFoo())
    }

}

protocol Foo {
    func someFoo() -> Bool
}

protocol Bar {
    func boolFunction() throws -> Bool
}

class FooClass: Foo {
    @Inject private var bar: Bar
    
    func someFoo() -> Bool {
        do {
            return try bar.boolFunction()
        } catch {
            return false
        }
    }
}

class BarClass: Bar {
    var stubReturn = false
    var stubError: Error?
    func boolFunction() throws -> Bool {
        if let stubError {
            throw stubError
        }
        return stubReturn
    }
}

class TestServiceProvider: ServiceProvider {
    lazy var someLongRunningTask = SomeLongRunningTask(scope: .default)
    lazy var shortTask = SyncTask()
    lazy var dependentTask = DependentTask(scope: .default)

    lazy var appTasks: [AsyncOperation] = {

        dependentTask.addDependency(someLongRunningTask)

        return [
            someLongRunningTask,
            shortTask,
            dependentTask,
        ]
    }()

    var appPlugins: [AppLifecyclePluginable] {
        []
    }

    func modules() -> [Register] {
        [
            Register(Foo.self) { FooClass() }
        ]
    }
}
