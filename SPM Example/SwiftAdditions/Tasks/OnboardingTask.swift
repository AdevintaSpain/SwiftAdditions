import Foundation
import Additions
import SwiftUI

class OnboardingTask: CancellableTask<Void> {

    @MainActor
    override func executeMain() async throws -> Void {
        guard let task = self.dependencies.first(where: { $0 is WindowSetupTask }) as? WindowSetupTask else {
            finish()
            return
        }

        task.window?.rootViewController = UIHostingController(rootView: OnboardingScreen())
    }

    func finish() {
        state = .finished
        print("\(self) \(#function) finished")
    }
}
