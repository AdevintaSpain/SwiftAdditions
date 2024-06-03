import Foundation
//based on https://github.com/ZamzamInc/Shank

public protocol ServiceLocator {
    var root: CoreServiceLocator { get }
    func services() -> [Register]
}

public extension ServiceLocator {
    var root: CoreServiceLocator {
        CoreServiceLocator.shared
    }

    func services() -> [Register] {
        []
    }
}

///
/// A dependency collection that provides resolutions for object instances.
///
/// Can be used directly:
/// use
/// ```
/// func add(@Factory _ modules: () -> [Register])
/// ```
///
///  **IMPORTANT**
///  Best used through `AppTasks`.
///
///  See documentation to on how to add `ServiceProvider` instances (which provide their own set of tasks and registries `[Register]`).
///

public class CoreServiceLocator {
    /// Stored object instance factories.
    private var services = [String: Register]()

    /// Stored unique object instances.
    private var uniqueInstances = [String: Any]()

    fileprivate init() {}
    deinit { services.removeAll() }
}

extension CoreServiceLocator {
    /// Composition root container of dependencies.
    public static let shared = CoreServiceLocator()

    /// Registers a specific type and its instantiating factory.
    public func add(@Factory _ module: () -> Register) {
        let module = module()
        services[module.name] = module
    }

    /// Register factories
    /// - Parameter modules: The factories added
    public func add(@Factory _ modules: () -> [Register]) {
        modules().forEach {
            services[$0.name] = $0
        }
    }

    /// Register factories through the `ServiceProvider` array. Each has a set of `Register` arrays. Note that they can be overriden if two `ServiceProvider` instances carry the same type of `Register`. The last one stays.
    /// - Parameter buildTasks: The ServiceProvider added
    public func addBuildTasks(_ buildTasks: () -> [ServiceProvider]) {
        buildTasks().forEach { (task) in
            task.modules().forEach {
                services[$0.name] = $0
            }
        }
    }

    public func removeAll() {
        services.removeAll()
        uniqueInstances.removeAll()
    }

    /// Resolves through inference and returns an instance of the given type from the current default container. 
    /// **Important**
    /// - Although `public` for legacy purposes, try to avoid using this, instead use `Inject`
    /// - If the dependency is not found, an exception will occur.
    ///
    public func module<T>(for type: T.Type = T.self) -> T {
        let name = String(describing: T.self)
        guard let service = services[name] else {
            fatalError("Dependency '\(T.self)' not resolved!")
        }

        switch service.storagePolicy {
        case .unique:
            if let uniqueInstance = uniqueInstances[name] as? T {
                return uniqueInstance
            } else {
                let instance = service.resolve()
                uniqueInstances[name] = instance
                return instance as! T
            }
        case .new:
            return service.resolve() as! T
        }
    }
}

// MARK: Public API
public extension CoreServiceLocator {
    @resultBuilder struct Factory {
        public static func buildBlock(_ modules: Register...) -> [Register] { modules }
        public static func buildBlock(_ module: Register) -> Register { module }
    }
}

// TODO: update documentation
// Register(Foo.self, .unique) { FooImp() }
public enum StoragePolicy {
    case unique
    case new
}

///
/// A type that contributes to the object graph.
///
/// If you use protocols:
/// ```
/// CoreServiceLocator.shared.add {
///     Register(SomeProtocol.self) { SomeImplementation() } // can be fetched using @Inject var foo: SomeProtocol
/// }
/// ```
/// Otherwise type is inferred from `T.self`:
/// CoreServiceLocator.shared.add {
///     Register { SomeImplementation() } // can be fetched using @Inject var foo: SomeImplementation
/// }
///
///---
/// **IMPORTANT!**ServiceProvider
/// - Best to use through `ServiceProvider`. (avoids using `CoreServiceLocator.shared`) See `ServiceProvider` documentation for more info.
/// - see `PrinterTests` how to replace protocol implementations with mocks.
///

public struct Register {
    fileprivate let name: String
    fileprivate let storagePolicy: StoragePolicy
    fileprivate let resolve: () -> Any

    public init<T>(_ type: T.Type = T.self, _ storagePolicy: StoragePolicy = .new, _ resolve: @escaping () -> T) {
        self.name = String(describing: T.self)
        self.storagePolicy = storagePolicy
        self.resolve = resolve
    }
}

///
/// Resolves an instance from the dependency injection container.
///
/// Can fetch based on protocol names also:
///
/// ```
/// @Inject var foo: SomeProtocol
/// ```
///
@propertyWrapper
public class Inject<Value>: ObservableObject {
    private let name: String?
    private var storage: Value?

    public var wrappedValue: Value {
        storage ?? {
            let value: Value = CoreServiceLocator.shared.module(for: Value.self)
            storage = value // Reuse instance for later
            return value
        }()
    }

    public init() {
        self.name = nil
    }

    public init(_ type: Value.Type = Value.self) {
        self.name = String(describing: Value.self)
    }
}
