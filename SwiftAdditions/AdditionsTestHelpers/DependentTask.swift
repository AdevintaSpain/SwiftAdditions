import Foundation
import Additions

class DependentTask: CancellableTask<Void> {

    override func execute() async throws -> Void {
        try await Task.sleep(for: 1)
        setFinished()
    }
}
