import XCTest
import Additions
@testable import SwiftAdditions_Example

class PrinterTests: XCTestCase {

    @Inject private var dataSource: DataSource

    override func setUp() {
        super.setUp()

        CoreServiceLocator.shared.add {
            Register(DataSource.self) { StubReader() }
        }
    }

    override func tearDownWithError() throws {
        CoreServiceLocator.shared.removeAll()
    }

    @MainActor
    func testPrinterReceivesReaderInputAndPublishesToOutput() {
        let char = dataSource.next()
        XCTAssertNotNil(char)
    }
}


class StubReader: DataSource {
    var stubNext = "a"
    func next() -> Character? {
        stubNext.popLast()
    }
}
