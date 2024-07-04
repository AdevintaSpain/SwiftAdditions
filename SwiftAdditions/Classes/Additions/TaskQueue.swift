import Foundation

extension Task where Success == Never, Failure == Never {
    public static func sleep(for seconds: Double) async throws {
        try await sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}

public class TaskQueue<U> {
    public init(queue: OperationQueue = .init()) {
        self.queue = queue
        queue.maxConcurrentOperationCount = 1
    }

    let queue: OperationQueue

    public var maxConcurrentOperationCount: Int {
        get {
            queue.maxConcurrentOperationCount
        }
        set {
            queue.maxConcurrentOperationCount = newValue
        }
    }

    public func cancelAllOperations() {
        queue.cancelAllOperations()        
    }

    public func add(priority: TaskPriority? = nil, task: AsyncOperation) {
        queue.addOperation(task)
    }

    public func addBarrier(_ barrier: @escaping () -> Void) {
        queue.addBarrierBlock(barrier)
    }

    public func schedule(delay: TimeInterval, task: AsyncOperation) {
        queue.schedule(after: OperationQueue.SchedulerTimeType(Date() + delay)) {
            self.queue.addOperation(task)
        }
    }
}

open class CancellableTask<U>: AsyncOperation {
    public enum ActorScope {
        case main
        case `default`
    }

    private let priority: TaskPriority?
    var result: U?
    var task: Task<Void, Error>?
    var scope: ActorScope

    open override func main() {
        super.main()
        switch scope {
        case .default:
            self.task = Task(priority: priority) {
                do {
                    self.result = try await execute()
                    setFinished()
                } catch {
                    setFinished()
                }
            }
        case .main:
            self.task = Task(priority: priority) { @MainActor in
                do {
                    self.result = try await executeMain()
                    setFinished()
                } catch {
                    setFinished()
                }
            }
        }
    }
    
    open func execute() async throws -> U {
        fatalError("not implemented")
    }

    @MainActor
    open func executeMain() async throws -> U {
        fatalError("not implemented")
    }

    public init(priority: TaskPriority? = nil, scope: ActorScope) {
        self.priority = priority
        self.scope = scope
        super.init()
    }

    open override func cancel() {
        super.cancel()
        task?.cancel()
    }
}
