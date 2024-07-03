import Additions
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private lazy var serviceProviders: [ServiceProvider] = [
        ExampleAppServices(),
    ]

    private lazy var plugins: AppPlugins = {
        AppPlugins.shared.build(serviceProviders: serviceProviders) {
            print("all tasks completed")
        }
        return AppPlugins.shared
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        plugins.forEach {
            _ = $0.application?(application, didFinishLaunchingWithOptions: launchOptions)
        }

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        plugins.forEach {
            $0.applicationDidEnterBackground?(application)
        }
    }
}

