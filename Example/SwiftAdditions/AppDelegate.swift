import Additions
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private lazy var serviceProviders: [ServiceProvider] = [
        ExampleAppServices(),
        AdditionsServices(),
    ]

    private lazy var tasks = AppTasks.build(serviceProviders: serviceProviders) {
        print("all tasks completed")
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        tasks.forEach {
            _ = $0.application?(application, didFinishLaunchingWithOptions: launchOptions)
        }

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        tasks.forEach {
            $0.applicationDidEnterBackground?(application)
        }
    }
}

