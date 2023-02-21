import Foundation

public class AdditionsServices: ServiceProvider {
    public init() {}

    public var appTasks = [AppTask]()

    public func modules() -> [Register] {
        [
            Register(Dispatching.self) { Dispatcher() }
        ]
    }
}
