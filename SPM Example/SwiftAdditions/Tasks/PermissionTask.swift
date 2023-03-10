import Foundation
import Additions
import UserNotifications
import UIKit

class PermissionTask: AppTask {

    override func main() {
        super.main()

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in

            self.state = .finished
            print("\(self) finished")
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("\(self) \(#function) \n with \(deviceToken)")
    }

}
