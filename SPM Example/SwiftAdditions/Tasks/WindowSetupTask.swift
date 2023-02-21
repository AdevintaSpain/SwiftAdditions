import Foundation
import Additions
import SwiftUI

class WindowSetupTask: AppTask {

    var window: UIWindow?
    @Inject var dispatch: Dispatching

    override func main() {
        super.main()

        dispatch.dispatchMain {
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

}
