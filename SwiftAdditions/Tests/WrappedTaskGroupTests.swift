import XCTest
import Additions

final class WrappedTaskGroupTests: XCTestCase {

    var random: Double {
        Double.random(in: 0.000001...0.00001)
    }

    func testConcurrentQueueItems() async throws {

        let iterations = 10000
        var expected = [Int]()
        var expectations = [XCTestExpectation]()
        let results = try await WrappedTaskGroup.run { queue in
            for i in 1...iterations {
                let exp = expectation(description: #function+"_i")
                expectations.append(exp)
                queue.addTask {
                    let result = try await self.executeBlock(value: i)
                    exp.fulfill()
                    return result
                }
                expected.append(i)
            }
        }

        await fulfillment(of: expectations)

        XCTAssertEqual(results.count, expected.count) // all items are returned
        XCTAssertNotEqual(results, expected) //items are returned in a different order
        XCTAssertEqual(results.sorted(), expected.sorted()) // specific items are returned
    }

    func executeBlock(value: Int) async throws -> Int {
        try await Task.sleep(for: self.random)
        return value
    }
}
