public class WrappedTask<U> {
    public init(block: @escaping @Sendable () async -> Result<U, Error>) {
        self.block = block
    }

    let block: @Sendable () async -> Result<U, Error>

    public func execute() async -> Result<U, Error> {
        if isCancelled {
            return .failure(CancellationError())
        }

        let result = await block()
        isDone = true
        return result
    }

    public var isCancelled = false
    public var isDone = false

    public func cancel() {
        isCancelled = true
    }
}

public class WrappedSequence<U>: AsyncSequence {
    public init(results: [Result<U, Error>] = [Result<U, Error>](), tasks: [WrappedTask<U>] = [WrappedTask<U>]()) {
        self.results = results
        self.tasks = tasks
    }

    public typealias Element = Result<U, any Error>
    private var results = [Result<U, Error>]()
    var tasks = [WrappedTask<U>]()

    public class WrappedIterator: AsyncIteratorProtocol {
        internal init(iterator: IndexingIterator<[WrappedTask<U>]>) {
            self.iterator = iterator
        }

        private var iterator: IndexingIterator<[WrappedTask<U>]>

        public func next() async -> Result<U, Error>? {
            await iterator.next()?.execute()
        }
    }

    public func makeAsyncIterator() -> WrappedIterator {
        WrappedIterator(iterator: tasks.makeIterator())
    }

    @discardableResult
    public func addTask(priority: TaskPriority? = nil, operation: @escaping @Sendable () async -> Result<U, Error>) -> WrappedTask<U> {
        let task = WrappedTask<U>(block: operation)
        tasks.append(task)
        return task
    }

    public func cancelAll() {
        tasks.forEach { $0.cancel() }
    }

    public func getResults() async -> [Result<U, Error>] {
        var results = [Result<U, Error>]()
        for await value in self {
            results.append(value)
        }
        return results
    }
}
