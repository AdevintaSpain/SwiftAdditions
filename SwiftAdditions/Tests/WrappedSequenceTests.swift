import XCTest
@testable import Additions
import Foundation

final class WrappedSequenceTests: XCTestCase {
    
    var random: Double {
        Double.random(in: 0.000001...0.00001)
    }

    func testSequencePerformance() async throws {

        let iterations = 10000
        var expected = [Int]()

        let sequeunce = WrappedSequence<Int>()

        for i in 0...iterations {
            sequeunce.addTask {
                await self.executeBlock(value: i)
            }
            expected.append(i)
        }

        let results = await sequeunce.getResults().compactMap { try? $0.get() }
        XCTAssertEqual(results, expected)
    }

    func testSequenceCancelations() async throws {
        let iterations = 1000
        var expected = [Int]()
        let sequeunce = WrappedSequence<Int>()

        for i in 0...iterations {
            if i.isMultiple(of: 2) {
                expected.append(i)
            }
            let task = sequeunce.addTask {
                await self.executeBlock(value: i)
            }

            if i.isMultiple(of: 2) == false {
                task.cancel()
            }
        }

        let results = await sequeunce.getResults().compactMap { try? $0.get() }
        XCTAssertEqual(results, expected)
    }

    func testSequenceCancelsFirstElementButReceivesSecond() async throws {

        let sequeunce = WrappedSequence<Int>()

        let task1 = sequeunce.addTask {
            await self.executeBlock(value: 1, delay: 0.2)
        }

        sequeunce.addTask {
            await self.executeBlock(value: 2, delay: 0.2)
        }

        task1.cancel()

        let results = await sequeunce.getResults().compactMap { try? $0.get() }

        XCTAssertEqual(results, [2])
    }

    func testSequenceCanReceiveEventsInVariousMoments() async throws {

        let sequeunce = WrappedSequence<Int>()

        let task1 = sequeunce.addTask {
            await self.executeBlock(value: 1, delay: 0.2)
        }

        sequeunce.addTask {
            await self.executeBlock(value: 2, delay: 0.2)
        }

        task1.cancel()

        var results = await sequeunce.getValues()
        sequeunce.removeDone()

        sequeunce.addTask {
            await self.executeBlock(value: 3, delay: 0.2)
        }

        let task4 = sequeunce.addTask {
            await self.executeBlock(value: 4, delay: 0.2)
        }

        task4.cancel()

        let next = await sequeunce.getValues()
        results.append(contentsOf: next)

        XCTAssertEqual(results, [2, 3])
    }

    func executeBlock(value: Int, delay: Double? = nil) async -> Result<Int, Error> {
        if Task.isCancelled {
            return .failure(CancellationError())
        }

        try? await Task.sleep(for: delay ?? self.random)
        if Task.isCancelled {
            return .failure(CancellationError())
        }

        return .success(value)
    }
}

//MARK: - Test helpers.
private extension WrappedSequence {
    func removeDone() {
        tasks.removeAll { $0.isDone }
    }

    func getValues() async -> [U] {
        await getResults().compactMap { try? $0.get() }
    }
}
