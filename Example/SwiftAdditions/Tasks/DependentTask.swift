import Foundation
import Additions

public class DependentTask: CancellableTask<Void> {

    public init(scope: CancellableTask<Void>.ActorScope) {
        super.init(scope: scope)
    }

    public override func execute() async throws -> Void {
        try await Task.sleep(nanoseconds: 500)
        setFinished()
    }
}
