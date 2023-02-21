import Foundation
import Additions

class SomeLongRunningTask: AppTask {
    @Inject var dispatch: Dispatching

    override func main() {
        super.main()
        dispatch.dispatchMain(after: 1) {
            print("\(self) finished")
            self.state = .finished
        }
    }
}
