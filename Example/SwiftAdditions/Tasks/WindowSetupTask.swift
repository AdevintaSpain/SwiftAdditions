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
            let vc = UIHostingController(rootView: LoadingView())
            window.rootViewController = vc
            self.window = window
            window.makeKeyAndVisible()
            setFinished()
            print("\(self) finished")
        } else {
            fatalError()
        }
    }
}

struct LoadingView: View {
    var body: some View {
        Text("Hello, world!")
    }
}
