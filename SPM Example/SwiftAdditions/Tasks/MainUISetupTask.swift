import Foundation
import Additions
import SwiftUI

class MainUISetupTask: CancellableTask<Void> {

    override func executeMain() async throws -> Void {
        guard let task = self.dependencies.first(where: { $0 is WindowSetupTask }) as? WindowSetupTask else {
            return
        }

        let contentView = PrinterView()
        task.window?.rootViewController = UIHostingController(rootView: contentView)
        self.state = .finished
        print("\(self) \(#function) finished")
    }
}
