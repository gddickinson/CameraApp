//
//  AppDelegate.swift
//  CameraApp
//
//  Application delegate
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Create window - no scene delegate configured in Info.plist
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Set root view controller to mode selection
        let modeSelectionVC = ModeSelectionViewController()
        window?.rootViewController = modeSelectionVC
        window?.makeKeyAndVisible()
        
        return true
    }
}
