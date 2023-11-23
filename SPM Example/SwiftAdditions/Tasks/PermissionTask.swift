import Foundation
import Additions
import UserNotifications
import UIKit

class PermissionTask: AsyncOperation {

    override func main() {
        super.main()

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in

            self.state = .finished
            print("\(self) finished")
        }
    }

}

class PermissionsPlugin: NSObject, AppLifecyclePluginable {

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("\(self) \(#function) \n with \(deviceToken)")
    }
}
