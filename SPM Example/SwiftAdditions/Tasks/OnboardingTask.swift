import Foundation
import Additions
import SwiftUI

class OnboardingTask: AppTask {

    @Inject var dispatch: Dispatching

    override func main() {
        super.main()

        dispatch.dispatchMain {
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
