import Foundation
import UIKit
import UserNotifications

public protocol ApplicationLifecycleTask: UIWindowSceneDelegate, UIApplicationDelegate, UNUserNotificationCenterDelegate {}


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
    var appTasks: [AppTask] { get }
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
open class AppTasks {

    public static var shared: AppTasks?
    public static func build(serviceProviders: [ServiceProvider], finished: @escaping Action) -> AppTasks {
        let tasks = AppTasks(serviceProviders, finished: finished)
        shared = tasks
        return tasks
    }

    @Inject private var dispatch: Dispatching
    private let queue = OperationQueue()
    private  var serviceProviders = [ServiceProvider]()

    private lazy var allTasks: [AppTask] = {
        serviceProviders.compactMap { $0.appTasks }.reduce([AppTask]()) { (result, next) in
            return result + next
        }
    }()

    private init(_ serviceProviders: [ServiceProvider], finished: @escaping Action) {
        self.serviceProviders = serviceProviders
        CoreServiceLocator.shared.addBuildTasks {
            serviceProviders
        }

        queue.addOperations(allTasks, waitUntilFinished: false)
        queue.addBarrierBlock {
            self.dispatch.dispatchMain { [weak self] in
                finished()
                self?.isReady = true
            }
        }
    }

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
            }
            buffer.removeAll()
        }
    }

    private enum BufferedPredicate {
        case forPredicate( (ApplicationLifecycleTask) throws -> Void)
        case allSatisfyPredicate((ApplicationLifecycleTask) throws -> Bool)
    }

    private var buffer = [BufferedPredicate]()

    public func forEach(_ body: @escaping (ApplicationLifecycleTask) throws -> Void) rethrows {
        guard isReady else {
            buffer.append(.forPredicate(body))
            return
        }

        try allTasks.forEach(body)
    }

    @discardableResult
    public func allSatisfy(_ predicate: @escaping (ApplicationLifecycleTask) throws -> Bool) rethrows -> Bool {
        guard isReady else {
            buffer.append(.allSatisfyPredicate(predicate))
            return true
        }
        return try allTasks.allSatisfy(predicate)
    }

    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, ApplicationLifecycleTask) throws -> Result) rethrows -> Result {
        try allTasks.reduce(initialResult, nextPartialResult)
    }
}
