import Foundation
import UIKit
import UserNotifications

public protocol AppLifecyclePluginable: UIWindowSceneDelegate, UIApplicationDelegate, UNUserNotificationCenterDelegate {}

///
/// An instance of this protocol will provide a combination of sync / async operations that can be queued before the app's first functions start:
///
/// See in the example app, and its output:
/// 
/// ```
/// class ExampleAppServices: ServiceProvider {
///
///     lazy var someLongRunningTask = SomeLongRunningTask()
///     lazy var shortTask = SyncTask()
///     lazy var dependentTask = DependentTask()
///     lazy var permissionTask = PermissionTask()
///     lazy var uiTask = UITask()
///
///     lazy var appTasks: [AsyncOperation] = {
///         dependentTask.addDependency(someLongRunningTask)
///         uiTask.addDependency(permissionTask)
///
///         return [
///             someLongRunningTask,
///             shortTask,
///             dependentTask,
///             permissionTask,
///             uiTask,
///         ]
///     }()
///
///     func modules() -> [Register] {
///         [
///             Register(ReaderProtocol.self, { Reader() })
///         ]
///     }
///
///     var appPlugins: [AppLifecyclePluginable] {
///         [PermissionsPlugin()]
///     }
///
///     func modules() -> [Register] {
///         [
///            Register(DataSource.self) { CharacterDataSource() },
///            Register { self.onboardingTask }
///         ]
///     }
///
/// }
/// ```
///
/// Output:
/// ```
/// <Additions_Example.AsyncTask: 0x600001699b00> finished
/// <Additions_Example.PermissionTask: 0x600001698600> finished
/// <Additions_Example.UITask: 0x7f8c4f9086f0> finished
/// <Additions_Example.SomeLongRunningTask: 0x7f8c4f907d10> finished
/// <Additions_Example.DependentTask: 0x7f8c4f906070> finished
/// all tasks completed
/// <Additions_Example.UITask: 0x7f8c4f9086f0> scene(_:willConnectTo:options:) finished
/// ```
///
public protocol ServiceProvider {
    func modules() -> [Register]
    var appOperations: [AsyncOperation] { get }
    @MainActor var appPlugins: [AppLifecyclePluginable] { get }
}

///
/// Can be tasked with taking care of a controlled startup process.
///
/// Example usage:
/// ```
/// private lazy var serviceProviders: [ServiceProvider] = [
///     ExampleAppServices(),
///     AdditionsServices(),
/// ]
/// ```
///
/// used in first class getting called, usually SceneDelegate (AppDelegate if first is not implemented)
/// ```
/// private lazy var tasks = AppTasks.build(serviceProviders: serviceProviders) {
///     print("all tasks completed")
/// }
/// ```
///
/// subsequent uses in other classes, usually AppDelegate:
/// ```
/// private var tasks: AppTasks? {
///     AppTasks.shared
/// }
/// ```
///
/// interracting with the AppTasks should be done using app lifecycle events (AppDelegate / SceneDelegate):
/// ```
/// func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
///     tasks.forEach {
///         $0.scene?(scene, willConnectTo: session, options: connectionOptions)
///     }
/// }
/// ```
///
/// or
/// ```
/// func applicationDidEnterBackground(_ application: UIApplication) {
///     tasks?.forEach {
///         $0.applicationDidEnterBackground?(application)
///     }
/// }
///
/// ```
public class AppPlugins: @unchecked Sendable {

    public static let shared = AppPlugins()

    @MainActor
    public func build(serviceProviders: [ServiceProvider], finished: @escaping () -> Void) {
        self.serviceProviders = serviceProviders
        CoreServiceLocator.shared.addBuildTasks {
            serviceProviders
        }
        self.allPlugins = serviceProviders.compactMap { $0.appPlugins }.reduce([AppLifecyclePluginable]()) { (result, next) in
            return result + next
        }

        self.allOperations = serviceProviders.compactMap { $0.appOperations }.reduce([AsyncOperation]()) { (result, next) in
            return result + next
        }

        queue.addOperations(allOperations, waitUntilFinished: false)
        queue.addBarrierBlock {
            Task { @MainActor in
                finished()                
                self.isReady = true
            }
        }
    }

    private let queue = OperationQueue()
    private var serviceProviders = [ServiceProvider]()

    private var allOperations: [AsyncOperation] = []
    private var allPlugins: [AppLifecyclePluginable] = []

    @MainActor
    private var isReady: Bool = false {
        didSet {
            guard isReady else { return }

            buffer.forEach { predicate in
                switch predicate {
                case .forPredicate(let body):
                    try? forEach(body)
                case .allSatisfyPredicate(let body):
                    _ = try? allSatisfy(body)
                }
                buffer.removeAll()
            }
        }
    }

    private enum BufferedPredicate {
        case forPredicate((AppLifecyclePluginable) throws -> Void)
        case allSatisfyPredicate((AppLifecyclePluginable) throws -> Bool)
    }

    private var buffer = [BufferedPredicate]()

    @MainActor
    public func forEach(_ body: @escaping (AppLifecyclePluginable) throws -> Void) rethrows {
        guard isReady else {
            buffer.append(.forPredicate(body))
            return
        }

        try allPlugins.forEach(body)
    }

    @discardableResult @MainActor
    public func allSatisfy(_ predicate: @escaping (AppLifecyclePluginable) throws -> Bool) rethrows -> Bool {
        guard isReady else {
            buffer.append(.allSatisfyPredicate(predicate))
            return true
        }
        return try allPlugins.allSatisfy(predicate)
    }

    @MainActor
    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, AppLifecyclePluginable) throws -> Result) rethrows -> Result {
        try allPlugins.reduce(initialResult, nextPartialResult)
    }
}
