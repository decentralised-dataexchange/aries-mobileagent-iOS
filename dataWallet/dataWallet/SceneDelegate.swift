//
//  SceneDelegate.swift
//  dataWallet
//
//  Created by Mohamed Rebin on 11/01/21.
//

import UIKit
import SwiftMessages
import Reachability
import SwiftMessages

private let reachability = try! Reachability()
private let networkErrorMsg = SwiftMessages.init()

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var scene: UIWindowScene?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        self.scene = scene as? UIWindowScene
        SwiftMessages.sharedInstance.defaultConfig.presentationContext = SwiftMessages.PresentationContext.windowScene(((scene as? UIWindowScene)!), windowLevel: UIWindow.Level.normal)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
            do{
              try reachability.startNotifier()
            }catch{
              print("could not start reachability notifier")
            }
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    @objc func reachabilityChanged(note: Notification) {

      let reachability = note.object as! Reachability

      switch reachability.connection {
      case .wifi:
          print("Reachable via WiFi")
        networkErrorMsg.hide()
      case .cellular:
          print("Reachable via Cellular")
        networkErrorMsg.hide()
      case .unavailable:
        print("Network not reachable")
        let view = MessageView.viewFromNib(layout: .statusLine)
        view.backgroundColor = .red
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.presentationContext = .windowScene(scene!, windowLevel: UIWindow.Level.normal)
        config.prefersStatusBarHidden = true
        config.duration = .forever
        config.dimMode = .gray(interactive: true)
        config.interactiveHide = false
        config.preferredStatusBarStyle = .lightContent
//        config.eventListeners.append() { event in
//            if case .didHide = event { print("yep") }
//        }
        view.configureContent(body: "No Internet Connection".localized())
        networkErrorMsg.show(config: config, view: view)
        case .none:
            networkErrorMsg.hide()
            break
      }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

