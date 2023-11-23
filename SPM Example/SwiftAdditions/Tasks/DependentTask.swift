import Foundation
import Additions

class DependentTask: AsyncOperation {
    
    override func main() {
        super.main()
        Task {
            try await Task.sleep(for: 1)
            print("\(self) finished")
            self.state = .finished
        }
    }
}
