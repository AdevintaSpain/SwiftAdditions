import Foundation
import Additions

class ExampleAppServices: ServiceProvider {

    lazy var someLongRunningTask = SomeLongRunningTask(scope: .default)
    lazy var shortTask = SyncTask()
    lazy var dependentTask = DependentTask(scope: .default)
    lazy var permissionTask = PermissionTask()
    lazy var windowSetupTask = WindowSetupTask(scope: .main)
    lazy var onboardingTask = OnboardingTask(scope: .main)
    lazy var mainUISetupTask = MainUISetupTask(scope: .main)

    lazy var appOperations: [AsyncOperation] = {
        
        dependentTask.addDependency(someLongRunningTask)

        windowSetupTask.addDependency(dependentTask)

        onboardingTask.addDependency(windowSetupTask)

        permissionTask.addDependency(onboardingTask)

        mainUISetupTask.addDependency(permissionTask)
        mainUISetupTask.addDependency(windowSetupTask)

        return [
            someLongRunningTask,
            shortTask,
            dependentTask,
            permissionTask,
            windowSetupTask,
            onboardingTask,
            mainUISetupTask,
        ]
    }()

    var appPlugins: [AppLifecyclePluginable] {
        [PermissionsPlugin()]
    }
    
    func modules() -> [Register] {
        [
            Register(DataSource.self) { CharacterDataSource() },
            Register { self.onboardingTask }
        ]
    }
}
