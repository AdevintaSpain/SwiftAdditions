import XCTest
import Additions
@testable import SwiftAdditions_Example

class StoragePolicyTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        spyCount = 0
    }

    func test_WhenRegisterUniqueInstance_ReturnSameInstance() {
        givenUniqueReaderRegistered()

        let reader: DataSource = CoreServiceLocator.shared.module()
        let anotherReader: DataSource = CoreServiceLocator.shared.module()

        XCTAssert(reader === anotherReader)
    }

    func test_WhenRegisterNewInstance_ReturnDifferentInstance() {
        givenNewReaderRegistered()

        let reader: DataSource = CoreServiceLocator.shared.module()
        let anotherReader: DataSource = CoreServiceLocator.shared.module()

        XCTAssertFalse(reader === anotherReader)
    }

    func test_WhenRegisterUniqueInstance_ReturnSameInjectedInstance() {
        @Inject var reader: DataSource
        @Inject var anotherReader: DataSource

        XCTAssertEqual(spyCount, 0)
        
        givenUniqueReaderRegistered()

        XCTAssertTrue(reader === anotherReader)
        XCTAssertEqual(spyCount, 1)
    }

    func test_WhenRegisterNewInstance_ReturnDifferentInjectedInstance() {
        @Inject var reader: DataSource
        @Inject var anotherReader: DataSource

        XCTAssertEqual(spyCount, 0)

        givenNewReaderRegistered()

        XCTAssertFalse(reader === anotherReader)
        XCTAssertEqual(spyCount, 2)
    }

    var spyCount: Int = 0

    private func givenUniqueReaderRegistered() {
        CoreServiceLocator.shared.add {
            Register(DataSource.self, .unique) {
                self.spyCount += 1
                return StubReader()
            }
        }
    }

    private func givenNewReaderRegistered() {
        CoreServiceLocator.shared.add {
            Register(DataSource.self) {
                self.spyCount += 1
                return StubReader()
            }
        }
    }
}
