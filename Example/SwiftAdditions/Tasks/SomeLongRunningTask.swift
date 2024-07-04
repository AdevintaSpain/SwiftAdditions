import Foundation
import Additions

public class SomeLongRunningTask: CancellableTask<Void> {

    public init(scope: CancellableTask<Void>.ActorScope) {
        super.init(scope: scope)
    }

    public override func execute() async throws -> Void {
        try await Task.sleep(nanoseconds: 5000)
        setFinished()
    }
}
