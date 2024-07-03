import Foundation
import Additions
import SwiftUI

class OnboardingTask: AsyncOperation {

    override func main() {
        super.main()

        Task { @MainActor in
            guard let task = self.dependencies.first(where: { $0 is WindowSetupTask }) as? WindowSetupTask else {
                return
            }

            task.window?.rootViewController = UIHostingController(rootView: OnboardingScreen())
        }
    }

    func finish() {
        state = .finished
        print("\(self) \(#function) finished")
    }
}
