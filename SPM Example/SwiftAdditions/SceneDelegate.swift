import UIKit
import SwiftUI
import Additions

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    override init() {
        super.init()
        AppPlugins.shared.build(serviceProviders: serviceProviders) {
            print("all tasks completed")
        }
    }

    private lazy var serviceProviders: [ServiceProvider] = [
        ExampleAppServices(),
    ]

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        AppPlugins.shared.forEach {
            $0.scene?(scene, willConnectTo: session, options: connectionOptions)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        AppPlugins.shared.forEach {
            $0.sceneDidEnterBackground?(scene)
        }
    }
}

