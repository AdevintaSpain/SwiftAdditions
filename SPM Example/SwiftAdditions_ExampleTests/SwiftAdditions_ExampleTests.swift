import Combine
import XCTest
import Additions
@testable import SwiftAdditions_Example

class Tests: XCTestCase {

    var cancellables = [AnyCancellable]()
    var mockReader: MockReader!

    override func setUp() {
        super.setUp()
        mockReader = MockReader()

        CoreServiceLocator.shared.add {
            Register(ReaderProtocol.self) { self.mockReader }
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

        CoreServiceLocator.shared.removeAll()

        mockReader = nil
    }

    func testFoo() {
        mockReader.mockValue = "b"
        let presenter = PrinterPresenter()
        var capturedValue: String!
        let exp = expectation(description: "foo")
        presenter.$text.sink {
            capturedValue = $0
            exp.fulfill()
        }.store(in: &cancellables)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(capturedValue, "b")
    }

}

class MockReader: ReaderProtocol {
    var mockValue: Character!
    func start(update: @escaping (Character) -> Void) {
        update(mockValue)
    }
}
