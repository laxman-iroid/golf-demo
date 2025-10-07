//
//  AppDelegate.swift
//  golf-demo
//
//  Created by Laxmansinh Rajpurohit on 24/09/25.
//

import UIKit
import GoogleMaps
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navVC : UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        // Provide Google Maps API Key
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String {
            GMSServices.provideAPIKey(apiKey)
        }
        self.navigation()
        return true
    }


    func navigation(){
        let nextViewController = STORYBOARD.main.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navVC = UINavigationController(rootViewController: nextViewController)
        self.navVC?.isNavigationBarHidden = true
        self.navVC?.interactivePopGestureRecognizer?.isEnabled = false
        self.navVC?.interactivePopGestureRecognizer?.delegate = nil
        self.window?.rootViewController = nil
        self.window?.rootViewController = navVC
        self.window?.makeKeyAndVisible()
    }
}

