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
///     lazy var appTasks: [AppTask] = {
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
    var appTasks: [AsyncOperation] { get }
    @MainActor var appPlugins: [AppLifecyclePluginable] { get }
}

///
/// Can be tasked with taking care of a controlled startup process.
///
/// Example usage:
/// ```
/// private lazy var serviceProviders: [ServiceProvider] = [
///     ExampleAppServices(),
///     DomainServices(),
///     FeatureServices(),
/// ]
/// ```
///
/// build first before getting called, usually in SceneDelegate (AppDelegate if first is not implemented)
/// ```
/// AppPlugins.shared.build(serviceProviders: serviceProviders) {
///     print("all tasks completed")
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
public class AppPlugins {

    public static let shared: AppPlugins = AppPlugins()

    @MainActor
    public func build(serviceProviders: [ServiceProvider], finished: @escaping () -> Void) {
        self.serviceProviders = serviceProviders
        CoreServiceLocator.shared.addBuildTasks {
            serviceProviders
        }
        self.allPlugins = serviceProviders.compactMap { $0.appPlugins }.reduce([AppLifecyclePluginable]()) { (result, next) in
            return result + next
        }

        self.allTasks = serviceProviders.compactMap { $0.appTasks }.reduce([AsyncOperation]()) { (result, next) in
            return result + next
        }

        queue.addOperations(allTasks, waitUntilFinished: false)
        queue.addBarrierBlock {
            finished()
            self.isReady = true
        }
    }

    private let queue = OperationQueue()
    private var serviceProviders = [ServiceProvider]()

    private var allTasks: [AsyncOperation] = []
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
