//
//  AppDelegate.swift
//  WristcamPartnerSampleCode
//
//  Created by Doron Adler on 05/12/2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("launchOptions = \(String(describing: launchOptions))")
        let manager = CUK_Manager.shared
        if let myFirstScheme = CUK_Manager.urlSchemes?.first {
            print("Registering my own scheme \"\(myFirstScheme)\" so Wristcam could call me back")
            manager.callbackURLScheme = myFirstScheme
        } else {
            print ("ERROR: I have no schemes configured, Wristcam will not be able to call back to me")
        }
        return true
    }
    
    //If your App is not UIScene based, uncomment the code below
    /*
    func handleOpen(_ url: URL) -> Bool{
        print("handleOpen(\"\(url)\")")
        let callbackUrlManager = CUK_Manager.shared
        return callbackUrlManager.handleOpen(url: url)
    }
    
     func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool
    {
        return self.handleOpen(url)
    }
     */

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

