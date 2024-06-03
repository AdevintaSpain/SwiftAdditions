import XCTest
@testable import Additions

final class TestTask: CancellableTask<Int> {
    init(i: Int, completion: @escaping (Int) -> Void) {
        self.i = i
        self.completion = completion
        super.init(priority: .userInitiated, scope: .default)
    }

    let i: Int
    let completion: (Int) -> Void
    override func execute() async throws -> Int {
        if isCancelled {
            throw CancellationError()
        }

        try? await Task.sleep(for: Double.random(in: 0.01...0.1))
        if isCancelled {
            throw CancellationError()
        }

        completion(i)
        return i
    }
}

final class TaskQueueTests: XCTestCase {
    func testQueueItemsInOrder() async {
        let queue = TaskQueue<Int>()

        let iterations = 20

        var results = [Int]()
        var expected = [Int]()
        for i in 0...iterations {
            queue.add(task: TestTask(i: i) { results.append($0) })
            expected.append(i)
        }

        while results.count < expected.count {
            try? await Task.sleep(nanoseconds: 1_000)
        }

        XCTAssertEqual(expected, results)
    }

    func testConcurrentQueueItems() async {
        let operationQueue = OperationQueue()
        let queue = TaskQueue<Int>(queue: operationQueue)

        let iterations = 100
        var results = [Int]()
        var expected = [Int]()
        queue.maxConcurrentOperationCount = 10
        for i in 1...iterations {
            expected.append(i)
            queue.add(task: TestTask(i: i) {
                results.append($0)
            })
        }

        while results.count < expected.count {
            try? await Task.sleep(nanoseconds: 1_000)
        }

        XCTAssertTrue(expected != results) //items are returned in a different order
        XCTAssertEqual(expected.sorted(), results.sorted()) // specific items are returned
        XCTAssertEqual(expected.count, results.count) // all items are returned
    }

    func testConcurrentQueueItemsWithCancellations() async {
        let queue = TaskQueue<Int>()
        let iterations = (1...100)
        var results = [Int]()
        var expected = [Int]()

        queue.maxConcurrentOperationCount = 10

        for i in iterations {
            if i.isMultiple(of: 2) {
                expected.append(i)
            }
            let task: TestTask = TestTask(i: i) {
                results.append($0)
            }
            queue.add(task: task)

            if i.isMultiple(of: 2) == false {
                task.cancel()
            }
        }

        while results.count < expected.count {
            try? await Task.sleep(nanoseconds: 1_000)
        }

        XCTAssertTrue(expected != results) //items are returned in a different order
        XCTAssertEqual(expected.sorted(), results.sorted()) // specific items are returned
        XCTAssertEqual(expected.count, results.count) // all items are returned
        XCTAssertEqual(50, results.count) // all items are returned
    }
}
