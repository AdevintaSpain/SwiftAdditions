import Foundation
import Additions

class SomeLongRunningTask: CancellableTask<Void> {
    
    override func execute() async throws -> Void {
        try await Task.sleep(nanoseconds: 5000)
        setFinished()
    }
}
