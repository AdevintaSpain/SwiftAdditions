import Foundation
import Additions

class SomeLongRunningTask: AsyncOperation {
    
    override func main() {
        super.main()
        Task {
            try await Task.sleep(for: 1)
            self.state = .finished
        }
    }
}
