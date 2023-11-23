import Foundation
import Additions
import SwiftUI

class WindowSetupTask: CancellableTask<Void> {

    var window: UIWindow?

    override func executeMain() async throws -> Void {
        //launch a loading screen here
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }),
           let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let vc = UIStoryboard(name: "LaunchScreen", bundle: .main).instantiateInitialViewController()

            window.rootViewController = vc
            self.window = window
            window.makeKeyAndVisible()
            self.state = .finished
            print("\(self) finished")
        }
    }
}
