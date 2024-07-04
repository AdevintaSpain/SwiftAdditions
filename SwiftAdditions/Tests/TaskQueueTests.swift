import XCTest
@testable import Additions

final class TaskQueueTests: XCTestCase {

    func testBasicSingleOperation() {
        let queue = TaskQueue<Int>()
        var results = [Int]()
        let exp = expectation(description: #function)
        queue.add(
            task: TestTask(i: 0) {
                results.append($0)
                exp.fulfill()
            }
        )

        wait(for: [exp])
    }

    func testQueueItemsInOrder() async {
        let queue = TaskQueue<Int>()

        let iterations = 20

        var results = [Int]()
        var expected = [Int]()
        var expectations = [XCTestExpectation]()
        for i in 0...iterations {
            let exp = expectation(description: #function+"_i")
            expectations.append(exp)
            queue.add(task: TestTask(i: i) {
                results.append($0)
                exp.fulfill()
            })
            expected.append(i)
        }

        await fulfillment(of: expectations)

        XCTAssertEqual(expected, results)
    }

    func testConcurrentQueueItems() async {
        let operationQueue = OperationQueue()
        let queue = TaskQueue<Int>(queue: operationQueue)

        let iterations = 20
        var results = [Int]()
        var expected = [Int]()
        var expectations = [XCTestExpectation]()
        queue.maxConcurrentOperationCount = 3
        for i in 1...iterations {
            expected.append(i)
            let exp = expectation(description: #function+"_i")
            expectations.append(exp)
            queue.add(task: TestTask(i: i) {
                results.append($0)
                exp.fulfill()
            })
        }

        await fulfillment(of: expectations)

        XCTAssertTrue(expected != results) //items are returned in a different order
        XCTAssertEqual(expected.sorted(), results.sorted()) // specific items are returned
        XCTAssertEqual(expected.count, results.count) // all items are returned
    }

    func testConcurrentQueueItemsWithCancellations() async {
        let queue = TaskQueue<Int>()
        let iterations = (1...20)
        var results = [Int]()
        var expected = [Int]()

        queue.maxConcurrentOperationCount = 3
        var expectations = [XCTestExpectation]()

        for i in iterations {
            if i.isMultiple(of: 2) {
                expected.append(i)
            }
            let exp = expectation(description: #function+"_i")
            expectations.append(exp)

            let task: TestTask = TestTask(i: i) {
                results.append($0)
                exp.fulfill()
            }

            queue.add(task: task)

            if i.isMultiple(of: 2) == false {
                task.cancel()
                exp.fulfill()
            }
        }

        await fulfillment(of: expectations)

        XCTAssertTrue(expected != results) //items are returned in a different order
        XCTAssertEqual(expected.sorted(), results.sorted()) // specific items are returned
        XCTAssertEqual(expected.count, results.count) // all items are returned
        XCTAssertEqual(10, results.count) // all items are returned
    }
}

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
