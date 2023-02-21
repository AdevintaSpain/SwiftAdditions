import Foundation

/// This task represents a long running action that can be queued
///
/// **IMPORTANT!**
///
/// Override `main` to start the operation, then set `state = .finished`
///
///`AppTask` implementations can override `ApplicationLifecycleTask` functions  such as
///  ```
/// func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
/// ```
/// or
/// ```
/// func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions
/// ```
open class AppTask: AsyncOperation, ApplicationLifecycleTask {
    public override init() {
        super.init()
    }

    open override func main() {
        super.main()

        print("started \(self)")
    }

    public func setFinished() {
        state = .finished
        print("finished \(self)")
    }
}
