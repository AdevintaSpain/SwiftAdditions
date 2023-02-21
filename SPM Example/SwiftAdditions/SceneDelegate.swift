import UIKit
import SwiftUI
import Additions

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private lazy var serviceProviders: [ServiceProvider] = [
        ExampleAppServices(),
        AdditionsServices(),
    ]

    private lazy var tasks = AppTasks.build(serviceProviders: serviceProviders) {
        print("all tasks completed")
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        tasks.forEach {
            $0.scene?(scene, willConnectTo: session, options: connectionOptions)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        tasks.forEach {
            $0.sceneDidEnterBackground?(scene)
        }
    }
}

