import Foundation
import Additions
import SwiftUI

class MainUISetupTask: AsyncOperation {

    override func main() {
        super.main()

        Task { @MainActor in
            guard let task = self.dependencies.first(where: { $0 is WindowSetupTask }) as? WindowSetupTask else {
                return
            }

            let contentView = PrinterView()
            task.window?.rootViewController = UIHostingController(rootView: contentView)
            self.state = .finished
            print("\(self) \(#function) finished")
        }
    }
}
