import UIKit
import Additions
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        AppPlugins.shared.forEach {
            _ = $0.application?(application, didFinishLaunchingWithOptions: launchOptions)
        }

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        AppPlugins.shared.forEach {
            $0.applicationDidEnterBackground?(application)
        }
    }
}

