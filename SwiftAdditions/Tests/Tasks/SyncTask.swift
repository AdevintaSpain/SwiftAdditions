import Foundation
import Additions

public class SyncTask: AsyncOperation {

    public override init() {
        super.init()
    }

    public override func main() {
        super.main()
        print("\(self) finished")
        setFinished()
    }
}
