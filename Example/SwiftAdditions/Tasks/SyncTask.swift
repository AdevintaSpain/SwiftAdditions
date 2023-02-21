import Foundation
import Additions

class SyncTask: NoOpAppTask {

    override func main() {
        super.main()
        print("\(self) finished")
    }
}
