import Foundation
import Additions

class SomeLongRunningTask: AsyncOperation {

    override func main() {
        super.main()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.state = .finished
            print("\(self) finished")
        }
    }
}
