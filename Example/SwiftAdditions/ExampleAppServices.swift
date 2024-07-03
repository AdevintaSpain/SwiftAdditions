import Foundation
import Additions

class ExampleAppServices: ServiceProvider {

    lazy var someLongRunningTask = SomeLongRunningTask()
    lazy var shortTask = SyncTask()
    lazy var dependentTask = DependentTask()
    lazy var permissionTask = PermissionTask()
    lazy var windowSetupTask = WindowSetupTask()
    lazy var onboardingTask = OnboardingTask()
    lazy var mainUISetupTask = MainUISetupTask()

    lazy var plugins: [AppLifecyclePluginable] = []
    lazy var operations: [AsyncOperation] = {

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

    func modules() -> [Register] {
        [
            Register(ReaderProtocol.self, .unique, { Reader() }),
            Register { self.onboardingTask }
        ]
    }
}
